$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
}

InModuleScope "ConfigMgr" {
    Describe "public/New-CMInstance" {
        Context "No connection" {
            Mock Test-CMConnection {throw}

            It "Throw if no connection has been established" {
                {New-CMObject -ClassName "TestClass" -Arguments @{TestArg=1} } | Should Throw
            }
        }

        Context "Connection established" {
            Get-CimSession | Remove-CimSession

            $global:CMProviderServer = "TestProviderServer"
            $global:CMSiteCode = "TST"
            $global:CMNamespace = "root\sms\Site_TST"
            $global:CMSession = New-CimSession $env:COMPUTERNAME

            Mock New-CimInstance { [PSCustomObject]@{Class = $ClassName; Arguments = $Property; Namespace = $Namespace; ComputerName = $($CimSession.ComputerName); ClientOnly = $ClientOnly.IsPresent} }

            It "Throw if class or properties are missing" {
                {New-CMInstance -ClassName "" -Property @{TestArg=1}} | Should Throw
                {New-CMInstance -ClassName "TestClass" -Property $null } | Should Throw
            }

            It "Use Provider connection" {
                $TestObject = New-CMInstance -ClassName "TestClass" -Property @{TestArg=1}

                $TestObject.Namespace | Should Be "root\sms\site_TST"
                $TestObject.ComputerName | Should Be "$Env:ComputerName"
            }

            It "Use specified values" {
                $TestObject = New-CMInstance -ClassName "TestClass" -Property @{TestArg=1}

                $TestObject.Class | Should Be "TestClass"
                $TestObject.Arguments | %{$_.TestArg} |  Should Be 1

                New-CMInstance -ClassName "TestClass" -Property @{TestArg=1} -ClientOnly | Select-Object -ExpandProperty "ClientOnly" | Should Be $true
            }
        }
    }
}