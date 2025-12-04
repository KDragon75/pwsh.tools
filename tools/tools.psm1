# This is just the "module file" that will include all .ps1 files in this module

# Get a list of all files in the '.\' folder
$functionsToImport = Get-ChildItem -Path $PSScriptRoot -File -Filter '*.ps1' -Recurse

if ($functionsToImport.count -gt 0) {
    # For each file found, add its contents to the array $Scripts
    ForEach ($function in $functionsToImport) {
        Write-Debug "Importing $function"
        . $function
        #Export-ModuleMember -Function $($function.BaseName)
    }
}