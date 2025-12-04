Function Get-IIQLocations {
    [CmdletBinding()]
    param ()

    Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
    #Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters)"
    #Write-Debug "ParameterSetName: $($PSCmdlet.ParameterSetName)"

    if (-not $global:IIQSession) {
        Throw "No IIQ sessions found. Use Connect-IIQ to establish a connection."
    }

    $response = Invoke-RestMethod "$($global:IIQSession.BaseURL)/api/v1.0/locations" -Method GET -Headers $global:IIQSession.Headers
    $response.items | Select-Object Name, Abbreviation, LocationId

}