---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# New-CMInstance
## SYNOPSIS
Creates a new ConfigMgr object.

## SYNTAX

```
New-CMInstance [-ClassName] <String> [-Property] <Hashtable> [-ClientOnly] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a new ConfigMgr object.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```

```

## PARAMETERS

### -ClassName
Specifies the ConfigMgr WMI provider Class Name

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Property
Specifies the properties to be supplied to the new object

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientOnly
Specifies if the new instance shall be created on the client only.
Will be used for embedded classes without key property

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

