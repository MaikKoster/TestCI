function New-CMUserDeviceAffinity{
    <#
    .SYNOPSIS
        Creates a new User device affinity

    .DESCRIPTION
        The New-CMUserDeviceAffinity cmdlet creates a new user device affinity.

    .EXAMPLE
        New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser"
        Creates a new user device affinity for the specified Resource and User

    .EXAMPLE
        New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source Administrator
        Creates a new user device affinity for the specified Resource, User and Source

    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    PARAM (
        # Specifies the DeviceID (ResourceID)
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [uint32]::MaxValue)]
        [Alias("DeviceID")]
        [uint32]$ResourceID,

        # Specifies the User name
        # e.g. "{Domain}\{samaccountname}
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName,

        # Specifies the Package Type
        [ValidateSet("SoftwareCatalog","Administrator","User","UsageAgent","DeviceManagement","OSD","FastInstall","ExchangeServerConnector")]
        [ValidateNotNullOrEmpty()]
        [string]$Source = "Administrator",

        # Specifies if the Type property should be set for the relationship
        [switch]$NoType
    )

    Process {
         Switch ($Source){
            "SoftwareCatalog" {$SourceID = 1}
            "Administrator" {$SourceID = 2}
            "User" {$SourceID = 3}
            "UsageAgent" {$SourceID = 4}
            "DeviceManagement" {$SourceID = 5}
            "OSD" {$SourceID = 6}
            "FastInstall" {$SourceID = 7}
            "ExchangeServerConnector" {$SourceID = 8}
        }

        $MethodArgs = @{
            MachineResourceID = [uint32]$ResourceID
            UserAccountName = $UserName
            SourceID = [uint32]$SourceID
        }

        if (-not($NoType.IsPresent)) { $MethodArgs.TypeID = [uint32]1 }

        Invoke-CMMethod -ClassName "SMS_UserMachineRelationship" -MethodName "CreateRelationship" -Arguments $MethodArgs
    }
}