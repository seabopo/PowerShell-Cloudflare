
BeforeAll {
    Write-Msg -h -ps -b -m $(' {0}' -f $(Split-Path -Leaf $PSCommandPath))
    $testZoneName = 'the-powells.org'
}

Describe 'Get-cfZone' {

    Context ':: Get a single zone using parameters' {
        BeforeAll {
            $zone = Get-cfZone -ZoneName $testZoneName
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'Zone: ' -o $zone -rd 0
        }
        It 'Results in a successful request.' {
            $zone | Should -Not -BeNullOrEmpty
        }
        It 'Returns all zones.' {
            $zone.name | Should -Be $testZoneName
        }
    }

    Context ':: Get a single zone using the PipelineObject' {
        BeforeAll {
            $PO = @{ ZoneName = $testZoneName }
            $PO | Get-cfZone | Out-Null
            Write-Msg -a -ps -m 'Result Object:'
            Write-Msg -d -ds -m 'PipelineObject: ' -o $PO -rd 1
            Write-Msg -d -ds -m 'Zone: ' -o $PO.Zone -rd 0
        }
        It 'Results in a successful request.' {
            $PO.Success | Should -Be $true
        }
        It 'Returns all zones.' {
            $PO.Zone.name | Should -Be $testZoneName
        }
    }

}