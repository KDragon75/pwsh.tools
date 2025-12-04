Function Get-IIQCustomFields {
    [CmdletBinding()]
    Param()

    Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."

    if (-not $global:IIQSession) {
        Throw "No IIQ sessions found. Use Connect-IIQ to establish a connection."
    }
    
    $response = Invoke-RestMethod "$($global:IIQSession.BaseURL)/api/v1.0/custom-fields/types" -Method 'GET' -Headers $global:IIQSession.Headers
    $response.items | Select-Object Name, CustomFieldTypeId, Description, OwnerAppId, @{Name = 'Options'; Expression = {$_.Options -replace "\[|\]" -replace '"' -split ','}} | Sort-Object Name

}