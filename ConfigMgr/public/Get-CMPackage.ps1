function Get-CMPackage {
    <#
    .SYNOPSIS
        Gets a ConfigMgr package.

    .DESCRIPTION
        Gets a ConfigMgr package.

    .EXAMPLE


    .NOTES

    #>
    [CmdletBinding(DefaultParameterSetName="ID")]
    PARAM (
        # Specifies the PackageID
        [Parameter(Mandatory, ParameterSetName="ID",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("PackageID")]
        [string]$ID,

        # Specifies the Package Name
        # If Search is set, the name can include the default WQL placeholders [],^,% and _
        [Parameter(Mandatory, ParameterSetName="Name",ValueFromPipelineByPropertyName)]
        [Alias("PackageName")]
        [string[]]$Name,

        # Specifies if Name contains a search string
        [Parameter(ParameterSetName="Name")]
        [switch]$Search,

        # Specifies the Folder ID
        [Alias("FolderID", "Folder")]
        [string]$ParentID,

        # Specifies the CIID of assigned content.
        [Parameter(Mandatory,ParameterSetName="CIID")]
        [string]$CIID,

        # Specifies the Package Type
        [Parameter(Mandatory,ParameterSetName="ID")]
        [Parameter(Mandatory,ParameterSetName="Name")]
        [Parameter(Mandatory,ParameterSetName="CIID")]
        [ValidateSet("Package","DriverPackage","TaskSequencePackage","SoftwareUpdatePackage","DeviceSettingPackage","VirtualApplicationPackage","ImagePackage","BootImagePackage","OperatingSystemInstallPackage","VHDPackage","All")]
        [Alias("PackageType")]
        [string]$Type,

        # Specifies a custom filter to use
        [Parameter(Mandatory, ParameterSetName = "Filter")]
        [ValidateNotNullOrEmpty()]
        [string]$Filter
    )

    Process {
        # Prepare filter
        $PackageFilter = @()

        If ($PSCmdlet.ParameterSetName -eq "ID") {
            $PackageFilter += Get-WQLFilterString -PropertyName "PackageID" -PropertyValue $ID
        } ElseIf ($PSCmdlet.ParameterSetName -eq "Filter") {
            $PackageFilter += $Filter
        } ElseIf ($PSCmdlet.ParameterSetName -eq "CIID") {
            $PackageFilter += "PackageID IN (SELECT PackageID FROM SMS_PackageToContent WHERE CI_ID = '$CIID')"
        } Else {
            $PackageFilter += Get-WQLFilterString -PropertyName "Name" -PropertyValue $Name -Search:($Search.IsPresent)

            If (-not([string]::IsNullOrEmpty($ParentID))) {
                $PackageFilter += "(PackageID IN (SELECT InstanceKey FROM SMS_ObjectContainerItem WHERE ContainerNodeID = $ParentID))"
            }
        }

        # Evaluate Package Type
        Switch ($Type){
            "Package" {$ClassName = "SMS_Package"}
            "DriverPackage" {$ClassName = "SMS_DriverPackage"}
            "TaskSequencePackage" {$ClassName = "SMS_TaskSequencePackage"}
            "SoftwareUpdatePackage" {$ClassName = "SMS_SoftwareUpdatePackage"}
            "DeviceSettingPackage" {$ClassName = "SMS_DeviceSettingPackage"}
            "VirtualApplicationPackage" {$ClassName = "SMS_Package"; $PackageFilter += "(PackageType = 7)"}
            "ImagePackage" {$ClassName = "SMS_ImagePackage"}
            "BootImagePackage" {$ClassName = "SMS_BootImagePackage"}
            "OperatingSystemInstallPackage" {$ClassName = "SMS_OperatingSystemInstallPackage"}
            "VHDPackage" {$ClassName = "SMS_VHDPackage"}
            "All" {$ClassName = "SMS_PackageBaseClass"}
        }

        $Filter = "($($PackageFilter -join ' AND '))"
        Write-Verbose "Get Package(s) by filter $Filter"
        Get-CMInstance -ClassName $ClassName -Filter $Filter
    }
}