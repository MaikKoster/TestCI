param (
	[string]$ReleaseNotes = $null
)

if (Test-Path '.\build\.buildenvironment.ps1') {
    . '.\build\.buildenvironment.ps1'
} else {
    Write-Error "Without a build environment file we are at a loss as to what to do!"
}

# You really shouldn't change this for a powershell module (if you want it to publish to the psgallery correctly)
$CurrentReleaseFolder = $ModuleToBuild

# Put together our full paths. Generally leave these alone
$ModuleFullPath = (Get-Item "$($ModuleToBuild).psm1").FullName
$ScriptRoot = Split-Path $ModuleFullPath
$ScratchPath = Join-Path $ScriptRoot $ScratchFolder
$ModuleManifestFullPath = (Get-Item "$($ModuleToBuild).psd1").FullName
$ReleasePath = Join-Path $ScriptRoot $BaseReleaseFolder
$CurrentReleasePath = Join-Path $ReleasePath $CurrentReleaseFolder
$StageReleasePath = Join-Path $ScratchPath $BaseReleaseFolder   # Just before releasing the module we stage some changes in this location.

# These are required for a full build process and will be automatically installed if they aren't available
$RequiredModules = @('BuildHelpers', 'PlatyPS', 'PSScriptAnalyzer', 'Pester')

# Used later to determine if we are in a configured state or not
$IsConfigured = $False

# Used to update our function CBH to external help reference
$ExternalHelp = @"
<#
    .EXTERNALHELP $($ModuleToBuild)-help.xml
    #>
"@

# Include: Settings
#. './ConfigMgr.settings.ps1'

# Include: build_utils
#. './build_utils.ps1'

# Full Build pipeline
#task Build InstallDependencies, Clean, Analyze, Test

# Synopsis: Run/Publish Tests and Fail Build on Error
#task Test Clean, Analyze, BeforeTest, RunTests, ConfirmTestsPassed, AfterTest

# Synopsis: Run full Pipleline.
#task . Clean, Analyze, Test, Archive, Publish

#Synopsis: Validate system requirements are met
task ValidateRequirements {
    Write-Host -NoNewLine '      Running Powershell version 5?'
    assert ($PSVersionTable.PSVersion.Major.ToString() -eq '5') 'Powershell 5 is required for this build to function properly (you can comment this assert out if you are able to work around this requirement)'
    Write-Host -ForegroundColor Green '...Yup!'
}


#Synopsis: Load required modules if available. Otherwise try to install, then load it.
task LoadRequiredModules {
    $RequiredModules | Foreach {
        if ((get-module $_ -ListAvailable) -eq $null) {
            Write-Host -NoNewLine "      Installing $($_) Module"
            $null = Install-Module $_
            Write-Host -ForegroundColor Green '...Installed!'
        }

        if (get-module $_ -ListAvailable) {
            Write-Host -NoNewLine "      Importing $($_) Module"
            Import-Module $_ -Force
            Write-Host -ForegroundColor Green '...Loaded!'
        } else {
            throw 'How did you even get here?'
        }
    }
}

task Configure ValidateRequirements, LoadRequiredModules, {
    # If we made it this far then we are configured!
    $Script:IsConfigured = $True
    Write-Host -NoNewline '      Configure build environment'
    Write-Host -ForegroundColor Green '...configured!'
}

# Synopsis: Install Build Dependencies
#task InstallDependencies {
    # Cant run an Invoke-Build Task without Invoke-Build.
    # Should be installed via "Start-Build.ps1"
    #Install-Module -Name InvokeBuild -Force

#    Install-Module -Name DscResourceTestHelper -Force
#    Install-Module -Name Pester -Force
#    Install-Module -Name PSScriptAnalyzer -Force
#    Install-Module -Name BuildHelpers -Force
#}

# Synopsis: Clean Artifacts Directory
task Clean {
    Write-Host -NoNewLine "      Clean up our scratch/staging directory at $($ScratchPath)"
    if(Test-Path -Path $ScratchPath) { Remove-Item "$ScratchPath/*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null}
    New-Item -ItemType Directory -Path $Artifacts -Force | Out-Null
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Create base content tree in scratch staging area
task PrepareStage {
    # Create the directories
    $null = New-Item "$($ScratchPath)\src" -ItemType:Directory -Force
    $null = New-Item $StageReleasePath -ItemType:Directory -Force

    Copy-Item -Path "$($ScriptRoot)\*.psm1" -Destination $ScratchPath
    Copy-Item -Path "$($ScriptRoot)\*.psd1" -Destination $ScratchPath
    Copy-Item -Path "$($ScriptRoot)\$($PublicFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PublicFunctionSource)"
    Copy-Item -Path "$($ScriptRoot)\$($PrivateFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PrivateFunctionSource)"
    Copy-Item -Path "$($ScriptRoot)\$($OtherModuleSource)" -Recurse -Destination "$($ScratchPath)\$($OtherModuleSource)"
    Copy-Item -Path "$($ScriptRoot)\en-US" -Recurse -Destination $ScratchPath
}

# Synopsis: Assemble the module for release
task CreateModulePSM1 {
    $CombineFiles = "## OTHER MODULE FUNCTIONS AND DATA ##`r`n`r`n"
    Write-Host "      Other Source Files: $($ScratchPath)\$($OtherModuleSource)"
    Get-childitem  (Join-Path $ScratchPath "$($OtherModuleSource)\*.ps1") | foreach {
        Write-Host "             $($_.Name)"
        $CombineFiles += (Get-content $_ -Raw) + "`r`n`r`n"
    }
    Write-Host -NoNewLine "      Combining other source files"
    Write-Host -ForegroundColor Green '...Complete!'

    $CombineFiles += "## PRIVATE MODULE FUNCTIONS AND DATA ##`r`n`r`n"
    Write-Host  "      Private Source Files: $($ScratchPath)\$($PrivateFunctionSource)"
    Get-childitem  (Join-Path $ScratchPath "$($PrivateFunctionSource)\*.ps1") | foreach {
        Write-Host "             $($_.Name)"
        $CombineFiles += (Get-content $_ -Raw) + "`r`n`r`n"
    }
    Write-Host -NoNewLine "      Combining private source files"
    Write-Host -ForegroundColor Green '...Complete!'

    $CombineFiles += "## PUBLIC MODULE FUNCTIONS AND DATA ##`r`n`r`n"
    Write-Host  "      Public Source Files: $($PublicFunctionSource)"
    Get-childitem  (Join-Path $ScratchPath "$($PublicFunctionSource)\*.ps1") | foreach {
        Write-Host "             $($_.Name)"
        $CombineFiles += (Get-content $_ -Raw) + "`r`n`r`n"
    }
    Write-Host -NoNewline "      Combining public source files"
    Write-Host -ForegroundColor Green '...Complete!'

    Set-Content $Script:ReleaseModule ($CombineFiles) -Encoding UTF8
    Write-Host -NoNewLine '      Combining module functions and data into one PSM1 file'
    Write-Host -ForegroundColor Green '...Complete!'
}


# Synopsis: Lint Code with PSScriptAnalyzer
task Analyze BeforeAnalyze, {
    $scriptAnalyzerParams = @{
        Path = $ModulePath
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        #ExcludeRules = @('PSAvoidGlobalVars')
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalyzerResults.json")

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}, AfterAnalyze

# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
task RunTests {
    write-host "Modulepath: $ModulePath"
    $invokePesterParams = @{
        Script = "..\"
        OutputFile =  (Join-Path $Artifacts "TestResults.xml")
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    # Ensure current module scope is removed.
    # Will be loaded properly by first pester test.
    Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Stop

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    # Save Test Results as JSON
    $testresults | ConvertTo-Json -Depth 5 | Set-Content  (Join-Path $Artifacts "PesterResults.json")

    # Temp: Publish Test Report
    $options = @{
        BuildNumber = $BuildNumber
        GitRepo = $Settings.GitRepo
        GitRepoURL = $Settings.ProjectUrl
        CiURL = $Settings.CiURL
        ShowHitCommands = $true
        Compliance = ($PercentCompliance / 100)
        ScriptAnalyzerFile = (Join-Path $Artifacts "ScriptAnalyzerResults.json")
        PesterFile =  (Join-Path $Artifacts "PesterResults.json")
        OutputDir = "$Artifacts"
    }

    #. ".\PSTestReport\Invoke-PSTestReport.ps1" @options
    . ".\Invoke-PSTestReport.ps1" @options

    # Upload Tests to AppVeyor if running in CI environment

    if ($Env:APPVEYOR) {
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path(Join-Path $Artifacts "TestResults.xml")))
    }
}

task UpdateModuleManifest {
    if ($Env:APPVEYOR) {
        Update-Metadata -Path (Resolve-Path(Join-Path $ModulePath -ChildPath "$ModuleName.psd1")) -PropertyName ModuleVersion -Value "$Env:APPVEYOR_MODULE_VERSION"
        Set-ModuleFunctions -Path (Resolve-Path(Join-Path $ModulePath -ChildPath "$ModuleName.psd1"))
    }
}

# Synopsis: Throws and error if any tests do not pass for CI usage
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path $Artifacts "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path $Artifacts "PesterResults.json") -Raw | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

# Synopsis: Creates Archived Zip and Nuget Artifacts
task Archive BeforeArchive, {
    $moduleInfo = @{
        ModuleName = $ModuleName
        BuildNumber = $BuildNumber
    }

    Publish-ArtifactZip @moduleInfo

    $nuspecInfo = @{
        packageName = $ModuleName
        author =  $Settings.Author
        owners = $Settings.Owners
        licenseUrl = $Settings.LicenseUrl
        projectUrl = $Settings.ProjectUrl
        packageDescription = $Settings.PackageDescription
        tags = $Settings.Tags
        destinationPath = $Artifacts
        BuildNumber = $BuildNumber
    }

    Publish-NugetPackage @nuspecInfo
}, AfterArchive

# Synopsis: Publish to SMB File Share
task Publish BeforePublish, {
    $moduleInfo = @{
        RepoName = $Settings.SMBRepoName
        RepoPath = $Settings.SMBRepoPath
        ModuleName = $ModuleName
        ModulePath = "$ModulePath\$ModuleName.psd1"
        BuildNumber = $BuildNumber
    }

    Publish-SMBModule @moduleInfo -Verbose
}, AfterPublish

task BeforePublish {
    #
}