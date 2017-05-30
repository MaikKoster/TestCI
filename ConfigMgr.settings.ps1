###############################################################################
# Customize these properties and tasks
###############################################################################
param(
    $Artifacts = './artifacts',
    $ModuleName = 'ConfigMgr',
    $ModulePath = './ConfigMgr',
    $BuildNumber = $env:BUILD_NUMBER,
    $PercentCompliance  = '60'
)

###############################################################################
# Static settings -- no reason to include these in the param block
################################s###############################################
$Settings = @{
    SMBRepoName = 'DSCGallery'
    SMBRepoPath = '\\Server01\Repo'

    Author =  "Maik Koster"
    Owners = "Maik Koster"
    LicenseUrl = 'https://github.com/MaikKoster/TestCI/blob/master/LICENSE'
    ProjectUrl = "https://github.com/MaikKoster/TestCI"
    PackageDescription = "PowerShell module to directly access the ConfigMgr WMI provider"
    Repository = 'https://github.com/MaikKoster/TestCI.git'
    Tags = ""

    # TODO: fix any redudant naming
    GitRepo = "MaikKoster/TestCI"
    #CIUrl = "http://jenkins/job/PSHitchhiker/"
}

###############################################################################
# Before/After Hooks for the Core Task: Clean
###############################################################################

# Synopsis: Executes before the Clean task.
task BeforeClean {}

# Synopsis: Executes after the Clean task.
task AfterClean {}

###############################################################################
# Before/After Hooks for the Core Task: Analyze
###############################################################################

# Synopsis: Executes before the Analyze task.
task BeforeAnalyze {}

# Synopsis: Executes after the Analyze task.
task AfterAnalyze {}

###############################################################################
# Before/After Hooks for the Core Task: Archive
###############################################################################

# Synopsis: Executes before the Archive task.
task BeforeArchive {}

# Synopsis: Executes after the Archive task.
task AfterArchive {}

###############################################################################
# Before/After Hooks for the Core Task: Publish
###############################################################################

# Synopsis: Executes before the Publish task.
task BeforePublish {}

# Synopsis: Executes after the Publish task.
task AfterPublish {}

###############################################################################
# Before/After Hooks for the Core Task: Test
###############################################################################

# Synopsis: Executes before the Test Task.
task BeforeTest {}

# Synopsis: Executes after the Test Task.
task AfterTest {}