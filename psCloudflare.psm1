#==================================================================================================================
#==================================================================================================================
# POWERSHELL MODULE: psCloudflare
#==================================================================================================================
#==================================================================================================================

#==================================================================================================================
# INITIALIZATIONS
#==================================================================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Stop"

Set-Variable -Scope 'Local' -Name "PS_MODULE_ROOT" -Value $PSScriptRoot
Set-Variable -Scope 'Local' -Name "PS_MODULE_NAME" -Value $($PSScriptRoot | Split-Path -Leaf)

#==================================================================================================================
# LOAD FUNCTIONS AND EXPORT PUBLIC FUNCTIONS AND ALIASES
#==================================================================================================================

# Define the root folder source lists for public and private functions
  $publicFunctionsRootFolders  = @('Public')
  $privateFunctionsRootFolders = @('Private')

# Load all public functions
  $publicFunctionsRootFolders | ForEach-Object {
      Get-ChildItem -Path "$PS_MODULE_ROOT\$_\*.ps1" -Recurse |
          Where-Object { $_.Name -notlike '*.tests.ps1' } |
          ForEach-Object { . $($_.FullName) }
  }

# Export all the public functions and aliases (enable for testing only)
  Export-ModuleMember -Function * -Alias *

# Load all private functions
  $privateFunctionsRootFolders | ForEach-Object {
      Get-ChildItem -Path "$PS_MODULE_ROOT\$_\*.ps1" -Recurse |
      Where-Object { $_.Name -notlike '*.tests.ps1' } |
      ForEach-Object { . $($_.FullName) }
  }

#==================================================================================================================
# SET ENVIRONMENT VARIABLE DEFAULTS
#==================================================================================================================

  $env:CLOUDFLARE_API_THROTTLE_RETRY_SECONDS = 10

#==================================================================================================================
# VALIDATE REQUIRED ENVIRONMENT VARIABLES ARE PRESENT
#==================================================================================================================

$validationErrorMessage = "Environment variable '{0}' is not defined."

if ( [String]::IsNullOrEmpty($env:CLOUDFLARE_ACCOUNT_ID) ) {
    Write-Msg -w -m $( $validationErrorMessage -f 'CLOUDFLARE_ACCOUNT_ID' )
}

if ( [String]::IsNullOrEmpty($env:CLOUDFLARE_AUTH_TOKEN) ) {
    Write-Msg -w -m $( $validationErrorMessage -f 'CLOUDFLARE_AUTH_TOKEN' )
}
