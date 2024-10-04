function Get-cfDNSrecords {
    <#
    .DESCRIPTION
        Gets the DNS records for a Cloudflare zone.

    .OUTPUTS
        An Array of PSCustomObjects, each containing a single DNS record.

    .PARAMETER ZoneName
        REQUIRED. String. Alias: -n. The name of the Cloudflare zone. Example: cloudflare.com

    .PARAMETER ZoneID
        REQUIRED. String. Alias: -i. The Cloudflare Zone ID. Example: x60b485ea06e97c2c1c4b1cabf7e5aa2

    .PARAMETER RecordTypes
        REQUIRED. Array of String. Alias: -t. Filters the DNS records by type (A, CNAME, TXT, ...).

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
        Get-cfDNSrecords -AccountID '<AccountID>' -AuthToken '<AuthToken>' -ZoneName 'my-zone.com'

    #>
    [OutputType([Hashtable])]
    [CmdletBinding(DefaultParameterSetName='P')]
    param (
        [Parameter(ParameterSetName='N')] [Alias('n')]  [String]   $ZoneName,
        [Parameter(ParameterSetName='I')] [Alias('i')]  [String]   $ZoneID,
        [Parameter()]                     [Alias('t')]  [String[]] $RecordTypes,

        [Parameter()]                     [Alias('ai')] [String]   $AccountID = $env:CLOUDFLARE_ACCOUNT_ID,
        [Parameter()]                     [Alias('at')] [String]   $AuthToken = $env:CLOUDFLARE_AUTH_TOKEN,

        [Parameter(DontShow,ValueFromPipeline,ParameterSetName='P')] [Hashtable] $PO = @{}
    )

    process {

        try {

            $parameterTests = @{
                AnyIsNull  = @('AccountID','AuthToken')
                AllAreNull = @('ZoneName','ZoneID')
            }

            $PO | Initialize-PipelineObject -t $parameterTests | Out-Null

            if ( $PO.Success ) {

                if ( $PO.ZoneName ) {
                    $PO | Get-cfZoneID -ZoneName $PO.ZoneName -AccountID $PO.AccountID -AuthToken $PO.AuthToken
                }





            }





            $invocationData = @{
                DNSRecords = $null
                Tests = @{ AnyIsNull=@('AccountID','AuthToken'); AllAreNull=@('ZoneName','ZoneID'); ZoneID=$null }
            }
            $PO = $invocationData | Initialize-kcPipelineObject -apo -log | Test-Parameters



            if ( $PO.Tests.ContinueProcessing ) {

                $requestParams = @{
                    AuthToken  = $PO.AuthToken
                    Uri        = "/zones/{0}/dns_records?per_page=10000" -f $PO.ZoneID
                    Method     = 'GET'
                }
                $PO | Invoke-KCcfApiRequest @requestParams | Out-Null

                $PO.DNSRecords = switch ( $MyInvocation.InvocationName ) {
                                        'Get-KCcfZoneDNSARecords'
                                            { $PO.apiRequest.result | Where-Object { $_.type -eq 'A' } }
                                        'Get-KCcfZoneDNSCnameRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.type -eq 'CNAME' } }
                                        'Get-KCcfZoneDNSTxtRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.type -eq 'TXT' } }
                                        'Get-KCcfZoneDNSNsRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.type -eq 'NS' } }
                                        'Get-KCcfZoneDNSMxRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.type -eq 'MX' } }
                                        'Get-KCcfZoneDNSProxiedRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.proxied -eq $true } }
                                        'Get-KCcfZoneDNSNonProxiedRecords'
                                            { $PO.apiRequest.result | Where-Object { $_.proxied -eq $false } }
                                        default { $PO.apiRequest.result }
                                }

                if ( $PO.apiRequest.success ) {
                    $PO.Logs[$LogID] += $('... Result: Success')
                    $PO.Logs[$LogID] += $('... Result Count: {0} records' -f $($PO.DNSRecords | Measure-Object).Count)
                }
                else {
                    $PO.Logs[$LogID] += $('... Result: Failure')
                    $PO.Logs[$LogID] += $('... Error Message: {0}' -f $PO.apiRequest.errors )
                }
            }
        }

        catch {
            $PO.Logs[$LogID] += $('... Result: Exception Error.')
            $PO.Logs[$LogID] += $('... Error Message: {0}' -f $($_.Exception.Message))
            $PO.Logs[$LogID] += $('... Error Details: {0}' -f $($_.ErrorDetails.Message))
        }

        if ( $PSCmdlet.ParameterSetName -eq 'P' ) { return $PO } else { $PO | Write-Logs; return $PO.DNSRecords }
    }
}
