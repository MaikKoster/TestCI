$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    Describe "public/Invoke-CMMethod" {
        Context "No connection" {
            Mock Test-CMConnection {throw}

            It "Throw if no connection has been established" {
                {Invoke-CMMethod -ClassName "TestClass" -Name "TestMethod"} | Should Throw
            }
        }

        Context "Connection established" {

            Mock Invoke-CimMethod {
                [PSCustomObject]@{ReturnValue = 0; Class = $ClassName; Name = $MethodName; Arguments = $Arguments; Namespace = $Namespace; ComputerName = $($CimSession.ComputerName)}
            }

            Mock Invoke-CimMethod {
                [PSCustomObject]@{ReturnValue = 1; Class = $ClassName; Name = $MethodName; Arguments = $Arguments}
            } -ParameterFilter {$MethodName -eq "FailMethod"}

            Mock Invoke-CimMethod {
                [PSCustomObject]@{ReturnValue = 0; Class = $InputObject.CimClass.CimClassName; Name = $MethodName; Arguments = $Arguments}
            } -ParameterFilter {$InputObject -ne $null}

            Get-CimSession | Remove-CimSession
            $global:CMProviderServer = "TestProviderServer"
            $global:CMSiteCode = "TST"
            $global:CMNamespace = "root\sms\Site_TST"
            $global:CMSession = New-CimSession $env:COMPUTERNAME

            It "Throw if no class or method is supplied" {
                {Invoke-CMMethod -ClassName "" -MethodName "TestMethod"} | Should Throw
                {Invoke-CmMethod -ClassName "TestClass" -MethodName ""} | Should Throw
                {Invoke-CmMethod -ClassInstance $null -MethodName "TestMethod"} | Should Throw
            }

            It "Use Provider connection" {
                $TestMethod = Invoke-CMMethod -ClassName "TestClass" -MethodName "TestMethod"

                $TestMethod.Namespace | Should Be "root\sms\site_TST"
                $TestMethod.ComputerName | Should Be "$Env:ComputerName"
            }

            It "Use specified values for static WMI Method invocation" {
                $TestMethod = Invoke-CMMethod -ClassName "TestClass" -MethodName "TestMethod" -Arguments @{TestArgument="Test"}

                $TestMethod.Class | Should Be "TestClass"
                $TestMethod.Name  | Should Be "TestMethod"
                $TestMethod.Arguments.TestArgument | Should Be "Test"

                Invoke-CMMethod -ClassName "TestClass" -MethodName "TestMethod"  | Select-Object -ExpandProperty "Arguments" | Should Be $null
            }

            It "Use specified values for WMI instance Method invocation" {
                $TestInstance = Get-CimInstance "Win32_Process" -Filter "Name='Explorer.exe'" | Select-Object -First 1
                $TestMethod = Invoke-CMMethod -InputObject $TestInstance -MethodName "TestMethod" -Arguments @{TestArgument="Test"}

                $TestMethod.Class | Should Be "Win32_Process"
                $TestMethod.Name  | Should Be "TestMethod"
                $TestMethod.Arguments.TestArgument | Should Be "Test"

                Invoke-CMMethod -InputObject $TestInstance -MethodName "TestMethod"  | Select-Object -ExpandProperty "Arguments" | Should Be $null
            }

            It "Log method failure" {
                $TestMethod = Invoke-CMMethod -ClassName "TestClass" -MethodName "FailMethod"

                $TestMethod.Class | Should Be "TestClass"
                $TestMethod.Name  | Should Be "FailMethod"
                $TestMethod.Arguments | Should Be $null
                $TestMethod.ReturnValue | Should Be 1
            }

            #It "Use specified values for static WMI Method invocation" {
            #    $TestClassInstance = [PSCustomObject]{Name="TestClass"}
            #    $TestClassInstance | Add-Member -MemberType ScriptMethod -Name "RunMe" -Value {[PSCustomObject]@{ReturnValue=0;}}
            #    $TestMethod = Invoke-CMMethod -ClassName "TestClass" -Name "TestMethod"
            #
            #    $TestMethod.Class | Should Be "TestClass"
            #    $TestMethod.Name  | Should Be "TestMethod"
            #    $TestMethod.Arguments | Should Be $null
    #
            #    Invoke-CMMethod -ClassName "TestClass" -Name "TestMethod" -Arguments @("TestArgument") | select -ExpandProperty "Arguments" | Should Be @("TestArgument")
            #}
        }
    }
}