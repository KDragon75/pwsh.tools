Function Get-IIQModelCategories {
    [CmdletBinding()]
    Param()

    Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
    #Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters)"
    #Write-Debug "ParameterSetName: $($PSCmdlet.ParameterSetName)"

    if (-not $global:IIQSession) {
        Throw "No IIQ sessions found. Use Connect-IIQ to establish a connection."
    }
    
    $response = Invoke-WebRequest -Uri "$($global:IIQSession.BaseURL)/services/categories/of/models" -Method GET -Headers $global:IIQSession.Headers -SkipCertificateCheck -ErrorVariable httpError
    $categories = ($response.Content | ConvertFrom-JSON).items
    $categories | Select-Object Name, CategoryId, ModelsCount, AssetsCount | Where-Object {$_.ModelsCount -gt 0} | Sort-Object Name
    
}