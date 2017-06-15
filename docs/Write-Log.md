---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Write-Log

## SYNOPSIS
Write-Log writes a message to a specified log file with the current time stamp.
Test

## SYNTAX

```
Write-Log [-Message] <String> [[-Path] <String>] [[-Severity] <String>] [-PassThru] [-AsPlainText]
```

## DESCRIPTION
The Write-Log function is designed to add logging capability to other scripts.
In addition to writing output and/or verbose you can write to a log file for
later debugging.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Write-Log -Message 'Log message'
```

Writes the message to c:\Logs\PowerShellLog.log.

### -------------------------- EXAMPLE 2 --------------------------
```
Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
```

Writes the content to the specified log file and creates the path and file specified.

### -------------------------- EXAMPLE 3 --------------------------
```
Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
```

Writes the message to the specified log file as an error message, and writes the message to the error pipeline.

## PARAMETERS

### -Message
Defines the content that should be added to the log file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: LogContent

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
The path to the log file to which the Message shall be written.
Path and file will be created if it does not exist.
If omitted function will use the $LogPath variable defined on script or global level.
If that isn't set as well, function will fail

```yaml
Type: String
Parameter Sets: (All)
Aliases: LogPath

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
Defines the criticality of the log information being written to the log.
Can be any of Error, Warning, Informational
Default is Info

```yaml
Type: String
Parameter Sets: (All)
Aliases: Level

Required: False
Position: 3
Default value: Info
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Defines if the Message should be passed through the pipeline.
Severity will be mapped to the corresponding Write-Verbose, Write-Warning
or Write-Error functions

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsPlainText
Defines if the message should be written as plain text message.
On default, System Center Configuration Manager log format is used.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: AsText, a

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Let's add some notes

## RELATED LINKS

