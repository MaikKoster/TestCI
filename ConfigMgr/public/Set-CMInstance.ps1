function Set-CMInstance {
    <#
    .SYNOPSIS
        Updates a ConfigMgr object.

    .DESCRIPTION
        Updates a ConfigMgr object. The properties to update have to be supplied by the Property parameter.

    .EXAMPLE
        $Pkg = Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        $Pkg | Set-CMInstance -Properties @{Description = "Update Me"}
        Updates the Description of the specified ConfigMgr package.

    .EXAMPLE
        Set-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'" -Properties @{Description = "Update Me"}
        Updates the Description of the specified ConfigMgr package.

    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName="Instance")]
    PARAM (
        # Specifies the ConfigMgr WMI provider Class Name
        [Parameter(Mandatory,ParameterSetName="Name")]
        [ValidateNotNullOrEmpty()]
        [Alias("Class")]
        [string]$ClassName,

        # Specifies the Filter
        [Parameter(Mandatory,ParameterSetName="Name")]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,

        # Specifies the ConfigMgr WMI provider object
        [Parameter(Mandatory,ParameterSetName="Instance",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("ClassInstance")]
        [object]$InputObject,

        # Specifies the properties to be set on the instance.
        # Should be a hashtable with key/name pairs.
        [Parameter(Mandatory, ParameterSetName="Name")]
        [Parameter(Mandatory, ParameterSetName="Instance")]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Property,

        # Specifies if updated object shall be returned
        [switch]$PassThru
    )

    Process {
        # Ensure ConfigMgr Provider information is available
        If (Test-CMConnection) {
            If ($PSCmdlet.ParameterSetName -eq "Name") {
                $InputObject = Get-CMInstance -ClassName $ClassName -Filter $Filter
            }

            If ($null -ne $InputObject) {
                $Params = @{
                    InputObject = $InputObject
                    Property = $Property
                    ErrorAction = "Stop"
                }

                If ($PassThru.IsPresent) {$Params.PassThru = $PassThru}

                Invoke-CimCommand {Set-CimInstance @Params}
            }
        }
    }
}
