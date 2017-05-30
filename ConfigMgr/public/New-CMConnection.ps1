function New-CMConnection {
    <#
    .SYNOPSIS
        Creates a new ConfigMgr connection.

    .DESCRIPTION
        Creates a new ConfigMgr connection.

    .EXAMPLE


    .NOTES

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    PARAM (
        # Specifies the ConfigMgr Provider Server name.
        # If no value is specified, the script assumes to be executed on the Site Server.
        [Alias("ServerName", "Name", "SiteServer" ,"ProviderServer")]
        [string]$ProviderServerName = $env:COMPUTERNAME,

        # Specifies the ConfigMgr provider Site Code.
        # If no value is specified, the script will evaluate it from the Site Server.
        [string]$SiteCode,

        # Specifies the Credentials to connect to the Provider Server.
        [PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Process {
        # Get or Create session object to connect to currently provided Providerservername
        # Ensure processing stops if it fails to create a session
        $SessionParams = @{
            ErrorAction = "Stop"
            ComputerName = $ProviderServerName
        }

        if ($PSBoundParameters["Credential"]) {
            $SessionParams.Credential = $Credential
        }

        $CMSession = Get-CMSession @SessionParams

        # Get Provider location
        If ($null -ne $CMSession) {
            $ProviderLocation = $null
            If ($SiteCode -eq $null -or $SiteCode -eq "") {
                Write-Verbose "Get provider location for default site on server $ProviderServerName"
                $ProviderLocation = Invoke-CimCommand {Get-CimInstance -CimSession $CMSession -Namespace "root\sms" -ClassName SMS_ProviderLocation -Filter "ProviderForLocalSite = true" -ErrorAction Stop}
            } Else {
                Write-Verbose "Get provider location for site $SiteCode on server $ProviderServerName"
                $ProviderLocation = Invoke-CimCommand {Get-CimInstance -CimSession $CMSession -Namespace "root\sms" -ClassName SMS_ProviderLocation -Filter "SiteCode = '$SiteCode'" -ErrorAction Stop}
            }

            If ($null -ne $ProviderLocation) {
                # Split up the namespace path
                $Parts = $ProviderLocation.NamespacePath -split "\\", 4
                Write-Verbose "Provider is located on $($ProviderLocation.Machine) in namespace $($Parts[3])"

                # Set Script variables used by ConfigMgr related functions
                $global:CMProviderServer = $ProviderLocation.Machine
                $global:CMNamespace = $Parts[3]
                $global:CMSiteCode = $ProviderLocation.SiteCode
                $global:CMCredential = $Credential

                # Create and store session if necessary
                If ($global:CMProviderServer -ne $ProviderServerName) {
                    $SessionParams.ComputerName = $global:CMProviderServer
                    $CMSession = Get-CMSession @SessionParams
                }

                If ($null -eq $CMSession) {
                    Throw "Unable to establish CIM session to $global:CMProviderServer"
                } Else {
                    $global:CMSession = $CMSession
                }
            } Else {
                # Clear global variables
                $global:CMProviderServer = [string]::Empty
                $global:CMNamespace = [string]::Empty
                $global:CMSiteCode = [string]::Empty
                $global:CMCredential = $null

                Throw "Unable to connect to specified provider"
            }
        } Else {
            # Clear global variables
            $global:CMProviderServer = [string]::Empty
            $global:CMNamespace = [string]::Empty
            $global:CMSiteCode = [string]::Empty
            $global:CMCredential = $null

            Throw "Unable to create CIM session to $ProviderServerName"
        }
    }
}