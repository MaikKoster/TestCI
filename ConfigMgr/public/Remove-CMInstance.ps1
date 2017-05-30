function Remove-CMInstance {
    <#
    .SYNOPSIS
        Removes a ConfigMgr object.

    .DESCRIPTION
        Removes a ConfigMgr object.
        If the object is specified by Classname and filter, make sure it returns a unique object.

    .EXAMPLE
        Remove-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        Removes the ConfigMgr package with PackageID 'TST00001'.

    .EXAMPLE
        $Pkg = Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        $Pkg | Remove-CMInstance
        Removes the ConfigMgr package with PackageID 'TST00001'.

    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName="ClassInstance")]
    PARAM (
        # Specifies the ConfigMgr WMI provider Class Name
        [Parameter(Mandatory,ParameterSetName="ClassName",ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$ClassName,

        # Specifies the Filter
        [Parameter(Mandatory,ParameterSetName="ClassName",ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,

        # Specifies the ConfigMgr WMI provider object
        [Parameter(Mandatory,ParameterSetName="ClassInstance",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("ClassInstance")]
        [object]$InputObject
    )

    Process {
        # Ensure ConfigMgr Provider information is available
        if (Test-CMConnection) {
            if ($PSCmdlet.ParameterSetName -eq "ClassName") {
                $InputObject = Get-CMInstance -Class $ClassName -Filter $Filter
            }

            if ($null -ne $InputObject) {
                $Params = @{
                    InputObject = $InputObject
                    ErrorAction = "Stop"
                }

                Invoke-CimCommand {Remove-CimInstance @Params}
            }
        }
    }
}