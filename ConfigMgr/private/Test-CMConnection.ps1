
function Test-CMConnection {
    <#
    .SYNOPSIS
        Validates that a ConfigMgr connection has been created.

    .DESCRIPTION
        Validates that a ConfigMgr connection has been created. If not, a new Connection will be created.

    .EXAMPLE
        Get-WQLFilterString


    .NOTES

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    Param()
    if ( ([string]::IsNullOrWhiteSpace($global:CMProviderServer)) -or
            ([string]::IsNullOrWhiteSpace($global:CMSiteCode)) -or
            ([string]::IsNullOrWhiteSpace($global:CMNamespace)) -or
            ($null -eq $global:CMSession)) {

        New-CMConnection
        $true
    } else {
        $true
    }
}