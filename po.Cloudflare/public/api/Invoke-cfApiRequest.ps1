function Invoke-cfApiRequest {
    <#
    .DESCRIPTION
        Executes a Cloudflare API request.

    .OUTPUTS
        A HashTable containing the results of the API request.

    .PARAMETER Method
        OPTIONAL. String. Alias: -m. The api request method.
        Default: 'GET'.
        Accepted Values: 'GET', 'POST', 'PATCH', 'DELETE'

    .PARAMETER BaseUri
        OPTIONAL. String. Alias: -bu. The stable base URI for all requests targeting a specific version of the
        Cloudflare API.
        Default: https://api.cloudflare.com/client/v4/
        Link: https://developers.cloudflare.com/fundamentals/api/how-to/make-api-calls/#using-cloudflares-apis

    .PARAMETER Uri
        REQUIRED. String. Alias: -u. The variable portion of the api request that contains the query parameters
        specific to the individual the api request. This should always start with a forward slash '/'.
        Example: the '/zones/<zone_id>' portion of the URI: https://api.cloudflare.com/client/v4/zones/<zone_id>

    .PARAMETER Body
        OPTIONAL. String. Alias: -b. The body of the api method in valid a valid JSON document. This is usually
        required for POST, PATCH and DELETE methods.

    .PARAMETER SuppressNotFoundErrors
        OPTIONAL. Switch. Alias: -x. Prevents errors from being written to the console when a function makes an
        api request and the object is not found. Used by functions when they performan object validation.

    .PARAMETER RetrySeconds
        OPTIONAL. Integer. Alias: -rt. The number of seconds to wait before retrying a request when the API
        returns the 'The remote server returned an error: (429) Too Many Requests.' error.
        Default: 10, set from $env:CLOUDFLARE_API_THROTTLE_RETRY_SECONDS

    .PARAMETER AuthToken
        OPTIONAL. String. Alias: -at. The Cloudflare API authorization token AS AN ENCRYPTED, PLAIN-TEXT STRING.
        Link: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
        Please note that this parameter requires an encrypted plain-text string, NOT a SecureString, as a
        secure string cannot be stored as an environment variable. To encrypt the token and set it to an
        environment variable use the following PowerShell command:
            $env:CLOUDFLARE_AUTH_TOKEN = ConvertTo-SecureString -String '<token>' -AsPlainText -Force |
                                         ConvertFrom-SecureString

    .PARAMETER PO
        OPTIONAL. HashTable. An object used to pass values throughout the module via the PowerShell pipeline.

    .EXAMPLE
        Invoke-cfApiRequest -at '<AuthToken>' -ab '<BaseUri>' -uri '<Uri>' -m 'GET' -b '<Body>'
    #>
    [OutputType([Hashtable])]
    [CmdletBinding(DefaultParameterSetName='U')]
    param (
        [Parameter()] [ValidateSet('GET','POST','PATCH','DELETE','PUT')]
                      [Alias('m')]  [String] $Method = 'GET',
        [Parameter()] [Alias('u')]  [String] $Uri,
        [Parameter()] [Alias('b')]  [String] $Body,
        [Parameter()] [Alias('x')]  [Switch] $SuppressNotFoundErrors,

        [Parameter()] [Alias('at')] [String] $AuthToken    = $env:CLOUDFLARE_AUTH_TOKEN,
        [Parameter()] [Alias('bu')] [String] $BaseUri      = 'https://api.cloudflare.com/client/v4',
        [Parameter()] [Alias('rs')] [Int]    $RetrySeconds = $env:CLOUDFLARE_API_THROTTLE_RETRY_SECONDS,

        [Parameter(DontShow,ValueFromPipeline,ParameterSetName='P')] [Hashtable] $PO = @{}
    )

    process {

        try {

            $PO | Initialize-PipelineObject -t @{ AnyIsNull = @('AuthToken','Method','Uri','BaseUri') } | Out-Null

            if ( $PO.Success ) {

                Write-Msg -p -ps -m $( 'Executing Cloudflare API request ...' )
                Write-Msg -d -il 1 -m $( 'Request URI: {0}{1}' -f $BaseUri, $Uri )

              # The token is unencrypted, so so do not add it to the PipelineObject.
                $token = $PO.AuthToken | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText

              # The token is unencrypted, so so do not add the header to the PipelineObject.
                $headers = @{
                    "Content-Type"  = "application/json"
                    "Authorization" = "Bearer {0}" -f $token
                }

              # The token is unencrypted, so so do not add the params to the PipelineObject.
                $params = @{
                    Headers = $headers
                    Method  = $PO.Method
                    Uri     = $( '{0}{1}' -f $PO.BaseUri, $PO.Uri )
                }

                $PO.request = switch ( $Method ) {
                    'GET'   { Invoke-RestMethod @params }
                    default { Invoke-RestMethod @params -Body $PO.Body }
                }

                Write-Msg -d -il 1 -m $( 'Request Success: {0}' -f $PO.request.success )

                if ( [string]::IsNullOrEmpty($PO.request) ) {
                    $PO.Success = $false
                    $PO.ResultMessage = 'No results returned from the API.'
                    Write-Msg -e -m $PO.ResultMessage
                }
                elseif ( $PO.request.success ) {
                    $resultCount = $($PO.request.result | Measure-Object).Count
                    $PO.Success = $true
                    $PO.ResultMessage = '{0} results returned from the API.' -f $resultCount
                    Write-Msg -d -il 1 -m $( 'Result Count: {0}'  -f $resultCount )
                    Write-Msg -d -il 1 -m $( 'Error Count: {0}'   -f $($PO.request.errors | Measure-Object).Count )
                    Write-Msg -d -il 1 -m $( 'Message Count: {0}' -f $($PO.request.messages | Measure-Object).Count )
                    Write-Msg -s -m $PO.ResultMessage
                }
                else {
                    $PO.Success = $false
                    $PO.ResultMessage = 'The API request returned an error.'
                    Write-Msg -e -m $PO.ResultMessage
                    $request.errors   | ForEach-Object { Write-Msg -e -il 1 -m $('... Error: {0}'   -f $_) }
                    $request.messages | ForEach-Object { Write-Msg -w -il 1 -m $('... Message: {0}' -f $_) }
                }

            }

        }

        catch {

            $PO.Success = $false
            $PO.ResultMessage = $_.Exception.Message
            $PO.request = @{
                result      = $null
                result_info = $null
                success     = $false
                errors      = $_.Exception.Message
                messages    = $_.ErrorDetails.Message
            }

            switch ( $_.Exception.Message ) {

                'The remote server returned an error: (429) Too Many Requests.' {
                    $PO.ResultMessage = 'Request limit exceeded. Retrying in {0} seconds.' -f $PO.RetrySeconds
                    Write-Msg -w -m $PO.ResultMessage
                    Start-Sleep -Seconds $RetrySeconds
                    $PO | Invoke-cfApiRequest -x:$PO.SuppressNotFoundErrors
                }

                'Response status code does not indicate success: 403 (Forbidden).' {
                    Write-Msg -e -m $PO.ResultMessage
                    Write-Msg -e -m $('Validate the authentication token is correct.')
                    Write-Msg -e -m $('The token used for this request starts with: {0}' -f $token.substring(0,6))
                }

                'The remote server returned an error: (404) Not Found.' {
                    if ( $PO.SuppressNotFoundErrors ) {
                        $PO.request.success = $true
                        $PO.Success = $true
                        Write-Msg -s -m $PO.ResultMessage
                    }
                    else {
                        Write-Msg -e -m $PO.ResultMessage
                    }
                }

                default {
                    Write-Msg -x -o $_
                }

            }

        }

        if ( $PSCmdlet.ParameterSetName -eq 'P' ) { return $PO } else { return $PO.request }

   }
}
