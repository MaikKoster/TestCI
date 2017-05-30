$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    Describe "public/Get-CMInstance" {
        Context "No connection" {
            Mock Get-CimInstance {throw}

            It "Throw if no connection has been established" {
                {Get-CMInstance -Class "TestMe"} | Should Throw
            }
        }

        Context "Connection established" {
            Get-CimSession | Remove-CimSession
            $global:CMProviderServer = "TestProviderServer"
            $global:CMSiteCode = "TST"
            $global:CMNamespace = "root\sms\Site_TST"
            $global:CMSession = New-CimSession $env:COMPUTERNAME
            $global:CMCredential = [System.Management.Automation.PSCredential]::Empty

            Mock Get-CimInstance {
                [PSCustomObject]@{ClassName = $ClassName; Filter = $Filter; Namespace = $Namespace; ComputerName = $($CimSession.ComputerName)}
            }

            Mock Get-WmiObject {
                [PSCustomObject]@{ClassName = $Class; Filter = $Filter; Namespace = $Namespace; ComputerName = $($CimSession.ComputerName); Credential = $Credential}
            }

            It "Throw if no class is supplied" {
                {Get-CMInstance -ClassName ""} | Should Throw
                {Get-CMInstance -ClassName $null} | Should Throw
            }

            It "Use Provider connection" {
                Get-CMInstance -ClassName "TestClass" | select -ExpandProperty "Namespace" | Should Be "root\sms\site_TST"
                Get-CMInstance -ClassName "TestClass" | select -ExpandProperty "ComputerName" | Should Be "$Env:ComputerName"
            }

            It "Get All instances" {
                $TestInstance = Get-CMInstance -ClassName "TestClass"

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be ""
            }

            It "Get All instances by pipelined Classname" {
                $TestInstance = "TestClass" | Get-CMInstance

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be ""
            }

            It "Get All instances and include lazy properties" {
                Assert-MockCalled Get-CimInstance -Times 3
                $TestInstance = Get-CMInstance -ClassName "TestClass" -IncludeLazy

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be ""
                Assert-MockCalled Get-CimInstance -Times 5
            }

            It "Filter instances" {
                $TestInstance = Get-CMInstance -ClassName "TestClass" -Filter "Name = 'TestFilter'"

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be "Name = 'TestFilter'"
            }

            It "Fall back to Get-WMIObject on 'Join' filters" {
                $TestInstance = Get-CMInstance -ClassName "TestClass" -Filter "Name = 'TestFilter with JOIN '"

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be "Name = 'TestFilter with JOIN '"
                $TestInstance | Select-Object -ExpandProperty "Credential" | Select-Object -ExpandProperty "UserName" | Should Be $null
            }

            It "Fall back to Get-WMIObject on 'Join' filters using different credentials" {
                $global:CMCredential = New-Object System.Management.Automation.PSCredential("TestUser", (ConvertTo-SecureString "TestPassword" -AsPlainText -Force))
                $TestInstance = Get-CMInstance -ClassName "TestClass" -Filter "Name = 'TestFilter with JOIN '"

                $TestInstance | Select-Object -ExpandProperty "ClassName" | Should Be "TestClass"
                $TestInstance | Select-Object -ExpandProperty "Filter" | Should Be "Name = 'TestFilter with JOIN '"
                $TestInstance | Select-Object -ExpandProperty "Credential" | Select-Object -ExpandProperty "UserName" | Should Be "TestUser"
            }
        }
    }
}