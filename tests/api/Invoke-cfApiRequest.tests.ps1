
BeforeAll {
    Write-Msg -h -ps -b -m $(' {0}' -f $(Split-Path -Leaf $PSCommandPath))
    $totalZoneCount = 5
    $badAuthToken = ConvertTo-SecureString -String '1234567890abcdefghi-jklmnopqrst_uvwxyz01' -AsPlainText -Force |
                    ConvertFrom-SecureString
}

Describe 'Invoke-cfApiRequest' {

    Context ':: Request all zones via parameters' {
        BeforeAll {
            $request = Invoke-cfApiRequest -Uri '/zones/'
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'Request: ' -o $request -rd 0
        }
        It 'Results in a successful request.' {
            $request.Success | Should -Be $true
        }
        It 'Returns all zones.' {
            $request.Result.Count | Should -Be $totalZoneCount
        }
    }

    Context ':: Request all zones via the PipelineObject' {
        BeforeAll {
            $PO = @{ URI = '/zones/' }
            $PO | Invoke-cfApiRequest | Out-Null
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'PipelineObject: ' -o $PO -rd 1
            Write-Msg -d -ds -m 'Request: ' -o $PO.request -rd 0
        }
        It 'Results in a successful request.' {
            $PO.Success | Should -Be $true
        }
        It 'Returns all zones.' {
            $PO.request.Result.Count | Should -Be $totalZoneCount
        }
    }

    Context ':: Make a request with a bad token via ' {
        BeforeAll {
            $request = Invoke-cfApiRequest -Uri '/zones/' -AuthToken $badAuthToken
        }
        It 'Results in a failed request.' {
            $request.success | Should -Be $false
        }
        It 'Returns the 403 (Forbidden) error message.' {
            $request.errors | Should -Be 'Response status code does not indicate success: 403 (Forbidden).'
        }
    }



}


#                 'The remote server returned an error: (429) Too Many Requests.' {
#                     $PO.Success = $false
#                     $PO.ResultMessage = 'Request limit exceeded. Retry in {0} seconds.' -f $PO.RetrySeconds
#                     Write-Msg -w -m $PO.ResultMessage
#                     Start-Sleep -Seconds $RetrySeconds
#                     $params = @{
#                         AuthToken = $PO.AuthToken
#                         BaseUri   = $PO.BaseUri
#                         Uri       = $PO.Uri
#                         Method    = $PO.Method
#                         Body      = $PO.Body
#                     }
#                     $PO.request = Invoke-cfApiRequest @params -x:$PO.SuppressNotFoundErrors
#                 }

#                 'The remote server returned an error: (404) Not Found.' {
#                     $PO.ResultMessage = 'The object was not found.'
#                     $PO.request = @{
#                         result      = $null
#                         result_info = $null
#                         success     = $null
#                         errors      = $_.Exception.Message
#                         messages    = $_.ErrorDetails.Message
#                     }
#                     if ( $PO.SuppressNotFoundErrors ) {
#                         $PO.request.success = $true
#                         $PO.Success = $true
#                         Write-Msg -s -m $PO.ResultMessage
#                     }
#                     else {
#                         $PO.request.success = $false
#                         $PO.Success = $false
#                         Write-Msg -e -m $PO.ResultMessage
#                     }
#                 }
