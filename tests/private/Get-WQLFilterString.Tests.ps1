$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""


# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
#if (-Not(Get-Module -Name "ConfigMgr")) {
#    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force
#}

InModuleScope "ConfigMgr" {
    Describe "private/Get-WQLFilterString" {
        It "Simple string filter" {
            $Result = Get-WQLFilterString -PropertyName "PackageID" -PropertyValue "TST00001"
            $Result | Should Be "(PackageID = 'TST00001')"
        }

        It "Multiple string filter" {
            $Result = Get-WQLFilterString -PropertyName "PackageID" -PropertyValue @("TST00001", "TST00002", "TST00003")
            $Result | Should Be "((PackageID = 'TST00001') OR (PackageID = 'TST00002') OR (PackageID = 'TST00003'))"
        }

        It "Simple string search" {
            $Result = Get-WQLFilterString -PropertyName "PackageID" -PropertyValue "TST000%" -Search
            $Result | Should Be "(PackageID LIKE 'TST000%')"

            $Result = Get-WQLFilterString -PropertyName "PackageID" -PropertyValue "TST000*" -Search
            $Result | Should Be "(PackageID LIKE 'TST000%')"
        }

        It "Multiple string search" {
            $Result = Get-WQLFilterString -PropertyName "PackageID" -PropertyValue @("TST000%", "%01") -Search
            $Result | Should Be "((PackageID LIKE 'TST000%') OR (PackageID LIKE '%01'))"
        }

        It "Simple int filter" {
            $Result = Get-WQLFilterString -PropertyName "ID" -PropertyValue 1
            $Result | Should Be "(ID = 1)"
        }

        It "Multiple int filter" {
            $Result = Get-WQLFilterString -PropertyName "ID" -PropertyValue @(1,2,3)
            $Result | Should Be "((ID = 1) OR (ID = 2) OR (ID = 3))"
        }

        It "Handle special characters" {
            $Result = Get-WQLFilterString -PropertyName "UniqueUsername" -PropertyValue "TST\TestUser"
            $Result | Should Be "(UniqueUsername = 'TST\\TestUser')"
        }
    }
}