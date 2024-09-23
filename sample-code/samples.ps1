#==================================================================================================================
#==================================================================================================================
# Sample Code :: Cloudflare PowerShell Module
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
    Import-Module '../' -Force

#==================================================================================================================
# Sample Code
#==================================================================================================================








