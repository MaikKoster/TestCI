$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    Describe "public/Set-CMInstance" {
        Context "No connection" {
            Mock Test-CMConnection {throw}

            It "Throw if no connection has been established" {
                {Get-CMInstance -ClassName "TestMe"} | Should Throw
            }
        }

        Context "Connection established" {
            Get-CimSession | Remove-CimSession
            $global:CMProviderServer = "TestProviderServer"
            $global:CMSiteCode = "TST"
            $global:CMNamespace = "root\sms\Site_TST"
            $global:CMSession = New-CimSession $env:COMPUTERNAME

            Mock Set-CimInstance {
                $InputObject
                #[PSCustomObject]@{ClassName = $($InputObject.ClassName); Filter = $($InputObject.Filter)}
            }

            Mock Get-CMInstance {
                Get-CimInstance "Win32_Process" -Filter $Filter | Select -First 1
            } -ParameterFilter {$ClassName -eq "TestClass"}

            Mock Get-CMInstance {
                Get-CimInstance "Win32_ComputerSystem" | Select -First 1
            }
            Mock Set-CimInstance { $InputObject }


            It "Throw if no classname and filter is supplied" {
                {Set-CMInstance -ClassName "" -filter "Name='Test'" -Property @{Test="Test"}} | Should Throw
                {Set-CMInstance -ClassName "TestClass" -filter "" -Property @{Test="Test"}} | Should Throw
            }

            It "Throw if no ClassInstance is supplied" {
                {Set-CMInstance -ClassInstance $null -Property @{Test="Test"} } | Should Throw
            }

            It "Throw if no properties are supplied" {
                $TestInstance = [PSCustomObject]@{Name="Test"}
                {Set-CMInstance -ClassInstance $TestInstance -Property $null } | Should Throw
            }

            It "Resolve Class name and filter to object" {
                $Result = Set-CMInstance -ClassName "TestClass" -Filter "Name='explorer.exe'" -Property @{TestProp="TestValue"}

                $Result.CreationClassName | Should Be "Win32_Process"
                $Result.Name | Should Be "explorer.exe"
            }


        }
    }
}