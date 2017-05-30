$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
}

InModuleScope "ConfigMgr" {
    Describe "public/New-CMConnection" {
        # Ensure global module variables are cleared
        $global:CMProviderServer = ""
        $global:CMSiteCode = ""
        $global:CMNamespace = ""

        Context "No server available" {
            It "Throw an exception if server cannot be contacted" {
                Mock Get-CMSession {}

                { New-CMConnection } | Should Throw
            }
        }
        Context "Server available" {
            Mock Get-CimInstance {
                [PSCustomObject]@{NamespacePath = "\\$ComputerName\root\sms\Site_TST"; Machine = "$($CimSession.ComputerName)"; SiteCode = "TST"}
            }

            Mock Get-CimInstance {
                [PSCustomObject]@{NamespacePath = "\\TestLocalServer\root\sms\Site_TST"; Machine = "TestLocalServer"; SiteCode = "TST"}

            } -ParameterFilter {$CimSession.ComputerName -eq "."}

            Mock Get-CimInstance {
                [PSCustomObject]@{NamespacePath = "\\$ComputerName\root\sms\Site_ZZZ"; Machine = "$($CimSession.ComputerName)"; SiteCode = "ZZZ"}

            } -ParameterFilter {$Filter -like "*SiteCode =*"}

            It "Use local computername if no server name was supplied." {
                New-CMConnection

                $global:CMProviderServer | Should Be "$Env:ComputerName"
            }

            It "Evaluate SiteCode if no SiteCode is supplied." {
                New-CMConnection

                $global:CMSiteCode | Should Be "TST"
            }

            It "Use supplied server name." {
                New-CMConnection -ProviderServerName "localhost"

                $global:CMProviderServer | Should Be "localhost"
            }

            It "Use supplied site code." {
                New-CMConnection -ProviderServerName "localhost" -SiteCode "ZZZ"

                $global:CMSiteCode | Should Be "ZZZ"
            }

            It "Use supplied credentials." {
                $TestCredentials = New-Object System.Management.Automation.PSCredential ("TestUser", (ConvertTo-SecureString "TestPassword"-AsPlainText -Force))

                New-CMConnection -ProviderServerName "localhost" -Credential $TestCredentials

                $global:CMCredential | Should Be $TestCredentials
            }
        }
    }
}
