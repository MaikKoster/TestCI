param (
	[string]$ReleaseNotes = $null
)

if (Test-Path '.\build\.buildenvironment.ps1') {
    . '.\build\.buildenvironment.ps1'
} else {
    Write-Error "Without a build environment file we are at a loss as to what to do!"
}

# You really shouldn't change this for a powershell module (if you want it to publish to the psgallery correctly)
#$CurrentReleaseFolder = $ModuleToBuild

# Put together our full paths. Generally leave these alone
$ScriptRoot = (Resolve-Path -Path ".\").Path
$ModulePath = Join-Path -Path $ScriptRoot -ChildPath $ModuleToBuild
$ModuleFullPath = Join-Path -Path $ModulePath -ChildPath "$ModuleToBuild.psm1"
$ScratchPath = Join-Path -Path $ScriptRoot -ChildPath $ScratchFolder
$ModuleManifestFullPath = Join-Path -Path $ModulePath -ChildPath "$ModuleToBuild.psd1"
$ReleasePath = Join-Path -Path $ScriptRoot -ChildPath $BaseReleaseFolder
$CurrentReleasePath = Join-Path -Path $ReleasePath -ChildPath $ModuleToBuild
$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $ModuleToBuild   # Just before releasing the module we stage some changes in this location.

# Additional build scripts and tools are found here (note that any dot sourced functions must be scoped at the script level)
$BuildToolPath = Join-Path -Path $ScriptRoot -ChildPath $BuildToolFolder

# These are required for a full build process and will be automatically installed if they aren't available
$RequiredModules = @('BuildHelpers', 'PlatyPS', 'PSScriptAnalyzer', 'Pester', 'Coveralls')

# Used later to determine if we are in a configured state or not
$IsConfigured = $False

# Used to update our function CBH to external help reference
$ExternalHelp = @"
<#
    .EXTERNALHELP $($ModuleToBuild)-help.xml
    #>
"@

#Synopsis: Validate system requirements are met
task ValidateRequirements {
    Write-Host -NoNewLine '      Running Powershell version 5?'
    assert ($PSVersionTable.PSVersion.Major.ToString() -eq '5') 'Powershell 5 is required for this build to function properly (you can comment this assert out if you are able to work around this requirement)'
    Write-Host -ForegroundColor Green '...Yup!'
}

#Synopsis: Load required modules if available. Otherwise try to install, then load it.
task LoadRequiredModules {
    $RequiredModules | Foreach {
        if ($null -eq (get-module $_ -ListAvailable)) {
            Write-Host -NoNewLine "      Installing $($_) Module"
            $null = Install-Module $_ -Force
            Write-Host -ForegroundColor Green '...Installed!'
        }
        if (get-module $_ -ListAvailable) {
            Write-Host -NoNewLine "      Importing $($_) Module"
            Import-Module $_ -Force
            Write-Host -ForegroundColor Green '...Loaded!'
        }
        else {
            throw 'How did you even get here?'
        }
    }
}

#Synopsis: Load dot sourced functions into this build session
task LoadBuildTools {
    # Dot source any build script functions we need to use
    Get-ChildItem $BuildToolPath/dotSource -Recurse -Filter "*.ps1" -File | Foreach {
        Write-Output "      Dot sourcing script file: $($_.Name)"
        . $_.FullName
    }
}

# Synopsis: Import the current module manifest file for processing
task LoadModuleManifest {
    assert (test-path $ModuleManifestFullPath) "Unable to locate the module manifest file: $ModuleManifestFullPath"

    Write-Host -NoNewLine '      Loading the existing module manifest for this module'
    $Script:Manifest = Import-PowerShellDataFile -Path $ModuleManifestFullPath

    # Validate we have a rootmodule defined
    if(-not $Script:Manifest.RootModule) {
        $Script:Manifest.RootModule = $Manifest.ModuleToProcess
        # If we don't then name it after the module to build
        if(-not $Script:Manifest.RootModule) {
            $Script:Manifest.RootModule = "$ModuleToBuild.psm1"
        }
    }

    # Store this for later
    $Script:ReleaseModule = Join-Path $StageReleasePath $Script:Manifest.RootModule
    Write-Host -ForegroundColor Green '...Loaded!'
}

# Synopsis: Create new module manifest
task CreateModuleManifest -After CreateModulePSM1 {
    Write-Host -NoNewLine '      Attempting to create a new module manifest file at .'
    $Script:Manifest.ModuleVersion = $Script:Version
    $Script:Manifest.FunctionsToExport = $Script:FunctionsToExport
    $Script:Manifest.CmdletsToExport = $Script:Module.ExportedCmdlets.Keys
    $Script:Manifest.VariablesToExport = $Script:Module.ExportedVariables.Keys
    $Script:Manifest.AliasesToExport = $Script:Module.ExportedAliases.Keys
    $Script:Manifest.WorkflowsToExport = $Script:Module.ExportedWorkflows.Keys
    $Script:Manifest.DscResourcesToExport = $Script:Module.ExportedDscResources.Keys
    $Script:Manifest.FormatFilesToExport = $Script:Module.ExportedFormatFiles.Keys
    $Script:Manifest.TypeFilesToExport = $Script:Module.ExportedTypeFiles.Keys

    # Update the private data element so it will work properly with new-modulemanifest
    $tempPSData = $Script:Manifest.PrivateData.PSdata

    if ( $tempPSData.Keys -contains 'Tags') {
        $tempPSData.Tags = @($tempPSData.Tags | Foreach {$_})
    }
    $NewPrivateDataString = "PrivateData = @{`r`n"
    $NewPrivateDataString += '  PSData = '
    $NewPrivateDataString += (Convert-HashToString $tempPSData)
    $NewPrivateDataString +=  "`r`n}"

    # We do this because private data never seems to give the results I want in the manifest file
    # Later we replace the whole string in the manifest with what we want.
    $Script:Manifest.PrivateData = ''

    # Remove some hash elements which cannot be passed to new-modulemanifest
    if ($Script:Manifest.Keys -contains 'TypeFilesToExport') {
        $Script:Manifest.Remove('TypeFilesToExport')
    }

    if ($Script:Manifest.Keys -contains 'WorkflowsToExport') {
        $Script:Manifest.Remove('WorkflowsToExport')
    }

    if ($Script:Manifest.Keys -contains 'FormatFilesToExport') {
        $Script:Manifest.Remove('FormatFilesToExport')
    }

    $MyManifest = $Script:Manifest
    New-ModuleManifest @MyManifest -Path $StageReleasePath\$ModuleToBuild.psd1

    # Replace the whole private data section with our own string instead
    Replace-FileString -Pattern "PrivateData = ''"  $NewPrivateDataString $StageReleasePath\$ModuleToBuild.psd1 -Overwrite -Encoding 'UTF8'
}

# Synopsis: Load the module project
task LoadModule {
    Write-Host -NoNewLine '      Attempting to load the project module.'
    try {
        $Script:Module = Import-Module $ModuleManifestFullPath -Force -PassThru
        Write-Host -ForegroundColor Green '...Loaded!'
    } catch {
        throw "Unable to load the project module: $($ModuleFullPath)"
    }
}

# Synopsis: Update current module manifest with the version
task Version LoadModuleManifest, {
    # Major/Minor changes are handled manually by updating the appveyor.yml file
    # Build version changes are enforced by CI system (AppVeyor)
    # Build version will only increment on successfull builds
    # Build version will be reset to 0 on major/minor change

    if ($Env:APPVEYOR) {
        # Prepare REST call
        $apiUrl = 'https://ci.appveyor.com/api'
        $token = "$Env:AppVeyorKey"
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-type" = "application/json"
            "Accept" = "application/json"
        }
        $accountName = $env:APPVEYOR_ACCOUNT_NAME
        $projectSlug = $env:APPVEYOR_PROJECT_SLUG
        $buildNumber = $env:APPVEYOR_BUILD_NUMBER
        $buildVersionText = $env:APPVEYOR_BUILD_VERSION
        $buildVersion = New-Object -TypeName PSObject -Property (@{
            'MajorVersion'=$buildVersionText.Split('.')[0];
            'MinorVersion'=$buildVersionText.Split('.')[1];
            'BuildVersion'=$buildVersionText.Split('.')[2]
        })

        # Get list of builds
        $response = Invoke-RestMethod -Method Get -Uri "$apiUrl/projects/$accountName/$projectSlug/history?recordsNumber=100" -Headers $headers

        # Get last successfull(!) build version
        $lastBuildVersion = $response.builds | Where-Object {$_.status -eq "success"} | Select-Object -First 1 @{Label="MajorVersion"; Expression={$_.version.Split('.')[0]}}, @{Label="MinorVersion"; Expression={$_.version.Split('.')[1]}}, @{Label="BuildVersion"; Expression={$_.version.Split('.')[2]}}

        if ($lastBuildVersion.MajorVersion -ne $buildVersion.MajorVersion -or (($lastBuildVersion.MajorVersion -eq $buildVersion.MajorVersion) -and ($lastBuildVersion.MinorVersion -ne $buildVersion.MinorVersion))) {
            # Reset Buildversion on Major/Minor change
            $build = @{
                nextBuildNumber = 0
            }
            $json = $build | ConvertTo-Json

            Invoke-RestMethod -Method Put "$apiUrl/projects/$accountName/$projectSlug/settings/build-number" -Body $json -Headers $headers

            # Update current version
            $Script:Version = "$($buildVersion.MajorVersion).$($buildVersion.MinorVersion).0"
        } elseif ($lastBuildVersion.buildVersion -ne ($buildNumber + 1)) {
            # Change Build version if it got incremented on a failed build
            $build = @{
                nextBuildNumber = ($lastBuildVersion.buildVersion + 2)
            }
            $json = $build | ConvertTo-Json

            Invoke-RestMethod -Method Put "$apiUrl/projects/$accountName/$projectSlug/settings/build-number" -Body $json -Headers $headers

            $Script:Version = "$($buildVersion.MajorVersion).$($buildVersion.MinorVersion).$($lastBuildVersion.buildVersion + 1)"
        } else {
            $Script:Version = $buildVersionText
        }

        # Update AppVeyor environment
        $env:APPVEYOR_BUILD_VERSION = $Script:Version
    } else {
        # Get current version from manifest file
        $Script:Version = $Script:Manifest.ModuleVersion
    }

    # Beyond this step, $Script:Version should be the referenced version

    Write-Host -NoNewline "      Updating Version"
    Write-Host -ForegroundColor Green '...Completed!'

}, UpdateModuleManifest, UpdateReadMe

# Synopsis: Updates the Module manifest version
task UpdateModuleManifest {
    # Update Modulemanifest
    if ($Manifest.ModuleVersion -ne $Script:Version) {
        Write-Host -NoNewline "      Attempting to update the module manifest version ($($Manifest.ModuleVersion)) to $(($Script:Version).ToString())"
        Update-Metadata -Path $ModuleManifestFullPath -PropertyName ModuleVersion -Value $Script:Version
        Write-Host -ForegroundColor Green '...Updated!'
    }
}

# Synposis. Updates the download link in the ReadMe file
task UpdateReadMe {
    $ReadMePath = Join-Path -Path $ScriptRoot -ChildPath "README.md"
    Write-Host $ReadMePath
    if (Test-Path ($ReadMePath)) {
        $ReadMe = Get-Content -Path $ReadMePath -Raw

        $NewDownloadLink = "$ModuleWebsite/releases/download/v$Script:Version/$ModuleToBuild.zip"

        $ReadMe -replace "$ModuleWebsite.+$ModuleToBuild.zip", $NewDownloadLink | Set-Content -Path $ReadMePath -Force -Encoding UTF8

        Write-Host -NoNewLine "      Updating download link in README.md"
        Write-Host -ForeGroundColor green '...Complete!'
    }
}


#Synopsis: Validate script requirements are met, load required modules, load project manifest and module, and load additional build tools.
task Configure ValidateRequirements, LoadRequiredModules, LoadBuildTools, LoadModuleManifest, LoadModule, Version, Clean, {
    # If we made it this far then we are configured!
    $Script:IsConfigured = $True
    Write-Host -NoNewline '      Configure build environment'
    Write-Host -ForegroundColor Green '...configured!'
}

# Synopsis: Remove/regenerate scratch staging directory
task Clean {
    Write-Host -NoNewLine "      Clean up our scratch/staging directory at $($ScratchPath)"
    if(Test-Path -Path $ScratchPath) {
        $null = Remove-Item "$ScratchPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    $null = New-Item -ItemType Directory -Path $ScratchPath -Force

    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Create base content tree in scratch staging area
task PrepareStage {
    # Create the directories
    $null = New-Item $StageReleasePath -ItemType:Directory -Force

    Copy-Item -Path $ModuleFullPath -Destination $ScratchPath
    Copy-Item -Path $ModuleManifestFullPath -Destination $ScratchPath
    Copy-Item -Path "$($ModulePath)\$($PublicFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PublicFunctionSource)"
    Copy-Item -Path "$($ModulePath)\$($PrivateFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PrivateFunctionSource)"
    if (Test-Path "$($ModulePath)\$($OtherModuleSource)") {
        Copy-Item -Path "$($ModulePath)\$($OtherModuleSource)" -Recurse -Destination "$($ScratchPath)\$($OtherModuleSource)"
    }

    if (Test-Path "$($ModulePath)\en-US") {
        Copy-Item -Path "$($ModulePath)\en-US" -Recurse -Destination $StageReleasePath
    } else {
        $null = New-Item "$ScratchPath\en-US" -ItemType:Directory -Force
    }
    Copy-Item -Path "$ScriptRoot\README.md" -Destination $StageReleasePath
    Copy-Item -Path "$ScriptRoot\LICENSE" -Destination $StageReleasePath
}, GetPublicFunctions

# Synopsis:  Collect a list of our public methods for later module manifest updates
task GetPublicFunctions {
    $Exported = @()
    Get-ChildItem "$($ModulePath)\$($PublicFunctionSource)" -Recurse -Filter "*.ps1" -File | Sort-Object Name | Foreach {
       $Exported += ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach {$_.Name}
    }

    # $Script:FunctionsToExport = (Get-ChildItem -Path $ScriptRoot\$($PublicFunctionSource)).BaseName | foreach {$_.ToString()}
    $Script:FunctionsToExport = $Exported
    Write-Host -NoNewLine '      Parsing for public (exported) function names'
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Assemble the module for release
task CreateModulePSM1 {
    $CombineFiles = ""
    # Have the License on top
    $LicensePath = Join-Path -Path $ScriptRoot -ChildPath "LICENSE"
    If (Test-Path($LicensePath)) {
        $CombineFiles += (Get-Content -Path "$LicensePath" -Raw) + "`r`n`r`n"
        Write-Host -NoNewLine "      Adding License"
        Write-Host -ForegroundColor Green '...Complete!'
    }

    $PublicPath = Join-Path -Path $ScratchPath -ChildPath $PublicFunctionSource
    if (Test-Path -Path $PublicPath) {
        $CombineFiles += "#region Public module functions and data `r`n`r`n"
        Write-Host  "      Public Source Files: $PublicPath"
        Get-childitem  "$PublicPath\*.ps1" | foreach {
            Write-Host "             $($_.Name)"
            $CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
        Write-Host -NoNewline "      Combining public source files"
        Write-Host -ForegroundColor Green '...Complete!'
    }

    # "Other" files might not always exist
    $OtherPath = Join-Path -Path $ScratchPath -ChildPath $OtherModuleSource
    if (Test-Path -Path $OtherPath) {
        $CombineFiles += "#region Other Module functions and data `r`n`r`n"
        Write-Host "      Other Source Files: $($OtherPath)"
        Get-Childitem -Path"$OtherPath\*.ps1" | foreach {
            Write-Host "             $($_.Name)"
            $CombineFiles += (Get-content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
        Write-Host -NoNewLine "      Combining other source files"
        Write-Host -ForegroundColor Green '...Complete!'
    } else {
        $CombineFiles = ""
    }

    $PrivatePath = Join-Path -Path $ScratchPath -ChildPath $PrivateFunctionSource
    if (Test-Path -Path $PrivatePath) {
        $CombineFiles += "#region Private Module functions and data`r`n`r`n"
        Write-Host  "      Private Source Files: $PrivatePath"
        Get-childitem  "$PrivatePath\*.ps1" | foreach {
            Write-Host "             $($_.Name)"
            $CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
        Write-Host -NoNewLine "      Combining private source files"
        Write-Host -ForegroundColor Green '...Complete!'
    }

    Set-Content -Path (Join-Path -Path $StageReleasePath -ChildPath "$ModuleToBuild.psm1") -Value $CombineFiles -Encoding UTF8
    Write-Host -NoNewLine '      Combining module functions and data into one PSM1 file'
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Warn about not empty git status if .git exists.
task GitStatus -If (Test-Path .git) {
	$status = exec { git status -s }
	if ($status) {
		Write-Warning "      Git status: $($status -join ', ')"
	}
}

# Synopsis: Replace comment based help with external help in all public functions for this project
task UpdateCBH -Before CreateModulePSM1 {
    $CBHPattern = "(?ms)(\<#.*\.SYNOPSIS.*?#>)"
    Get-ChildItem -Path "$($ScratchPath)\$($PublicFunctionSource)\*.ps1" -File | ForEach {
            $FormattedOutFile = $_.FullName
            Write-Output "      Replacing CBH in file: $($FormattedOutFile)"
            $UpdatedFile = (Get-Content  $FormattedOutFile -raw) -Replace $CBHPattern, $ExternalHelp
            $UpdatedFile | Out-File -FilePath $FormattedOutFile -Force -Encoding:utf8
    }
}

# Synopsis: Run PSScriptAnalyzer against the assembled module
task AnalyzeScript -After CreateModulePSM1 {
    $scriptAnalyzerParams = @{
        Path = $StageReleasePath
        Severity = @('Error', 'Warning', 'Information')
        Recurse = $true
        Verbose = $false
        #ExcludeRules = @('PSAvoidGlobalVars')
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResults | ConvertTo-Json | Set-Content (Join-Path -Path $ScratchPath -ChildPath "ScriptAnalyzerResults.json")
    Write-Host (Join-Path -Path $ScratchPath -ChildPath "ScriptAnalyzerResults.json")
    Write-Host -NoNewLine '      Analyzing script module'
    Write-Host -ForegroundColor Green '...Complete!'
    #if ($saResults) {
    #    $saResults | Format-Table
    #    throw "One or more PSScriptAnalyzer errors/warnings where found."
    #}

    #$Analysis = Invoke-ScriptAnalyzer -Path $StageReleasePath
    $saErrors = @($saResults | Where-Object {@('Information','Warning') -notcontains $_.Severity})
    #Write-Host -NoNewLine '      Analyzing script module'
    #Write-Host -ForegroundColor Green '...Complete!'
    if ($saErrors.Count -ne 0) {
        throw 'Script Analysis came up with some errors!'
    }

    $saWarnings = @($saResults | Where-Object {$_.Severity -eq 'Warning'})
    $saInfo =  @($saResults | Where-Object {$_.Severity -eq 'Information'})
    Write-Host -ForegroundColor Yellow "          Script Analysis Warnings = $($saWarnings.Count)"
    Write-Host "          Script Analysis Informational = $($saInfo.Count)"
}

# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
# Tests are executed against the source files to get proper Code coverage metrics.
task RunTests {
    $invokePesterParams = @{
        Script = (Join-Path -Path $ScriptRoot -ChildPath "tests")
        OutputFile =  (Join-Path -Path $ScratchPath -ChildPath "TestResults.xml")
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    # Ensure current module scope is removed.
    # Will be loaded properly by first pester test.
    Get-Module -Name $ModuleToBuild -All | Remove-Module -Force -ErrorAction Stop

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    # Save Test Results as JSON
    $testresults | ConvertTo-Json -Depth 5 | Set-Content  (Join-Path -Path $ScratchPath -ChildPath "PesterResults.json")

    # Upload Tests to AppVeyor if running in CI environment

    Write-Host -NoNewLine '      Running Tests'
    Write-Host -ForegroundColor Green '...Complete!'

    if ($Env:APPVEYOR) {
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path(Join-Path $ScratchPath "TestResults.xml")))

        Write-Host -NoNewLine '      Uploading Testresults to AppVeyor'
        Write-Host -ForegroundColor Green '...Complete!'

        $CurrentBranch = $Env:APPVEYOR_REPO_BRANCH

        # Upload Code Coverage to Coverall
        if (-not([string]::IsNullOrEmpty($Env:CoverallKey))) {
            Write-Host "Coverage"
            $Coverage = Format-Coverage -PesterResults $testResults -CoverallsApiToken "$Env:CoverallKey"  -BranchName $CurrentBranch -Verbose
            Publish-Coverage $Coverage -Verbose

            Write-Host -NoNewLine '      Uploading CodeCoverage to Coverall'
            Write-Host -ForegroundColor Green '...Complete!'
        }
    }
}

# Synopsis: Throws an error if any tests do not pass for CI usage
task ConfirmTestsPassed -After RunTests {
    Write-Host -NoNewLine '      Confirming Test results'
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path -Path $ScratchPath -ChildPath "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path -Path $ScratchPath -ChildPath "PesterResults.json") -Raw | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)

    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Build help files for module
task CreateHelp CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Host -NoNewLine '      Create help files'
    Write-Host -ForegroundColor Green '...Complete!'
}

task UpdateHelp UpdateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Host -NoNewLine '      Updating help files'
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Build help files for module and ignore missing section errors
task TestCreateHelp Configure, CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB,  {
    Write-Host -NoNewLine '      Create help files'
    Write-Host -ForegroundColor Green '...Complete!'
}

task TestUpdateHelp Configure, UpdateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Host -NoNewLine '      Updating help files'
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Build the markdown help files with PlatyPS
task UpdateMarkdownHelp {
    # Create the .md files and the generic module page md as well
    $DocRoot = Join-Path -Path $ScriptRoot -ChildPath "docs"
    $null = Update-MarkdownHelpModule -Path $DocRoot -RefreshModulePage

    # Replace each missing element we need for a proper generic module page .md file
    $ModulePage = Join-Path -Path $DocRoot -ChildPath "$ModuleToBuild.md"
    $ModulePageFileContent = Get-Content -Raw $ModulePage
    $ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $Script:Manifest.Description

    # Function Description should have been updated by PlatyPS
    $ModulePageFileContent | Out-File $ModulePage -Force -Encoding:utf8

    $MissingDocumentation = Select-String -Path "$DocRoot\*.md" -Pattern "({{.*}})"
    if ($MissingDocumentation.Count -gt 0) {
        Write-Host -ForegroundColor Yellow ''
        Write-Host -ForegroundColor Yellow '   The documentation that got generated resulted in missing sections which should be filled out.'
        Write-Host -ForegroundColor Yellow '   Please review the following sections in your comment based help, fill out missing information and rerun this build:'
        Write-Host -ForegroundColor Yellow '   (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
        Write-Host ''
        Write-Host -ForegroundColor Yellow "Path of files with issues: $DocRoot\docs\"
        Write-Host ''
        $MissingDocumentation | Select FileName,Matches | ft -auto
        Write-Host -ForegroundColor Yellow ''
        #pause

       # throw 'Missing documentation. Please review and rebuild.'
    }

    Write-Host -NoNewLine '      Updating markdown documentation with PlatyPS'
    Write-Host -ForegroundColor Green '...Complete!'
}

task CreateMarkdownHelp GetPublicFunctions, {
    $DocRoot = Join-Path -Path $ScriptRoot -ChildPath "docs"
    $OnlineModuleLocation = "$($ModuleWebsite)/$($BaseReleaseFolder)/blob/master"
    $FwLink = "$($OnlineModuleLocation)/docs/$($ModuleToBuild).md"
    $ModulePage = Join-Path -Path $DocRoot -ChildPath "$ModuleToBuild.md"

    # Create the .md files and the generic module page md as well
    $null = New-MarkdownHelp -Module $ModuleToBuild -OutputFolder $DocRoot -Force -WithModulePage -Locale 'en-US' -FwLink $FwLink -HelpVersion $Script:Version

    # Replace each missing element we need for a proper generic module page .md file
    $ModulePageFileContent = Get-Content -Raw $ModulePage
    $ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $Script:Manifest.Description
    $Script:FunctionsToExport | Foreach-Object {
        Write-Host "      Updating definition for the following function: $($_)"
        $TextToReplace = "{{Manually Enter $($_) Description Here}}"
        $ReplacementText = (Get-Help -Detailed $_).Synopsis
        $ModulePageFileContent = $ModulePageFileContent -replace $TextToReplace, $ReplacementText
    }
    $ModulePageFileContent | Out-File $ModulePage -Force -Encoding:utf8

    $MissingDocumentation = Select-String -Path "$($DocRoot)\*.md" -Pattern "({{.*}})"
    if ($MissingDocumentation.Count -gt 0) {
        Write-Host -ForegroundColor Yellow ''
        Write-Host -ForegroundColor Yellow '   The documentation that got generated resulted in missing sections which should be filled out.'
        Write-Host -ForegroundColor Yellow '   Please review the following sections in your comment based help, fill out missing information and rerun this build:'
        Write-Host -ForegroundColor Yellow '   (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
        Write-Host ''
        Write-Host -ForegroundColor Yellow "Path of files with issues: $($DocRoot)\"
        Write-Host ''
        $MissingDocumentation | Select FileName,Matches | ft -auto
        Write-Host -ForegroundColor Yellow ''
        #pause

       # throw 'Missing documentation. Please review and rebuild.'
    }

    Write-Host -NoNewLine '      Creating markdown documentation with PlatyPS'
    Write-Host -ForegroundColor Green '...Complete!'
}

# Synopsis: Build the external help files with PlatyPS
task CreateExternalHelp {
    $null = New-ExternalHelp "$($ScriptRoot)\docs" -OutputPath "$($ModulePath)\en-US\" -Force
    Write-Host -NoNewLine '      Creating markdown help files'
    Write-Host -ForeGroundColor green '...Complete!'
}

# Synopsis: Build the help file CAB with PlatyPS
task CreateUpdateableHelpCAB {
    Start-Sleep -Seconds 1
    $LandingPage = "$($ScriptRoot)\docs\$($ModuleToBuild).md"
    $null = New-ExternalHelpCab -CabFilesFolder "$($ModulePath)\en-US\" -LandingPagePath $LandingPage -OutputFolder "$($ModulePath)\en-US\"
    Write-Host -NoNewLine "      Creating updateable help cab file"
    Write-Host -ForeGroundColor green '...Complete!'
}


# task PushHelpFiles {
#     $DocRoot = Join-Path -Path $ScriptRoot -ChildPath "docs"

#     $null = Remove-Item -Path $DocRoot -Force -Recurse -ErrorAction SilentlyContinue
#     $null = New-Item -Path $DocRoot -ItemType:Directory
#     Copy-Item -Path "$($StageReleasePath)\docs\*" -Destination $DocRoot -Recurse
#     Write-Host -NoNewLine "      Updating documentation at $($DocRoot)"
#     Write-Host -ForeGroundColor green '...Complete!'
# }

# Synopsis: Push with a version tag.
task GitHubPushRelease Version, {
	#$changes = exec { git status --short }
	#assert (-not $changes) "Please, commit changes."

	#exec { git push }
	#exec { git tag -a "v$($Script:Version)" -m "v$($Script:Version)" }
	#exec { git push origin "v$($Script:Version)" }

    #if ($ENV:APPVEYOR_REPO_BRANCH -eq 'master' -and [string]::IsNullOrWhiteSpace($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {
        #Create GitHub release
        Write-Host 'Starting GitHub release'
        $releaseData = @{
            tag_name         = "v$ENV:APPVEYOR_BUILD_VERSION"
            target_commitish = 'master'
            name             = "v$ENV:APPVEYOR_BUILD_VERSION"
            draft            = $true
            prerelease       = $false
        }

        $auth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($env:GitHubKey + ':x-oauth-basic'))
        $releaseParams = @{
            Uri         = "$ModuleWebsite/releases"
            Method      = 'POST'
            Headers     = @{
                Authorization = $auth
            }
            ContentType = 'application/json'
            Body        = (ConvertTo-Json -InputObject $releaseData -Compress)
        }

        $result = Invoke-RestMethod @releaseParams
        $uploadUri = $result | Select-Object -ExpandProperty upload_url
        $uploadUri = $uploadUri -creplace '\{\?name,label\}'  #, '?name=coveralls.zip'
        $uploadUri = $uploadUri + "?name=$ModuleToBuild-$Script:Version.zip"

        $uploadParams = @{
            Uri         = $uploadUri
            Method      = 'POST'
            Headers     = @{
                Authorization = $auth
            }
            ContentType = 'application/zip'
            InFile      = "$ScratchPath\$ModuleToBuild-$Script:Version.zip"
        }

        $result = Invoke-RestMethod @uploadParams
        Write-Host -NoNewLine "      Creating GitHub release"
        Write-Host -ForeGroundColor green '...Complete!'
    #}
}

# Synopsis: Commit changes and push to github
task GithubPush GetReleaseNotes, {
    exec { git checkout master }
    exec { git add --all }
    exec { git status }
    if (-not([string]::IsNullOrEmpty($Script:ReleaseNotes))) {
        exec { git commit -s -m "$Script:ReleaseNotes"}
    } else {
        exec { git commit -s -m "v$($Script:Version)"}
    }
    exec { git push origin master }
	$changes = exec { git status --short }
	assert (-not $changes) "Please, commit changes."
}

# Synopsis: Push the project to PSScriptGallery
task PublishToPSGallery GetReleaseNotes, {
    if (-not([string]::IsNullOrEmpty("$Env:PSGalleryKey"))) {
        # Prepare Publis-Module parameters
        $PSGalleryParams = @{
            NuGetApiKey = "$Env:PSGalleryKey"
            Path = "$CurrentReleasePath"
            Repository = "PSGallery"
            ReleaseNotes = $Script:ReleaseNotes
        }

        Publish-Module @PSGalleryParams
        Write-Host -NoNewLine "      Uploading project to PSGallery"
        Write-Host -ForeGroundColor green '...Complete!'
    }
}

# Synopsis: Push the project to PSScriptGallery
task PublishToMyGet GetReleaseNotes, {
    if (-not([string]::IsNullOrEmpty("$Env:MyGetKey"))) {
        # Prepare Publis-Module parameters
        $MyGetParams = @{
            NuGetApiKey = "$Env:MyGetKey"
            Path = "$CurrentReleasePath"
            Repository = "MyGet"
            ReleaseNotes = $Script:ReleaseNotes
        }

        Publish-Module @MyGetParams
        Write-Host -NoNewLine "      Uploading project to MyGet"
        Write-Host -ForeGroundColor green '...Complete!'
    }
}

# Synopsis: Extracts the current Releasenotes from the ChangeLog
task GetReleaseNotes Version, {
    # Get Version release notes from Changelog
    $ChangeLogPath = Join-Path -Path $ScriptRoot -ChildPath "CHANGELOG.md"

    if (Test-Path $ChangeLogPath) {
        $VersionReleaseNotes = Get-Content -Path $ChangeLogPath |
                                Where-Object {
                                    $line = $_
                                    if( -not $foundVersion ) {
                                        if( $line -match ('^##\s+\[{0}\]' -f [regex]::Escape($Script:version)) ) {
                                            $foundVersion = $true
                                            return
                                        }
                                    } else {
                                        if( $line -match ('^##\s+\[(?!{0})' -f [regex]::Escape($Script:version)) ) {
                                            $foundVersion = $false
                                        }
                                    }

                                    return( $foundVersion )
                                }
    }

    if($VersionReleaseNotes ) {
        $Script:ReleaseNotes =  ($VersionReleaseNotes -join [Environment]::NewLine)
    }

    Write-Host -NoNewLine "      Extracting Release Notes from CHANGELOG.md"
    Write-Host -ForeGroundColor green '...Complete!'
}

# Synopsis: Prepare artifacts for AppVeyor
task PrepareArtifacts Version, {
    # Compress current Release
    $ZippedReleasePath = Join-Path -Path $ScratchPath -ChildPath "$ModuleToBuild-$Script:Version.zip"

    if (Test-Path -Path $CurrentReleasePath) {
        Compress-Archive -Path $CurrentReleasePath -DestinationPath $ZippedReleasePath

        # if ($Env:APPVEYOR) {
        #     Push-AppveyorArtifact $ZippedReleasePath -File (Split-Path -Path $ZippedReleasePath -Leaf )
        #     if (Test-Path -Path "$ScratchPath\ScriptAnalyzer.json") {
        #         Push-AppveyorArtifact "$ScratchPath\ScriptAnalyzer.json"
        #     }
        #     if (Test-Path -Path "$ScratchPath\PesterResults.json") {
        #         Push-AppveyorArtifact "$ScratchPath\PesterResults.json"
        #     }

        #     Write-Host -NoNewLine "      Publishing artificats to AppVeyor"
        #     Write-Host -ForeGroundColor green '...Complete!'
        # }
    }
}

# Synopsis: Remove session artifacts like loaded modules and variables
task BuildSessionCleanup {
    # Clean up loaded modules if they are loaded
    $RequiredModules | Foreach {
        Write-Output "      Removing $($_) module (if loaded)."
        Remove-Module $_  -Erroraction Ignore
    }
    Write-Output "      Removing $ModuleToBuild module  (if loaded)."
    Remove-Module $ModuleToBuild -Erroraction Ignore
}

# Synopsis: The default build
task . `
        Configure,
	    RunTests,
        PrepareStage,
        FormatCode,
        CreateHelp,
        CreateModulePSM1,
        PushVersionRelease,
        PushCurrentRelease,
        BuildSessionCleanup

task Build `
        Configure,
        CreateHelp,
        RunTests,
        PrepareStage,
        CreateModulePSM1,
        PublishArtifacts,
        BuildSessionCleanup

# Synopsis: Build module without combining source files
task BuildWithoutCombiningSource `
        Configure,
	    CreateHelp,
        RunTests,
        PrepareStage,
        CopyModulePSM1,
        PublishArtifacts