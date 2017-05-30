$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    # Define outside of Describe block, so "Mocking" doesn't apply
    $TestInstance = Get-CimInstance "Win32_ComputerSystemProduct"

    Describe "public/Get-CMUserDeviceAffinity" {
        Mock Remove-CimInstance {
            [PSCustomObject]@{ClassName = $ClassName}
        }

        Mock Get-CimInstance {
            $TestInstance
        }

        It "Throw if no ClassInstance is specified" {
            {Remove-CMInstance -InputObject $null} | Should Throw
        }

        It "Throw if no class and filter is supplied" {
            {Remove-CMInstance -ClassName "" -Filter "TestFilter"} | Should Throw
            {Remove-CMInstance -ClassName $null -Filter "TestFilter"} | Should Throw
            {Remove-CMInstance -ClassName "TestClass" -Filter ""} | Should Throw
            {Remove-CMInstance -ClassName "TestClass" -Filter $null} | Should Throw
        }

        It "Remove ConfigMgr instance" {
            Remove-CMInstance -ClassInstance $TestInstance
            Assert-MockCalled Remove-CimInstance -times 1
        }

        It "Remove pipelinged ConfigMgr instance" {
            $TestInstance | Remove-CMInstance
            Assert-MockCalled Remove-CimInstance -times 2
        }

        It "Remove ConfigMgr instances by classname and filter" {
            Remove-CMInstance -ClassName "TestClass" -Filter "TestFilter"
            Assert-MockCalled Remove-CimInstance -times 3
        }
    }
}