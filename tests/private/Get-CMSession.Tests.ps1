
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
#Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
#Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
}

InModuleScope "ConfigMgr" {
    Describe "private/Get-CMSession" {

        Context "DCOM" {
            Mock Test-WSMan {}

            It "Throw an exception if server cannot be contacted" {
                Get-CimSession | Remove-CimSession

                Mock New-CimSession { throw } -ParameterFilter {$ComputerName -eq "DoesNotExists"}
                {Get-CMSession "DoesNotExists" -ErrorAction Stop} | Should Throw
            }

            It "Create Dcom sesssion to local computer if WSMAN fails" {
                Get-CimSession | Remove-CimSession

                $Result = Get-CMSession
                $Result | Should Not Be $null
                $Result.ComputerName | Should be $env:COMPUTERNAME
                $Result.Protocol | Should Be "Dcom"
            }
        }

        Context "WSMAN" {
            It "Create WSMAN Session to local computer on default" {
                Get-CimSession | Remove-CimSession

                $Result = Get-CMSession
                $Result | Should Not Be $null
                $Result.ComputerName | Should be $env:COMPUTERNAME
                $Result.Protocol | Should Be "WSMAN"
            }

            It "Create WSMAN Session to specified computer" {
                Get-CimSession | Remove-CimSession

                $Result = Get-CMSession localhost
                $Result | Should Not Be $null
                $Result.ComputerName | Should be "localhost"
                $Result.Protocol | Should Be "WSMAN"
            }

            It "Return existing session" {
                Mock New-CimSession {}

                $Result = Get-CMSession localhost
                $Result | Should Not Be $null
                $Result.ComputerName | Should be "localhost"
                $Result.Protocol | Should Be "WSMAN"
            }
        }
    }
}