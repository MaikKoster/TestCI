$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
}


InModuleScope "ConfigMgr" {
    Describe "public/Test-CMConnection" {
        $global:CMProviderServer = ""
        $global:CMSiteCode = ""
        $global:CMNamespace = ""

        It "Throw if connection cannot be created" {
            Mock New-CMConnection { Throw }

            {Test-CMConnection}  | Should Throw
        }

        It "Connect to local Site Server" {
            Mock New-CMConnection {}
            Test-CMConnection | Should Be $true
        }

        It "Return $true if valid connection is available" {
            $global:CMProviderServer = "Testserver"
            $global:CMSiteCode = "TST"
            $global:CMNamespace = "root\sms\Site_TST"
            $global:CMSession = @{Test = "Test"}
            Test-CMConnection | Should Be $true
        }
    }
}