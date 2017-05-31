<#
.SYNOPSIS
    Publishes a PowerShell Module to a Network Share.

.Example
    $ModuleInfo = @{
        RepoName   = 'PoshRepo'
        RepoPath   = '\\server\PoshRepo'
        ModuleName = 'BuildHelpersTest'
        ModulePath = '.\BuildHelpersTest.psd1'
    }

    Publish-SMBModule @ModuleInfo
#>
function Publish-SMBModule
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $RepoName,

        [Parameter(Mandatory=$true)]
        [string] $RepoPath,

        [Parameter(Mandatory=$true)]
        [string] $ModuleName,

        [Parameter(Mandatory=$true)]
        [string] $ModulePath,

        [Parameter(Mandatory=$true)]
        [int] $BuildNumber
    )

    # Just force it x.x
    Install-Nuget

    # Resister SMB Share as Repository
    Write-Verbose ("Checking if Repo: {0} is registered" -f $RepoName)
    if(!(Get-PSRepository -Name $RepoName -ErrorAction SilentlyContinue))
    {
        Write-Verbose ("Registering Repo: {0}" -f $RepoName)
        Register-PSRepository -Name $RepoName -SourceLocation $RepoPath -InstallationPolicy Trusted
    }

    # Update Existing Manifest
    # - Source Manifest controls Major/Minor
    # - Jenkins Controls Build Number.
    Write-Verbose ("Checking if Module: {0} is registered" -f $ModuleName)
    if(Find-Module -Repository $RepoName -Name $ModuleName -ErrorAction SilentlyContinue)
    {
        Write-Verbose ("Updating Manifest for: {0}" -f $ModuleName)
        $version = (Get-Module -FullyQualifiedName $ModulePath -ListAvailable).Version | Select-Object Major, Minor
        $newVersion = New-Object Version -ArgumentList $version.major, $version.minor, $BuildNumber
        Update-ModuleManifest -Path $ModulePath -ModuleVersion $newVersion
    }

    # Publish ModuleInfo
    # - Fails if nuget install needs confirmation in NonInteractive Mode.
    Write-Verbose ("Publishing Module: {0}" -f $ModuleName)
    try
    {
        $env:PSModulePath += ";$PSScriptRoot"
        Publish-Module -Repository $RepoName -Name $ModuleName
    }
    catch [System.Exception]
    {
        # Write-Error "Publish Failed"
        throw($_.Exception)
    }
}

<#
    .SYNOPSIS
        Create a Zip Archive Build Artifact
#>
function Publish-ArtifactZip
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $ModuleName,

        [Parameter(Mandatory=$true)]
        [int] $BuildNumber
    )

    # Creating project artifact
    $artifactDirectory = Join-Path $pwd "artifacts"
    $moduleDirectory = Join-Path $pwd "$ModuleName"
    $manifest = Join-Path $moduleDirectory "$ModuleName.psd1"
    $zipFilePath = Join-Path $artifactDirectory "$ModuleName.zip"

    $version = (Get-Module -FullyQualifiedName $manifest -ListAvailable).Version | Select-Object Major, Minor
    $newVersion = New-Object Version -ArgumentList $version.major, $version.minor, $BuildNumber
    Update-ModuleManifest -Path $manifest -ModuleVersion $newVersion

    Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($moduleDirectory, $zipFilePath)
}

<#
    .SYNOPSIS
        Create a Nuget Package for the Build Artifact
        Simple wrapper around DscResourceTestHelper Module
#>
function Publish-NugetPackage
{
   param
    (
        [Parameter(Mandatory=$true)]
        [string] $packageName,
        [Parameter(Mandatory=$true)]
        [string] $author,
        [Parameter(Mandatory=$true)]
        [int] $BuildNumber,
        [Parameter(Mandatory=$true)]
        [string] $owners,
        [string] $licenseUrl,
        [string] $projectUrl,
        [string] $iconUrl,
        [string] $packageDescription,
        [string] $releaseNotes,
        [string] $tags,
        [Parameter(Mandatory=$true)]
        [string] $destinationPath
    )

    $CurrentVersion = (Get-Module -FullyQualifiedName "./$ModuleName" -ListAvailable).Version | Select-Object Major, Minor
    $version = New-Object Version -ArgumentList $CurrentVersion.major, $CurrentVersion.minor, $BuildNumber

    $moduleInfo = @{
        packageName = $packageName
        version =  ($version.ToString())
        author =  $author
        owners = $owners
        licenseUrl = $licenseUrl
        projectUrl = $projectUrl
        packageDescription = $packageDescription
        tags = $tags
        destinationPath = $destinationPath
    }

    # Creating NuGet package artifact
    Import-Module -Name DscResourceTestHelper
    New-Nuspec @moduleInfo

    $nuget = "$env:ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\nuget.exe"
    . $nuget pack "$destinationPath\$packageName.nuspec" -outputdirectory $destinationPath
}

<#
    .SYNOPSIS
        Used to address problem running Publish-Module in NonInteractive Mode when Nuget is not present.

    .NOTES
        https://github.com/OneGet/oneget/issues/173
        https://github.com/PowerShell/PowerShellGet/issues/79

        If Build Agent does not have permission to ProgramData Folder, may want to use the user specific folder.

        Package Provider Expected Locations (x86):
            C:\Program Files (x86)\PackageManagement\ProviderAssemblies
            C:\Users\{USER}\AppData\Local\PackageManagement\ProviderAssemblies
#>
function Install-Nuget
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [switch] $Force = $false
    )

    # Force Update Provider
    Install-PackageProvider Nuget -Force

    $sourceNugetExe = "http://nuget.org/nuget.exe"
    $powerShellGetDir = "$env:ProgramData\Microsoft\Windows\PowerShell\PowerShellGet"

    if(!(Test-Path -Path $powerShellGetDir))
    {
        New-Item -ItemType Directory -Path $powerShellGetDir -Force
    }

    if(!(Test-Path -Path "$powerShellGetDir\nuget.exe") -or $Force)
    {
        Invoke-WebRequest $sourceNugetExe -OutFile "$powerShellGetDir\nuget.exe"
    }
}