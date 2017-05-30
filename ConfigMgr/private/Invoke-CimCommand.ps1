# Used to catch some common errors due to RCP connection issues on slow WAN connections
function Invoke-CimCommand {
    <#
    .SYNOPSIS
        Executes the supplied CIM command.

    .DESCRIPTION
        Used as a wrapper around all common CIM based PowerShell commands to catch common issues.
        Primarily to catch a common RPC error (0X800706bf) on high latency/small bandwidth WAN connections.

    .EXAMPLE
        Invoke-CimCommand {Get-CimInstance -ClassName "Win32_OperatingSystem"}
        Returns an Instance of the "Win32_OperatingSystem" WMI class

    .NOTES

    #>
    [CmdLetBinding()]
    Param(
        # Specifies the CIM based Command that shall be executed
        [Parameter(Mandatory)]
        [scriptblock]$Command
    )

    Process {
        $RetryCount = 0
        Do {
            $Retry = $false

            Try {
                & $Command
            } Catch {
                If ($null -ne $_.Exception) {
                    If (($_.Exception.HResult -eq -2147023169 ) -or ($_.Exception.ErrorData.error_Code -eq 2147944127)) {
                        If ($RetryCount -ge 3) {
                            $Retry = $false
                        } Else {
                            $RetryCount += 1
                            $Retry = $true
                            Write-Verbose "CIM/WMI command failed with Error 2147944127 (HRESULT 0x800706bf)."
                            Write-Verbose "Common RPC error, retry on default. Current retry count $RetryCount"
                        }
                    } Else {
                        Throw $_.Exception
                    }
                } Else {
                    Throw
                }
            }
        } While ($Retry)
    }
}