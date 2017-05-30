function Get-CMInstance {
    <#
    .SYNOPSIS
        Returns a ConfigMgr object.

    .DESCRIPTION
        Returns one or several ConfigMgr objects.
        Results can be limited by a Filter.

    .EXAMPLE
        Get-CMInstance -ClassName SMS_Package
        Returns a list of ConfigMgr packages.

    .EXAMPLE
        Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        Returns a ConfigMgr Package with PackageID 'TST00001'.

    .NOTES

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWMICmdlet", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    PARAM (
        # Specifies the ConfigMgr WMI provider Class Name
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("Class")]
        [string]$ClassName,

        # Specifies the Where clause to filter the specified ConfigMgr WMI provider class.
        # If no filter is supplied, all objects will be returned.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Filter,

        # Specifies if the lazy properties shall be fetched as well.
        # On default, lazy properties won't be included in the result.
        [Alias("Lazy")]
        [switch]$IncludeLazy
    )

    Process {
        # Ensure ConfigMgr Provider information is available
        If (Test-CMConnection) {

            If ($Filter.Contains(" JOIN ")) {
                Write-Verbose "Fall back to WMI cmdlets"
                $WMIParams = @{
                    ComputerName = $global:CMProviderServer
                    Namespace = $CMNamespace
                    Class = $ClassName
                    Filter = $Filter
                }
                If ($global:CMCredential -ne [System.Management.Automation.PSCredential]::Empty) {
                    $WMIParams.Credential = $CMCredential
                }
                Invoke-CimCommand {Get-WmiObject @WMIParams -ErrorAction Stop}
            } Else {
                $InstanceParams = @{
                    CimSession = $global:CMSession
                    Namespace = $global:CMNamespace
                    ClassName = $ClassName
                    ErrorAction = "Stop"
                }

                If ($Filter -ne "") { $InstanceParams.Filter = $Filter }

                $Result = Invoke-CimCommand {Get-CimInstance @InstanceParams}

                If ($IncludeLazy.IsPresent) {
                    $Result = Invoke-CimCommand {$Result | Get-CimInstance -ErrorAction Stop}
                }

                $Result
            }
        }
    }
}