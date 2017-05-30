param(
    $Task = 'Build'
)

# InvokeBuild is required to drive all further steps
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name InvokeBuild -Force

Invoke-Build -File ".\Build\ConfigMgr.Build.ps1" -Task $Task

