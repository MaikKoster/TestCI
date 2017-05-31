# Update these to suit your PowerShell module build. These variables get dot sourced into
# the build at every run. The path root of the locations are assumed to be at the root of the
# PowerShell module project directory.

# The module we are building
$ModuleToBuild = 'ConfigMgr'

# Project website (used for external help cab file definition)
$ModuleWebsite = 'https://github.com/MaikKoster/TestCI'

# Public functions (to be exported by file name as the function name)
$PublicFunctionSource = "public"

# Private function source
$PrivateFunctionSource = "private"

# Other module source
$OtherModuleSource = "other"

# Release directory. You typically want a module to reside in a folder of the same name in order to publish to psgallery
# among other things.
$BaseReleaseFolder = 'release'

# Build tool path (these scripts are dot sourced)
$BuildToolFolder = 'build'

# Scratch path - this is where all our scratch work occurs. It will be cleared out at every run.
$ScratchFolder = 'artifacts'