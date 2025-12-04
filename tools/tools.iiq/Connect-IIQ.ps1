function Connect-IIQ {
    [CmdletBinding()]
    param (
        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory=$TRUE)]
        [string]$Token,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory=$TRUE)]
        [string]$Instance,

        [Parameter()]
        [switch]$PassThru
    )

    Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
    Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters)"
    #Write-Debug "ParameterSetName: $($PSCmdlet.ParameterSetName)"
    
    $headers = @{
        'Accept' = "application/json"
        'Content-Type' = "application/json"
        'Accept-Encoding' = "gzip, deflate"
        'Authorization' = "Bearer $Token"
    }

    Try {
        Write-Debug ""
        $response = Invoke-RestMethod "https://$Instance.incidentiq.com/api/v1.0/locations" -Method 'GET' -Headers $headers
        $location = $response.Items
    } Catch {
        Write-Error "Failed to connect to IIQ."
        Break
    }

    Write-Debug "Gathering information about your enviroment..."
    $global:IIQSession = @{
        Token           = $Token
        BaseURL         = "https://$Instance.incidentiq.com"
        Headers         = $headers
        Locations       = $location
        ModelCategorys  = $null
        CustomFields    = $null
    }
    $global:IIQSession.ModelCategorys = Get-IIQModelCategories
    $global:IIQSession.CustomFields = Get-IIQCustomFields

    If ($PassThru.IsPresent) {

        Return $global:IIQSession

    }

    Write-Host "IIQ Connected"

    Class iiqModelCategorys : System.Management.Automation.IValidateSetValuesGenerator {
        [string[]] GetValidValues() {
            return [string[]] $Global:IIQSession.ModelCategorys.Name
        }
    }
    
    Class iiqLocations : System.Management.Automation.IValidateSetValuesGenerator {
        [string[]] GetValidValues() {
            return [string[]] $Global:IIQSession.Locations.Name
        }
    }
    
    Class iiqCustomFields : System.Management.Automation.IValidateSetValuesGenerator {
        [string[]] GetValidValues() {
            return [string[]] $Global:IIQSession.CustomFields.Name
        }
    }

}