---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Invoke-CMMethod

## SYNOPSIS
Invokes a ConfigMgr provider method.

## SYNTAX

### ClassName (Default)
```
Invoke-CMMethod -ClassName <String> -MethodName <String> [-Arguments <Hashtable>] [-SkipValidation] [-WhatIf]
 [-Confirm]
```

### ClassInstance
```
Invoke-CMMethod -InputObject <Object> -MethodName <String> [-Arguments <Hashtable>] [-SkipValidation] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
Invokes a ConfigMgr provider method.

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
Needs to be supplied for static class methods

```yaml
Type: String
Parameter Sets: ClassName
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Specifies the ConfigMgr WMI provider object
Needs to be supplied for instance methods

```yaml
Type: Object
Parameter Sets: ClassInstance
Aliases: ClassInstance

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MethodName
Specifies the Method Name

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Arguments
Specifies the Arguments to be supplied to the method.
Should be a hashtable with key/name pairs.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipValidation
If set, ReturnValue will not be evaluated
Usefull if ReturnValue does not indicated successfull execution

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
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

