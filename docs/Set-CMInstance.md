---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Set-CMInstance
## SYNOPSIS
Updates a ConfigMgr object.

## SYNTAX

### Instance (Default)
```
Set-CMInstance -InputObject <Object> -Property <Hashtable> [-PassThru] [-WhatIf] [-Confirm]
```

### Name
```
Set-CMInstance -ClassName <String> -Filter <String> -Property <Hashtable> [-PassThru] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Updates a ConfigMgr object.
The properties to update have to be supplied by the Property parameter.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$Pkg = Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
```

$Pkg | Set-CMInstance -Properties @{Description = "Update Me"}
Updates the Description of the specified ConfigMgr package.

### -------------------------- EXAMPLE 2 --------------------------
```
Set-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'" -Properties @{Description = "Update Me"}
```

Updates the Description of the specified ConfigMgr package.

## PARAMETERS

### -ClassName
Specifies the ConfigMgr WMI provider Class Name

```yaml
Type: String
Parameter Sets: Name
Aliases: Class

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Specifies the Filter

```yaml
Type: String
Parameter Sets: Name
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Specifies the ConfigMgr WMI provider object

```yaml
Type: Object
Parameter Sets: Instance
Aliases: ClassInstance

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Property
Specifies the properties to be set on the instance.
Should be a hashtable with key/name pairs.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies if updated object shall be returned

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

### -WhatIf
{{Fill WhatIf Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
{{Fill Confirm Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

