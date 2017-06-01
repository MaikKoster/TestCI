---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Get-CMPackage
## SYNOPSIS
Gets a ConfigMgr package.

## SYNTAX

### ID (Default)
```
Get-CMPackage -ID <String> [-ParentID <String>] -Type <String>
```

### Name
```
Get-CMPackage -Name <String[]> [-Search] [-ParentID <String>] -Type <String>
```

### CIID
```
Get-CMPackage [-ParentID <String>] -CIID <String> -Type <String>
```

### Filter
```
Get-CMPackage [-ParentID <String>] -Filter <String>
```

## DESCRIPTION
Gets a ConfigMgr package.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```

```

## PARAMETERS

### -ID
Specifies the PackageID

```yaml
Type: String
Parameter Sets: ID
Aliases: PackageID

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
Specifies the Package Name
If Search is set, the name can include the default WQL placeholders \[\],^,% and _

```yaml
Type: String[]
Parameter Sets: Name
Aliases: PackageName

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Search
Specifies if Name contains a search string

```yaml
Type: SwitchParameter
Parameter Sets: Name
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentID
Specifies the Folder ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: FolderID, Folder

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -CIID
Specifies the CIID of assigned content.

```yaml
Type: String
Parameter Sets: CIID
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the Package Type

```yaml
Type: String
Parameter Sets: ID, Name, CIID
Aliases: PackageType

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Specifies a custom filter to use

```yaml
Type: String
Parameter Sets: Filter
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

