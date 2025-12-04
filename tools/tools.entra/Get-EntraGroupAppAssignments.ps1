 <#
 .SYNOPSIS
    Gets a list of all Intune applications assigned to that Entra group.
 .DESCRIPTION
    Used to help trace what apps are being deployed to a particuler device and why.
    
 .PARAMETER DisplayName
    The exact DisplayName of the Entra group.
 
 .EXAMPLE
    PS C:\> Get-EntraGroupAppAssignments -DisplayName dgrp_iPads-JJH-Student-WISC

AppName    Intent
-------    ------
TELLO EDU  required
Visuals2Go required

 #>
Function Get-EntraGroupAppAssignments {

    [CmdletBinding()]

    Param(

        [Parameter(Mandatory)]
        $DisplayName

    )

    Begin {

        Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
        Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters -Depth 5 -WarningAction SilentlyContinue)"

        Try {

            Import-Module Microsoft.Graph, wsd.tools
        
        } Catch {

            Throw "Unable to load Microsoft.Graph. Please run 'Install-Module Microsoft.Graph' to install."

        }

        # Authenticate to Microsoft Graph
        Try {

            Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.Read.All', 'DeviceManagementApps.Read.All', 'Group.Read.All' -NoWelcome

        } Catch {

            Throw "Failed to connect to MgGraph API Error: $_"

        }
    }

    Process {
        # Intune Group Lookup
        Try {
    
            $entraGroup = Get-MgGroup -Filter "DisplayName eq '$DisplayName'"

        If (-not $entraGroup) {

            Throw "No matching Entra group found for $DisplayName."

        }

        } Catch {

            Throw "Unable to find group $DisplayName Error: $_"

        }

        # App Search
        Try {

            $allApps = Get-MgDeviceAppManagementMobileApp -ExpandProperty Assignments

            $assignedApps = $allApps | Where-Object {$null -ne $_.Assignments.Id -and $entraGroup.Id -in ($_.Assignments.Id.split('_'))[0]}

            foreach ($app in $assignedApps) {

                $appAssignments = $app.Assignments | Where-Object {$entraGroup.Id -in ($_.Id.split('_'))[0]}

                [PSCustomObject]@{
                    AppName = $app.DisplayName
                    Intent  = $appAssignments.Intent
                }

            }

        } Catch {

            Throw "Error pulling an app list from Intune Error: $_"

        }
    }
}