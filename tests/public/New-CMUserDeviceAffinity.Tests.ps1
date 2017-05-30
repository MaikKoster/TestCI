$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

# Import our module to use InModuleScope
Get-Module -Name ConfigMgr -All | Remove-Module -Force -ErrorAction Stop
Import-Module (Resolve-Path "$root\ConfigMgr\ConfigMgr.psd1") -Force

InModuleScope "ConfigMgr" {
    Describe "public/New-CMUserDeviceAffinity" {
        Get-CimSession | Remove-CimSession
        $global:CMProviderServer = "TestProviderServer"
        $global:CMSiteCode = "TST"
        $global:CMNamespace = "root\sms\Site_TST"
        $global:CMSession = New-CimSession $env:COMPUTERNAME

        Mock Invoke-CMMethod {
            [PSCustomObject]@{Class = $ClassName; MethodName = $MethodName; Arguments = $Arguments}
        }

        It "Throw if no or empty ResourceID is supplied" {
            {New-CMUserDeviceAffinity -ResourceID $null -UserName "TST\Testuser"} | Should Throw
            {New-CMUserDeviceAffinity -ResourceID 0 -UserName "TST\Testuser"} | Should Throw
        }

        It "Throw if no or empty Username is supplied" {
            {New-CMUserDeviceAffinity -ResourceID 1 -UserName $null} | Should Throw
            {New-CMUserDeviceAffinity -ResourceID 1 -UserName ""} | Should Throw
        }

        It "Create new User Device Affinity" {
            $TestAffinity = New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser"

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "MethodName" | Should Be "CreateRelationship"
            $TestArgs = $TestAffinity | Select-Object -ExpandProperty "Arguments"

            $TestArgs["MachineResourceID"]  | Should Be 1
            $TestArgs["UserAccountName"] | Should Be "TST\Testuser"
            $TestArgs["SourceID"] | Should Be 2
            $TestArgs["TypeID"] | Should Be 1
        }

        It "Create new User Device Affinity with specified source" {
            $TestAffinity = New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source SoftwareCatalog

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "MethodName" | Should Be "CreateRelationship"
            $TestArgs = $TestAffinity | Select-Object -ExpandProperty "Arguments"

            $TestArgs["MachineResourceID"]  | Should Be 1
            $TestArgs["UserAccountName"] | Should Be "TST\Testuser"
            $TestArgs["SourceID"] | Should Be 1
            $TestArgs["TypeID"] | Should Be 1

            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source Administrator | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 2
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source User | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 3
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source UsageAgent | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 4
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source DeviceManagement | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 5
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source OSD | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 6
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source FastInstall | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 7
            New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source ExchangeServerConnector | Select-Object -ExpandProperty "Arguments" | ForEach-Object {$_["SourceID"]} | Should Be 8
        }

        It "Create new User Device Affinity without TypeID" {
            $TestAffinity = New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -NoType

            $TestAffinity | Select-Object -ExpandProperty "Class" | Should Be "SMS_UserMachineRelationship"
            $TestAffinity | Select-Object -ExpandProperty "MethodName" | Should Be "CreateRelationship"
            $TestArgs = $TestAffinity | Select-Object -ExpandProperty "Arguments"

            $TestArgs["MachineResourceID"]  | Should Be 1
            $TestArgs["UserAccountName"] | Should Be "TST\Testuser"
            $TestArgs["SourceID"] | Should Be 2
            $TestArgs["TypeID"] | Should Be $null
        }
    }
}