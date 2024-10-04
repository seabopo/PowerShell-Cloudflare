#==================================================================================================================
#==================================================================================================================
# PESTER TESTS
#==================================================================================================================
#==================================================================================================================

#==================================================================================================================
# Initialize Test Environment
#==================================================================================================================

    Clear-Host

    Set-Location  -Path $PSScriptRoot
    Push-Location -Path $PSScriptRoot

    $ErrorActionPreference = "Stop"

  # Set the environment variables for psToolKit's Write-Msg function.
    $env:PS_STATUSMESSAGE_SHOW_VERBOSE_MESSAGES = $true
    $env:PS_STATUSMESSAGE_VERBOSE_MESSAGE_TYPES = '["Debug","Information"]'

  # Set the environment variables for psToolKit's Initialize-PipelineObject function to determine if the
  # function call and input parameters should be logged.
    $env:PS_PIPELINEOBJECT_LOGGING       = $false
    $env:PS_PIPELINEOBJECT_DONTLOGPARAMS = $false
    $env:PS_PIPELINEOBJECT_LOGVALUES     = $true

  # Set the Cloudflare Account ID and Access Token
    . ".\init-tokens.ps1"

  # Import the module from it's repository location.
    Import-Module '../po.Cloudflare' -Force

  # List the exported functions and aliases so they can be copied to the PSD1 file.
    Write-Msg -p -ps -bb -m ' Module Loaded. The following functions and aliases are available:'
    $thisModule = Get-Module -Name 'psCloudflare'
    Write-Msg -a -ps -m 'psCloudFlare Public Functions: ' -o $( $thisModule.ExportedFunctions.Keys | Sort-Object )
    Write-Msg -a -ps -m 'psCloudFlare Public Aliases: '   -o $( $thisModule.ExportedAliases.Keys   | Sort-Object )

  # Import the Pester module.
    Import-Module Pester

#==================================================================================================================
# Run Tests
#==================================================================================================================

  # API Tests
    Write-Msg -h -ps -ds -bb -cb  -m ' Starting Pester API Tests ...'
    Invoke-Pester -Output Detailed @(
        './api/Invoke-cfApiRequest.Tests.ps1'
    )

  # Zone Tests
    Write-Msg -h -ps -ds -bb -cb  -m ' Starting Pester Zone Tests ...'
    Invoke-Pester -Output Detailed @(
        './zone/Get-cfZones.Tests.ps1',
        './zone/Get-cfZone.Tests.ps1'
    )


    #Get-cfZones | Select-Object -First 1









