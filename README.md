[![Build status](https://ci.appveyor.com/api/projects/status/sn9cxw8h026yfpb4/branch/master?svg=true)](https://ci.appveyor.com/project/MKoster/testci/branch/master)


ConfigMgr Module
================

The "ConfigMgr" PowerShell module is used to directly access the ConfigMgr WMI provider.

As it doesn't have any further dependencies, it's a perfect fit for all scenarios, where ConfigMgr PowerShell scripts shall be used, but the ConfigMgr console can't be installed or used, or where a certain functionality is not availabe.

### Requirements

PowerShell Version 3.0+

## Install

### PowerShell Gallery Install (Requires PowerShell v5)

    Install-Module -Name ConfigMgr

See the [PowerShell Gallery](http://www.powershellgallery.com/packages/ConfigMgr/) for the complete details and instructions.

### Manual Install

Download [ConfigMgr.zip](https://github.com/MaikKoster/TestCI/releases/download/untagged-981d034668b73a9edb9f/ConfigMgr.zip) and extract the contents into `C:\Users\[User]\Documents\WindowsPowerShell\modules\ConfigMgr` (you may have to create these directories if they don't exist.)


## Contributors
* [MaikKoster](https://github.com/MaikKoster)

## License
* see [LICENSE](LICENSE.md) file

## Contact

* Twitter: [@Maik_Koster](https://twitter.com/Maik_Koster)
* Blog: [MaikKoster.com](http://MaikKoster.com/)
