
function Write-Log {
    <#
    .SYNOPSIS
        Write-Log writes a message to a specified log file with the current time stamp.

    .DESCRIPTION
        The Write-Log function is designed to add logging capability to other scripts.
        In addition to writing output and/or verbose you can write to a log file for
        later debugging.

    .EXAMPLE
        Write-Log -Message 'Log message'
        Writes the message to c:\Logs\PowerShellLog.log.

    .EXAMPLE
        Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
        Writes the content to the specified log file and creates the path and file specified.

    .EXAMPLE
        Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
        Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param (
        # Defines the content that should be added to the log file.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        # The path to the log file to which the Message shall be written.
        # Path and file will be created if it does not exist.
        # If omitted function will use the $LogPath variable defined on script or global level.
        # If that isn't set as well, function will fail
        [Alias('LogPath')]
        [string]$Path,

        # Defines the criticality of the log information being written to the log.
        # Can be any of Error, Warning, Informational
        # Default is Info
        [ValidateSet("Error","Warning","Info")]
        [Alias("Level")]
        [string]$Severity="Info",

        # Defines if the Message should be passed through the pipeline.
        # Severity will be mapped to the corresponding Write-Verbose, Write-Warning
        # or Write-Error functions
        [Switch]$PassThru,

        # Defines if the message should be written as plain text message.
        # On default, System Center Configuration Manager log format is used.
        [Alias('AsText','a')]
        [Switch] $AsPlainText
    )

    begin {
        # Evaluate caller information
        $Caller = (Get-PSCallStack)[1]
        $Component = $Caller.Command
        $Source = $Caller.Location

        # Get Logpath from script/global level if not supplied explicitly
        # If no logpath is specified at all, write to current Temp folder
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = $Script:LogPath
            if ([string]::IsNullOrEmpty($Path)) {
                $Path = $Global:LogPath
                if ([string]::IsNullOrEmpty($Path)) {
                    if ([string]::IsNullOrEmpty($Source)) {
                        $LogName = [guid]::NewGuid().ToString()
                    } else {
                        if ($Source -like "*.*") {
                            $LogName = $Source.Split('\.')[0]
                        } else {
                            $LogName = $Source
                        }
                    }
                    $Path = Join-Path -Path $Env:TEMP -ChildPath "$LogName.log"
                }
            }
        }
    }

    process {
        # Make sure file and path exist
        if (-not(Test-Path $Path)) {
            Write-Verbose "Creating '$Path'."
            New-Item $Path -Force -ItemType File -ErrorAction SilentlyContinue | Out-Null
        }

        if ($AsPlainText) {
            $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $LogText = "$FormattedDate [$($Severity.ToUpper())] - $Message"
        } else {
            # Prepare ConfigMgr Log entry
            switch ($Severity) {
                "Error" { $Sev = 3 }
                "Warning" { $Sev = 2 }
                "Info" { $Sev = 1 }
            }

            # Get Timezone Bias to allign log entries through different timezones
            if ($null -eq $Script:TimezoneBias) {
                [int] $Script:TimezoneBias = Get-CimInstance -ClassName Win32_TimeZone -ErrorAction SilentlyContinue -Verbose:$false | Select-Object -ExpandProperty Bias
            }

            $Date = Get-Date -Format "MM-dd-yyyy"
            $Time = Get-Date -Format "HH:mm:ss.fff"
            $TimeString = "$Time$script:TimezoneBias"

            $LogText = "<![LOG[$Message]LOG]!><time=`"$TimeString`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Sev`" thread=`"0`" file=`"$Source`">"
        }

        # Write log entry to $Path
        $LogText | Out-File -FilePath $Path -Append -Force -Encoding default -NoClobber -ErrorAction SilentlyContinue

        # forward to pipeline
        if ($PassThru.IsPresent) {
            switch ($Severity) {
                "Error" { Write-Error $Message }
                "Warning" { Write-Warning $Message }
                "Info" { Write-Verbose $Message }
            }
        }
    }
}