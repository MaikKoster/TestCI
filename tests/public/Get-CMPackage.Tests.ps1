$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "ConfigMgr")) {
    Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psm1") -Force
}

InModuleScope "ConfigMgr" {
    Describe "public/Get-Package" {

        Get-CimSession | Remove-CimSession
        $global:CMProviderServer = "TestProviderServer"
        $global:CMSiteCode = "TST"
        $global:CMNamespace = "root\sms\Site_TST"
        $global:CMSession = New-CimSession $env:COMPUTERNAME

        Mock Get-CimInstance {
            [PSCustomObject]@{Class = $ClassName; Filter = $Filter}
        }

        It "Throw if no or empty ID is supplied" {
            {Get-CMPackage -ID $null -Type Package} | Should Throw
            {Get-CMPackage -ID "" -Type Package} | Should Throw
        }

        It "Throw if no or empty name is supplied" {
            {Get-CMPackage -Name $null} | Should Throw
            {Get-CMPackage -Name ""} | Should Throw
        }

        It "Get Package by ID" {
            $TestPackage = Get-CMPackage -Type Package -ID "TST000001"

            $TestPackage | select -ExpandProperty "Class" | Should Be "SMS_Package"
            $TestPackage | select -ExpandProperty "Filter" | Should Be "((PackageID = 'TST000001'))"
        }

        It "Get Package by Name" {
            $TestPackage = Get-CMPackage  -Type Package -Name "Test Package"

            $TestPackage | select -ExpandProperty "Class" | Should Be "SMS_Package"
            $TestPackage | select -ExpandProperty "Filter" | Should Be "((Name = 'Test Package'))"
        }

        It "Get Package by Name in Folder" {
            $TestPackage = Get-CMPackage -Type Package -Name "Test Package" -ParentID 1

            $TestPackage | select -ExpandProperty "Class" | Should Be "SMS_Package"
            $TestPackage | select -ExpandProperty "Filter" | Should Be "((Name = 'Test Package') AND (PackageID IN (SELECT InstanceKey FROM SMS_ObjectContainerItem WHERE ContainerNodeID = 1)))"
        }

        It "Get Package by CIID" {
            $TestPackage = Get-CMPackage -Type Package -CIID "JustSomeTestID"

            $TestPackage | select -ExpandProperty "Class" | Should Be "SMS_Package"
            $TestPackage | select -ExpandProperty "Filter" | Should Be "(PackageID IN (SELECT PackageID FROM SMS_PackageToContent WHERE CI_ID = 'JustSomeTestID'))"
        }

        It "Get correct package type" {
            Get-CMPackage -Type All -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_PackageBaseClass"
            Get-CMPackage -Type Package -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_Package"
            Get-CMPackage -Type TaskSequencePackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_TaskSequencePackage"
            Get-CMPackage -Type DriverPackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_DriverPackage"
            Get-CMPackage -Type SoftwareUpdatePackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_SoftwareUpdatePackage"
            Get-CMPackage -Type DeviceSettingPackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_DeviceSettingPackage"
            Get-CMPackage -Type VirtualApplicationPackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_Package"
            Get-CMPackage -Type ImagePackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_ImagePackage"
            Get-CMPackage -Type BootImagePackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_BootImagePackage"
            Get-CMPackage -Type OperatingSystemInstallPackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_OperatingSystemInstallPackage"
            Get-CMPackage -Type VHDPackage -Name "Test Package" | select -ExpandProperty "Class" | Should Be "SMS_VHDPackage"
        }
    }
}