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

Function Get-IIQDevices {
    [CmdletBinding()]
    param (
        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory=$TRUE, ValueFromPipeline=$TRUE, ParameterSetName = 'AssetTag')]
        [string[]]$AssetTag,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory=$TRUE, ValueFromPipeline=$TRUE, ParameterSetName = 'SerialNumber')]
        [string[]]$SerialNumber,

        [ValidateNotNullorEmpty()]
        [ValidateSet([iiqModelCategorys])]
        [Parameter(Mandatory=$False, ValueFromPipeline=$TRUE, ParameterSetName = 'Filter')]
        [string[]]$DeviceCategories,
        
        [ValidateNotNullorEmpty()]
        [ValidateSet([iiqLocations])]
        [Parameter(Mandatory=$False, ValueFromPipeline=$TRUE, ParameterSetName = 'Filter')]
        [string[]]$Locations,

        [ValidateNotNullorEmpty()]
        [ValidateSet([iiqCustomFields])]
        [Parameter(Mandatory=$False, ValueFromPipeline=$TRUE, ParameterSetName = 'Filter')]
        #[Parameter(ParameterSetName = 'CustomField')]
        [string]$CustomField,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory=$false, ValueFromPipeline=$TRUE, ParameterSetName = 'Filter')]
        #[Parameter(ParameterSetName = 'CustomField')]
        [string[]]$FieldValue

    )

    begin {
        Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
        Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters)"
        Write-Debug "ParameterSetName: $($PSCmdlet.ParameterSetName)"

        if (-not $global:IIQSession) {
            Throw "No IIQ sessions found. Use Connect-IIQ to establish a connection."
        }

    }

    process{

        try {

            switch ($PSCmdlet.ParameterSetName) {
                'AssetTag' {
                    $response = (Invoke-WebRequest -Uri "$($global:IIQSession.BaseURL)/api/v1.0/assets/assettag/$AssetTag" -Method GET -Headers $headers -ErrorVariable httpError).Content | ConvertFrom-Json
                }
                
                'SerialNumber' {
                    $response = (Invoke-WebRequest -Uri "$($global:IIQSession.BaseURL)/api/v1.0/assets/serial/$SerialNumber" -Method GET -Headers $headers -ErrorVariable httpError).Content | ConvertFrom-Json
                }

                'OwnerEmail' {
                    $response = (Invoke-WebRequest -Uri "$($global:IIQSession.BaseURL)/api/v1.0/assets/serial/$SerialNumber" -Method GET -Headers $headers -ErrorVariable httpError).Content | ConvertFrom-Json
                }

                'Filter' {
                    [System.Collections.Hashtable]$body = @{}
                    [System.Collections.ArrayList]$Filter = @{}

                    If ($DeviceCategories.Count -gt 0) {

                        [System.Collections.ArrayList]$categoryIds = @{}
                        foreach ($DeviceCategory in $DeviceCategories) {

                            Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Looking up device category $DeviceCategory ID."
                            $categoryIds.add( ($global:IIQSession.ModelCategorys | Where-Object {$_.Name -eq $DeviceCategory}).CategoryId )
                            Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) categoryIds $categoryIds"

                        }

                        Foreach ($categoryId in $categoryIds) {

                            $Filter.add(@{'Id' = $categoryId; 'Facet' = 'modelcategory'}) | out-null
                        }

                    }

                    
                    If ($Locations.Count -gt 0) {

                        [System.Collections.ArrayList]$locationIds = @{}
                        foreach ($Location in $Locations) {

                            Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Looking up location $Location ID."
                            $locationIds.add( ($global:IIQSession.Locations | Where-Object {$_.Name -eq $Location}).locationId )
                            Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) locationIds $locationIds"

                        }

                        Foreach ($locationId in $locationIds) {

                            $Filter.add(@{ 'Facet' = 'location'; 'Id' = $locationIds}) | out-null

                        }

                    }

                    If ($CustomField) {

                        $CustomFieldTypeId = ($Global:IIQSession.CustomFields | Where-Object {$_.Name -eq $CustomField}).CustomFieldTypeId
                        $Filter.add(@{ 'Facet' = 'assetcustomfield'; 'CustomFieldTypeId' = $CustomFieldTypeId; 'Value' = $FieldValue}) | out-null

                    }

                    $body.Add('Filters', $Filter)
                                    
                    Write-Debug "HTTP POST Body: $($body | ConvertTo-Json)"
                    $response = Invoke-RestMethod "$($global:IIQSession.BaseURL)/services/assets/?`$s=50000" -Method POST -Headers $global:IIQSession.headers -Body $($body | ConvertTo-Json) -SkipCertificateCheck -ErrorVariable httpError

                }
            }

        } catch {

            switch ($PSCmdlet.ParameterSetName) {

                'AssetTag' {
                    Write-Warning "Unable to lookup $AssetTag in IIQ Error: $_"
                }
                
                'SerialNumber' {
                    Write-Warning "Unable to lookup $SerialNumber in IIQ Error: $httpError.Message"
                }

                'Filter' {
                    Write-Warning "Unable to lookup devices in IIQ Error: $httpError.Message"
                }

            }

        }

        If ($response) {

            if ( $response.ItemCount -eq 0 ) {
                Write-Warning "No matching devices found."
            }

            return $response.items | Select-Object AssetTag, Name, SerialNumber, AssetId, CategoryId, CustomFieldValues, Location

        } else {

            throw $httpError.Message

        }

    }

}