$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psm1") -Force
}

InModuleScope "ConfigMgr" {
    Describe "public/Write-Log" {
        It "Write to log file at standard location" {
            $LogFile = "$Env:TEMP\Write-Log.log"
            Write-log -Message "Create log file at temp location."
            (Test-Path -Path $LogFile) |Should be $true

            # Clean up manually as
            Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
        }

        It "Write to log file at specified location" {
            $LogFile = "TestDrive:\Test.log"
            Write-log -Message "Create log file at specified location." -Path $LogFile
            (Test-Path -Path $LogFile) | Should be $true
        }

        It "Use specified severity" {
            $LogFile = "TestDrive:\TestSeverity.log"
            (Write-Log "Test Info" -Path $LogFile -PassThru -Severity Info -Verbose 4>&1) -match "Test Info" | Should Be $true
            (Get-Content $LogFile -Tail 1) -like "*Test Info*type=`"1`"*" | Should Be $true
            (Write-Log "Test Warning" -Path $LogFile -PassThru -Severity Warning 3>&1) -match "Test Warning" | Should Be $true
            (Get-Content $LogFile -Tail 1) -like "*Test Warning*type=`"2`"*" | Should Be $true
            (Write-Log "Test Error" -Path $LogFile -PassThru -Severity Error 2>&1) -match "Test Error" | Should Be $true
            (Get-Content $LogFile -Tail 1) -like "*Test Error*type=`"3`"*" | Should Be $true
        }

        It "Write plain text" {
            $LogFile = "TestDrive:\TestPlain.log"
            Write-Log "Test Plaintext" -Path $LogFile -AsPlainText
            (Get-Content $LogFile -Tail 1) -like "*INFO* - Test Plaintext" | Should Be $true
             Write-Log "Test Plaintext2" -Path $LogFile -AsPlainText -Severity Warning
            (Get-Content $LogFile -Tail 1) -like "*WARNING* - Test Plaintext2" | Should Be $true
             Write-Log "Test Plaintext3" -Path $LogFile -AsPlainText -Severity Error
            (Get-Content $LogFile -Tail 1) -like "*ERROR* - Test Plaintext3" | Should Be $true
        }
    }
}