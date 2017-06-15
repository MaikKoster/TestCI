---
external help file: ConfigMgr-help.xml
online version: 
schema: 2.0.0
---

# New-CMUserDeviceAffinity

## SYNOPSIS
Creates a new User device affinity

## SYNTAX

```
New-CMUserDeviceAffinity [-ResourceID] <UInt32> [-UserName] <String> [[-Source] <String>] [-NoType] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
The New-CMUserDeviceAffinity cmdlet creates a new user device affinity.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser"
```

Creates a new user device affinity for the specified Resource and User

### -------------------------- EXAMPLE 2 --------------------------
```
New-CMUserDeviceAffinity -ResourceID 1 -UserName "TST\Testuser" -Source Administrator
```

Creates a new user device affinity for the specified Resource, User and Source

## PARAMETERS

### -ResourceID
Specifies the DeviceID (ResourceID)

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: DeviceID

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UserName
Specifies the User name
e.g.
"{Domain}\{samaccountname}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Source
Specifies the Package Type

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: Administrator
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoType
Specifies if the Type property should be set for the relationship

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

