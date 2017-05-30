$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    Describe "public/Get-CMUserDeviceAffinity" {
        Get-CimSession | Remove-CimSession
        $global:CMProviderServer = "TestProviderServer"
        $global:CMSiteCode = "TST"
        $global:CMNamespace = "root\sms\Site_TST"
        $global:CMSession = New-CimSession $env:COMPUTERNAME

        Mock Get-CimInstance {
            [PSCustomObject]@{Class = $ClassName; Filter = $Filter}
        }

        It "Throw if no or empty ID is supplied" {
            {Get-CMUserDeviceAffinity -ID $null} | Should Throw
            {Get-CMUserDeviceAffinity -ID ""} | Should Throw
        }

        It "Throw if no or empty ResourceID is supplied" {
            {Get-CMUserDeviceAffinity -ResourceID $null} | Should Throw
            {Get-CMUserDeviceAffinity -ResourceID ""} | Should Throw
        }

        It "Throw if no or empty ResourceName is supplied" {
            {Get-CMUserDeviceAffinity -ResourceName $null} | Should Throw
            {Get-CMUserDeviceAffinity -ResourceName ""} | Should Throw
        }

        It "Throw if no or empty Username is supplied" {
            {Get-CMUserDeviceAffinity -UserName $null} | Should Throw
            {Get-CMUserDeviceAffinity -UserName ""} | Should Throw
        }

        It "Get UserDeviceAffinity by ID" {
            $TestAffinity = Get-CMUserDeviceAffinity -ID 1

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(RelationshipResourceID = 1)"
        }

        It "Get UserDeviceAffinity by multiple IDs" {
            $TestAffinity = Get-CMUserDeviceAffinity -ID 1,2,3

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((RelationshipResourceID = 1) OR (RelationshipResourceID = 2) OR (RelationshipResourceID = 3))"
        }

        It "Get UserDeviceAffinity by ResourceID" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceID 2

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(ResourceID = 2)"
        }

        It "Get UserDeviceAffinity by multiple ResourceIDs" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceID 2,3,4

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((ResourceID = 2) OR (ResourceID = 3) OR (ResourceID = 4))"
        }

        It "Get UserDeviceAffinity by Resource Name" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName "TSTComputer"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(ResourceName = 'TSTComputer')"
        }

        It "Get UserDeviceAffinity by multiple Resource Names" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName @("TSTComputer1", "TSTComputer2", "TSTComputer3")

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((ResourceName = 'TSTComputer1') OR (ResourceName = 'TSTComputer2') OR (ResourceName = 'TSTComputer3'))"
        }

        It "Get UserDeviceAffinity by Resource Name search" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName "TST%" -Search

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(ResourceName LIKE 'TST%')"
        }

        It "Get UserDeviceAffinity by Resource Name search limited by Source" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName "TST%" -Search -Source "FastInstall"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((Sources = 7) AND (ResourceName LIKE 'TST%'))"
        }

        It "Get UserDeviceAffinity by User Name" {
            $TestAffinity = Get-CMUserDeviceAffinity -UserName "TST\Testuser"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(UniqueUserName = 'TST\\TestUser')"
        }

        It "Get UserDeviceAffinity by multiple User Names" {
            $TestAffinity = Get-CMUserDeviceAffinity -UserName "TST\Testuser1", "TST\Testuser2", "TST\TestUser3"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((UniqueUserName = 'TST\\TestUser1') OR (UniqueUserName = 'TST\\TestUser2') OR (UniqueUserName = 'TST\\TestUser3'))"
        }

        It "Get UserDeviceAffinity by User Name search" {
            $TestAffinity = Get-CMUserDeviceAffinity -UserName "TST\Test%" -Search

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(UniqueUserName LIKE 'TST\\Test%')"
        }

        It "Get UserDeviceAffinity by User Name search limited by Source" {
            $TestAffinity = Get-CMUserDeviceAffinity -UserName "TST\Test%" -Search -Source "FastInstall"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((Sources = 7) AND (UniqueUserName LIKE 'TST\\Test%'))"
        }

        It "Get UserDeviceAffinity by Resource and User Name" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName "TstComputer" -UserName "TST\Testuser"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "((ResourceName = 'TstComputer') AND (UniqueUserName = 'TST\\TestUser'))"
        }

        It "Get UserDeviceAffinity by multiple Resource and User Names" {
            $TestAffinity = Get-CMUserDeviceAffinity -ResourceName "TstComputer1", "TstComputer2" -UserName "TST\Testuser1", "TST\Testuser2"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "Filter" | Should Be "(((ResourceName = 'TstComputer1') OR (ResourceName = 'TstComputer2')) AND ((UniqueUserName = 'TST\\TestUser1') OR (UniqueUserName = 'TST\\TestUser2')))"
        }

        It "Use correct Source" {
            Get-CMUserDeviceAffinity -Search -Source "SoftwareCatalog" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 1)"
            Get-CMUserDeviceAffinity -Search -Source "Administrator" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 2)"
            Get-CMUserDeviceAffinity -Search -Source "User" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 3)"
            Get-CMUserDeviceAffinity -Search -Source "UsageAgent" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 4)"
            Get-CMUserDeviceAffinity -Search -Source "DeviceManagement" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 5)"
            Get-CMUserDeviceAffinity -Search -Source "OSD" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 6)"
            Get-CMUserDeviceAffinity -Search -Source "FastInstall" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 7)"
            Get-CMUserDeviceAffinity -Search -Source "ExchangeServerConnector" | Select-Object -ExpandProperty "Filter" | Should Be "(Sources = 8)"
        }
    }
}