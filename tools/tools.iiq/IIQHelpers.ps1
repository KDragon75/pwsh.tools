Function ConvertTo-IIQGroupName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Type,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Name
    )
    Process {
        # iiq groups will be "iiq_{Type-Name} where spaces are replaced with dashes and (contents) are removed, the full CustomFieldValue is preseved as a description"
        # The following is a helper function to convert input strings into the above group name format
        [PSCustomObject]@{
            displayName = "iiq-$($Type)_$($Name -replace ' \(.*\)' -replace ' ', '-')"
            description = $Name
        }
    }
}