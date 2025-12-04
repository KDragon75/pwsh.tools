Function Get-MgDeviceMacOSCustomAttributes {
    [CmdletBinding()]
    param ()
    
    $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCustomAttributeShellScripts"

    $CustomAttributeShellScripts = $response.value

    Return $CustomAttributeShellScripts | Select-Object DisplayName, ID

}

Function Get-MgDeviceMacOSCustomAttribute {
    [CmdletBinding()]
    param (

        [String]$DeviceName,
        [String]$CustomAttributeDisplayName

    )

    
    $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCustomAttributeShellScripts"

    $CustomAttributeShellScript = $response.value | Where-Object {$_.displayName -eq $CustomAttributeDisplayName}

    $intuneDevice = Get-MgDeviceManagementManagedDevice -Filter "DeviceName eq '$DeviceName'"

    $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCustomAttributeShellScripts/95d9037c-bf17-401c-af81-41714ea95027/deviceRunStates"

    Return ($response.value | Where-Object {$_.id -eq $CustomAttributeShellScript.id+':'+$intuneDevice.Id})

}