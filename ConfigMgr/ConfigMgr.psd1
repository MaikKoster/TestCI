@{

    RootModule = 'ConfigMgr.psm1'
    ModuleVersion = '0.1.35'
    GUID = '9ad632f2-7a0e-48a3-8d62-3b44c063e0f4'
    Author = 'Maik Koster'
    CompanyName = 'Maik Koster'
    Copyright = '(c) 2017 Maik Koster. All rights reserved.'
    Description = 'The ConfigMgr PowerShell module is used to directly access the ConfigMgr WMI provider.'
    PowerShellVersion = '3.0'

    HelpInfoURI = 'http://github.com/MaikKoster/TestCI/blob/master/ConfigMgr/en-US/'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Functions to export from this module
# FunctionsToExport = @()

# Cmdlets to export from this module
# CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module
# AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("SCCM", "ConfigMgr", "Configuration Manager")

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/MaikKoster/TestCI/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/MaikKoster/TestCI'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable


}

