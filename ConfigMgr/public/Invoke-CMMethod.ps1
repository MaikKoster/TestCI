function Invoke-CMMethod {
    <#
    .SYNOPSIS
        Invokes a ConfigMgr provider method.

    .DESCRIPTION
        Invokes a ConfigMgr provider method.

    .EXAMPLE
        Remove-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        Removes the ConfigMgr package with PackageID 'TST00001'.

    .EXAMPLE
        $Pkg = Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
        $Pkg | Remove-CMInstance
        Removes the ConfigMgr package with PackageID 'TST00001'.

    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName="ClassName")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    PARAM (
        # Specifies the ConfigMgr WMI provider Class Name
        # Needs to be supplied for static class methods
        [Parameter(Mandatory,ParameterSetName="ClassName")]
        [ValidateNotNullOrEmpty()]
        [string]$ClassName,

        # Specifies the ConfigMgr WMI provider object
        # Needs to be supplied for instance methods
        [Parameter(Mandatory,ParameterSetName="ClassInstance")]
        [ValidateNotNullOrEmpty()]
        [Alias("ClassInstance")]
        [object]$InputObject,

        # Specifies the Method Name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MethodName,

        # Specifies the Arguments to be supplied to the method.
        # Should be a hashtable with key/name pairs.
        [hashtable]$Arguments,

        # If set, ReturnValue will not be evaluated
        # Usefull if ReturnValue does not indicated successfull execution
        [switch]$SkipValidation
    )

    Process {
        If ($PSCmdlet.ShouldProcess("$CMProviderServer", "Invoke $MethodName")) {
            # Ensure ConfigMgr Provider information is available
            If (Test-CMConnection) {
                    $Params = @{
                        MethodName = $MethodName
                        Arguments = $Arguments
                        ErrorAction = "Stop"
                    }

                    If ($PSCmdlet.ParameterSetName -eq "ClassInstance") {
                        $Params.InputObject = $InputObject
                    } Else {
                        $Params.CimSession = $Global:CMSession
                        $Params.Namespace = $Global:CMNamespace
                        $Params.ClassName = $ClassName
                    }

                    $Result = Invoke-CimCommand {Invoke-CimMethod @Params}

                    If ((!($SkipValidation.IsPresent)) -and ($null -ne $Result)) {
                        If ($Result.ReturnValue -eq 0) {
                            Write-Verbose "Successfully invoked $MethodName on $CMProviderServer."
                        } Else {
                            Write-Verbose "Failed to invoked $MethodName on $CMProviderServer. ReturnValue: $($Result.ReturnValue)"
                        }
                    }

                Return $Result
            }
        }
    }
}