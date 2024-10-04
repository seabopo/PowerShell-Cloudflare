function Get-cfZone {
    <#
    .DESCRIPTION
        Gets a Cloudflare zone.

    .OUTPUTS
        A Hashtable of zone properties.

    .PARAMETER ZoneName
        REQUIRED. String. Alias: -n. The name of the Cloudflare zone. Example: cloudflare.com

    .PARAMETER AccountID
        OPTIONAL. String. Alias: -ai. The Cloudflare Account ID.
        Default Value: $env:CLOUDFLARE_ACCOUNT_ID
        This ID can be found on any zone overview page in the Cloudflare dashboard.

    .PARAMETER AuthToken
        OPTIONAL. String. Alias: -at. The Cloudflare API authorization token.
        Default: $env:CLOUDFLARE_AUTH_TOKEN
        Link: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/

    .PARAMETER PO
        OPTIONAL. HashTable. An object used to pass values throughout the module via the PowerShell pipeline.

    .EXAMPLE
        Get-cfZone -AccountID '<AccountID>' -AuthToken '<AuthToken>' -ZoneName 'my-zone.com'

    #>
    [OutputType([Hashtable])]
    [CmdletBinding(DefaultParameterSetName='P')]
    param (
        [Parameter(ParameterSetName='N')] [Alias('n')]  [String] $ZoneName,

        [Parameter()]                     [Alias('ai')] [String] $AccountID = $env:CLOUDFLARE_ACCOUNT_ID,
        [Parameter()]                     [Alias('at')] [String] $AuthToken = $env:CLOUDFLARE_AUTH_TOKEN,

        [Parameter(DontShow,ValueFromPipeline,ParameterSetName='P')] [Hashtable] $PO = @{}
    )

    process {

        try {

            $PO.Zone = $null

            $PO | Initialize-PipelineObject -t @{ AnyIsNull = @('AccountID','AuthToken','ZoneName') } | Out-Null

            if ( $PO.Success ) {

                $uri = $( '/zones?account.id={0}&name={1}' -f $PO.AccountID, $PO.ZoneName )
                $request = Invoke-cfApiRequest -at $PO.AuthToken -u $uri

                if ( $request.success ) {
                    $PO.Zone = $request.result
                    $PO.Success = $true
                    $PO.ResultMessage = 'Zone was retrieved successfully from CloudFlare.'
                    Write-Msg -s -m $PO.ResultMessage
                }

            }
        }

        catch {
            $PO.Success = $false
            $PO.ResultMessage = $_.Exception.Message
            Write-Msg -x -o $_
        }

        if ( $PSCmdlet.ParameterSetName -eq 'P' ) { return $PO } else { return $PO.Zone}
    }
}
