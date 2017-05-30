function Get-CMUserDeviceAffinity{
    <#
    .SYNOPSIS
        Gets user device affinities

    .DESCRIPTION
        The Get-CMUserDeviceAffinity cmdlet gets one or more user device affinities.

    .EXAMPLE


    .NOTES

    #>
    [CmdletBinding(DefaultParameterSetName="ResourceID")]
    PARAM (
        # Specifies the Relationship ID
        [Parameter(Mandatory, ParameterSetName="ID",ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("RelationshipResourceID")]
        [string[]]$ID,

        # Specifies the DeviceID (ResourceID)
        [Parameter(Mandatory, ParameterSetName="ResourceID",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("DeviceID")]
        [string[]]$ResourceID,

        # Specifies the Device name
        # If Search is set, the name can include the default WQL placeholders [],^,% and _
        [Parameter(ParameterSetName="Name",ValueFromPipelineByPropertyName)]
        [Alias("DeviceName")]
        [string[]]$ResourceName,

        # Specifies the User name
        # If Search is set, the name can include the default WQL placeholders [],^,% and _
        [Parameter(ParameterSetName="Name",ValueFromPipelineByPropertyName)]
        [string[]]$UserName,

        # Specifies if Name contains a search string
        [Parameter(ParameterSetName="Name")]
        [switch]$Search,

        # Specifies the Affinity Source
        [Parameter(ParameterSetName="ID")]
        [Parameter(ParameterSetName="ResourceID")]
        [Parameter(ParameterSetName="Name")]
        [ValidateSet("SoftwareCatalog","Administrator","User","UsageAgent","DeviceManagement","OSD","FastInstall","ExchangeServerConnector")]
        [string]$Source
    )

    Process {
        # Prepare filter
        $TempFilter = @()

        If (-Not([string]::IsNullOrEmpty($Source))) {
            Switch ($Source){
                "SoftwareCatalog" {$SourceID = "1"}
                "Administrator" {$SourceID = "2"}
                "User" {$SourceID = "3"}
                "UsageAgent" {$SourceID = "4"}
                "DeviceManagement" {$SourceID = "5"}
                "OSD" {$SourceID = "6"}
                "FastInstall" {$SourceID = "7"}
                "ExchangeServerConnector" {$SourceID = "8"}
            }

            if ($SourceID -gt 0) {
                $TempFilter += Get-WQLFilterString -PropertyName "Sources" -PropertyValue $SourceID
            }
        }

        If ($PSCmdlet.ParameterSetName -eq "ID") {
            $TempFilter += Get-WQLFilterString -PropertyName "RelationshipResourceID" -PropertyValue $ID
        } ElseIf ($PSCmdlet.ParameterSetName -eq "ResourceID") {
            $TempFilter += Get-WQLFilterString -PropertyName "ResourceID" -PropertyValue $ResourceID
        } ElseIf ($PSCmdlet.ParameterSetName -eq "Name") {
            if ($ResourceName.Count -gt 0) {
                $TempFilter += Get-WQLFilterString -PropertyName "ResourceName" -PropertyValue $ResourceName -Search:($Search.IsPresent)
            }
            if ($UserName.Count -gt 0) {
                $TempFilter += Get-WQLFilterString -PropertyName "UniqueUserName" -PropertyValue $UserName -Search:($Search.IsPresent)
            }
        } Else {
            Throw
        }

        $Filter = Get-WQLFilterString -And $TempFilter

        Write-Verbose "Get UserDeviceAffinities by filter $Filter"
        Get-CMInstance -ClassName "SMS_UserMachineRelationship" -Filter $Filter
    }
}