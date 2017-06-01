---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Get-CMInstance
## SYNOPSIS
Returns a ConfigMgr object.

## SYNTAX

```
Get-CMInstance [-ClassName] <String> [[-Filter] <String>] [-IncludeLazy]
```

## DESCRIPTION
Returns one or several ConfigMgr objects.
Results can be limited by a Filter.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-CMInstance -ClassName SMS_Package
```

Returns a list of ConfigMgr packages.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-CMInstance -ClassName SMS_Package -Filter "PackageID = 'TST00001'"
```

Returns a ConfigMgr Package with PackageID 'TST00001'.

## PARAMETERS

### -ClassName
Specifies the ConfigMgr WMI provider Class Name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Class

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Filter
Specifies the Where clause to filter the specified ConfigMgr WMI provider class.
If no filter is supplied, all objects will be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IncludeLazy
Specifies if the lazy properties shall be fetched as well.
On default, lazy properties won't be included in the result.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Lazy

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

