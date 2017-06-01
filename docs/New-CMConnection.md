---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# New-CMConnection
## SYNOPSIS
Creates a new ConfigMgr connection.

## SYNTAX

```
New-CMConnection [[-ProviderServerName] <String>] [[-SiteCode] <String>] [[-Credential] <PSCredential>]
```

## DESCRIPTION
Creates a new ConfigMgr connection.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```

```

## PARAMETERS

### -ProviderServerName
Specifies the ConfigMgr Provider Server name.
If no value is specified, the script assumes to be executed on the Site Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ServerName, Name, SiteServer, ProviderServer

Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteCode
Specifies the ConfigMgr provider Site Code.
If no value is specified, the script will evaluate it from the Site Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Specifies the Credentials to connect to the Provider Server.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

