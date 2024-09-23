
BeforeAll {
    Write-Msg -h -ps -b -m $(' {0}' -f $(Split-Path -Leaf $PSCommandPath))
    $totalZoneCount = 5
}

Describe 'Get-cfZones' {

    Context ':: Get all zones using parameters' {
        BeforeAll {
            $zones = Get-cfZones
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'Zones: ' -o $( $zones | Select-Object -Property Name, ID, Status ) -rd 0
        }
        It 'Returns all zones.' {
            $zones.Result.Count | Should -Be $totalZoneCount
        }
    }

    Context ':: Get zones using the PipelineObject' {
        BeforeAll {
            $PO = @{}
            $PO | Get-cfZones | Out-Null
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'PipelineObject: ' -o $PO -rd 0
            Write-Msg -d -ds -m 'Zones: ' -o $( $PO.Zones | Select-Object -Property Name, ID, Status ) -rd 0
        }
        It 'Results in a successful request.' {
            $PO.Success | Should -Be $true
        }
        It 'Returns all zones.' {
            $PO.Zones.Result.Count | Should -Be $totalZoneCount
        }
    }

}
