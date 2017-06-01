---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Remove-CMInstance
## SYNOPSIS
Removes a ConfigMgr object.

## SYNTAX

### ClassInstance (Default)
```
Remove-CMInstance -InputObject <Object> [-WhatIf] [-Confirm]
```

### ClassName
```
Remove-CMInstance -ClassName <String> -Filter <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Removes a ConfigMgr object.
If the object is specified by Classname and filter, make sure it returns a unique object.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
```

Removes the ConfigMgr package with PackageID 'TST00001'.

### -------------------------- EXAMPLE 2 --------------------------
```
$Pkg = Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
```

$Pkg | Remove-CMInstance
Removes the ConfigMgr package with PackageID 'TST00001'.

## PARAMETERS

### -ClassName
Specifies the ConfigMgr WMI provider Class Name

```yaml
Type: String
Parameter Sets: ClassName
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Specifies the Filter

```yaml
Type: String
Parameter Sets: ClassName
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObject
Specifies the ConfigMgr WMI provider object

```yaml
Type: Object
Parameter Sets: ClassInstance
Aliases: ClassInstance

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
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

