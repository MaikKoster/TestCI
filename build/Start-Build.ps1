#Requires -Version 5
Param( $Task = "Build")

# Ensure InvokeBuild is installed to drive rest of the build process
if ((get-module InvokeBuild -ListAvailable) -eq $null) {
    $null = Install-Module InvokeBuild
}

if (Get-Module InvokeBuild -ListAvailable) {
    Import-Module InvokeBuild -Force
} else {
    throw 'How did you even get here?'
}

# Kick off the standard build
try {
    Invoke-Build -File ".\build\ConfigMgr.Build.ps1" -Task $Task
} catch {
    Write-Host -ForegroundColor Red 'Build Failed with the following error:'
    Write-Output $_
}
