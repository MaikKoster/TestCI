function Get-WQLFilterString {
    <#
    .SYNOPSIS
        Gets a WQL filter string.

    .DESCRIPTION
        Uses the supplied values to generate a WQL search filter string that can be used for WMI.

    .EXAMPLE
        Get-WQLFilterString


    .NOTES

    #>
    [CmdLetBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [Outputtype([string])]
    PARAM (
        [Parameter(Mandatory, ParameterSetName="Name", ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [string]$PropertyName,

        [Parameter(Mandatory, ParameterSetName="Name", ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("Value")]
        [string[]]$PropertyValue,

        [Parameter(ParameterSetName="Name")]
        [switch]$Search,

        [Parameter(Mandatory, ParameterSetName="Or")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Or,

        [Parameter(Mandatory, ParameterSetName="And")]
        [ValidateNotNullOrEmpty()]
        [string[]]$And
    )
    Process {
        if ($PSCmdlet.ParameterSetName -eq "Name") {
            $Filter = @()

            foreach ($Prop In $PropertyValue) {

                If ([bool]($Prop -as [double]) -and (-not($Search.IsPresent))) {
                    $Filter += "($PropertyName = $Prop)"
                } else {
                    If ($Search.IsPresent) {
                        $Operation = "LIKE"
                        $PropValue = $Prop -replace "\*", "%"
                    } Else {
                        $Operation = "="
                        $PropValue = $Prop
                    }

                    $Filter += "($Propertyname $Operation '$PropValue')"
                }
            }

            $Result = Get-WQLFilterString -Or $Filter
            #if ($Filter.Count -gt 1) {
            #    $Result = "($($Filter -join ' OR '))"
            #} else {
            #    $Result = $Filter
            #}
        } elseif ($PSCmdlet.ParameterSetName -eq "Or") {
            if ($Or.Count -gt 1) {
                $Result = "($($Or -join ' OR '))"
            } else {
                $Result = $Or
            }
        } elseif ($PSCmdlet.ParameterSetName -eq "And") {
            if ($And.Count -gt 1) {
                $Result = "($($And -join ' AND '))"
            } else {
                $Result = $And
            }
        }

        # Fix special characters
        $Result = $Result -replace "(?<!\\)\\(?!\\)", "\\"
        Write-Verbose "Created WQL filter string '$Result'."

        $Result
    }
}