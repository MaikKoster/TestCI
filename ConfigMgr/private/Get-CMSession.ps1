function Get-CMSession {
    <#
    .SYNOPSIS
        Returns a valid session to the specified computer

    .DESCRIPTION
        Returns a valid session to the specified computer
        If session does not exist, new session is created
        Falls back from WSMAN to DCOM for backwards compatibility

    .EXAMPLE


    .NOTES
    #>
    [CmdLetBinding()]
    PARAM (
        # Specifies the ComputerName to connect to.
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $env:COMPUTERNAME,

        # Specifies the credentials to connect to the Provider Server.
        [PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {

        $Opt = New-CimSessionOption -Protocol Dcom

        $SessionParams = @{
            ErrorAction = 'Stop'
        }

        if ($PSBoundParameters['Credential']) {
            $SessionParams.Credential = $Credential
        }
    }

    Process {
        # Check if there is an already existing session to the specified computer
        $Session = Get-CimSession | Where-Object { $_.ComputerName -eq $ComputerName} | Select-Object -First 1

        If ($null -eq $Session) {

            $SessionParams.ComputerName = $ComputerName

            $WSMan = Test-WSMan -ComputerName $ComputerName -ErrorAction SilentlyContinue

            If (($null -ne $WSMan) -and ($WSMan.ProductVersion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+')) {
                Try {
                    Write-Verbose -Message "Attempt to connect to $ComputerName using the WSMAN protocol."
                    $Session = New-CimSession @SessionParams
                } Catch {
                    Write-Verbose "Unable to connect to $ComputerName using the WSMAN protocol. Test DCOM ..."

                }
            }

            If ($null -eq $Session) {
                $SessionParams.SessionOption = $Opt

                Try {
                    Write-Verbose -Message "Attempt to connect to $ComputerName using the DCOM protocol."
                    $Session = New-CimSession @SessionParams
                } Catch {
                    Write-Error -Message "Unable to connect to $ComputerName using the WSMAN or DCOM protocol. Verify $ComputerName is online or credentials and try again."
                }
            }

            If ($null -eq $Session) {
                $Session = Get-CimSession | Where-Object { $_.ComputerName -eq $ComputerName} | Select-Object -First 1
            }
        }

        Return $Session
    }
}