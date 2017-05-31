---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# Get-CMUserDeviceAffinity
## SYNOPSIS
Gets user device affinities

## SYNTAX

### ResourceID (Default)
```
Get-CMUserDeviceAffinity -ResourceID <String[]> [-Source <String>]
```

### ID
```
Get-CMUserDeviceAffinity -ID <String[]> [-Source <String>]
```

### Name
```
Get-CMUserDeviceAffinity [-ResourceName <String[]>] [-UserName <String[]>] [-Search] [-Source <String>]
```

## DESCRIPTION
The Get-CMUserDeviceAffinity cmdlet gets one or more user device affinities.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```

```

## PARAMETERS

### -ID
Specifies the Relationship ID

```yaml
Type: String[]
Parameter Sets: ID
Aliases: RelationshipResourceID

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourceID
Specifies the DeviceID (ResourceID)

```yaml
Type: String[]
Parameter Sets: ResourceID
Aliases: DeviceID

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ResourceName
Specifies the Device name
If Search is set, the name can include the default WQL placeholders \[\],^,% and _

```yaml
Type: String[]
Parameter Sets: Name
Aliases: DeviceName

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName
Specifies the User name
If Search is set, the name can include the default WQL placeholders \[\],^,% and _

```yaml
Type: String[]
Parameter Sets: Name
Aliases: 

Required: False
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

### -Source
Specifies the Affinity Source

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

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

