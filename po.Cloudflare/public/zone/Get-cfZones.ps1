function Get-cfZones {
    <#
    .DESCRIPTION
        Gets all Cloudflare zones for an account.

    .OUTPUTS
        An array of Hashtables, each containing a set of zone properties.

    .PARAMETER AuthToken
        OPTIONAL. String. Alias: -at. The Cloudflare API authorization token.
        Default: $env:CLOUDFLARE_AUTH_TOKEN
        Link: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/

    .PARAMETER PO
        OPTIONAL. HashTable. An object used to pass values throughout the module via the PowerShell pipeline.

    .EXAMPLE
        Get-cfZones -AuthToken '<AuthToken>'

    #>
    [OutputType([Hashtable])]
    [CmdletBinding(DefaultParameterSetName='None')]
    param (
        [Parameter()] [Alias('at')] [String] $AuthToken = $env:CLOUDFLARE_AUTH_TOKEN,

        [Parameter(DontShow,ValueFromPipeline,ParameterSetName='P')] [Hashtable] $PO = @{}
    )

    process {

        try {

            $PO.Zones = $null

            $PO | Initialize-PipelineObject -t @{ AnyIsNull  = @('AuthToken') } | Out-Null

            if ( $PO.Success ) {

                Write-Msg -p -ps -m $( 'Getting zones from Cloudflare ...' )

                $page    = 0
                $perPage = 1000

                Do {
                    $page ++
                    $uri = '/zones/?page={0}&per_page={1}' -f $page, $perPage
                    $request = Invoke-cfApiRequest -at $PO.AuthToken -u $uri
                    if ( $request.success ) {
                        $PO.Zones += $request.result
                    }
                } until ( $PO.result.result_info.count -lt $perPage )

                $PO.Success = $true
                $PO.ResultMessage = 'Zones were retrieved successfully from CloudFlare.' -f $PO.Zones.Count
                Write-Msg -s -m $PO.ResultMessage

            }

        }

        catch {
            $PO.Success = $false
            $PO.ResultMessage = $_.Exception.Message
            Write-Msg -x -o $_
        }

        if ( $PSCmdlet.ParameterSetName -eq 'P' ) { return $PO } else { return $PO.Zones }
    }
}
