function New-RandomPassword {
    [CmdletBinding()]
    param (
        [ValidateRange(5, 128)]
        [int]$Length = 6,
        [switch]$Upper,
        [switch]$Lower,
        [switch]$Number,
        [switch]$Special
    )
    
    begin {
        Write-Debug "$(Get-Date -Format 'M/d/yyyy h:mm:ss tt')  $($MyInvocation.MyCommand) Started execution."
        Write-Debug "$($MyInvocation.MyCommand) Parameters: $(ConvertTo-Json $MyInvocation.BoundParameters -Depth 5 -WarningAction SilentlyContinue)"
        # ACSII Ranges
        $upperASCII = (65..90)
        $lowerASCII = (97..122)
        $numberASCII = (48..57)

        # Need to place the ranges in ()
        $specialASCII = (33,35,36,37,38,40,41,42,43,45,46,47,91,92,93,94,95)
        # (33,(35..38),(40..43),(45..47),(91..95),127)

        # Build out the full ACSII List
        $usableASCII = @()
        $numTypes = 0
        
        # Add each ASCII range depending on the options set and count the number of required types i.e. number, upper, lower
        if ($Upper) {
            $usableASCII += $upperASCII
            $numTypes ++
        }
        if ($Lower) {
            $usableASCII += $lowerASCII
            $numTypes ++
        }
        if ($Number) {
            $usableASCII += $numberASCII
            $numTypes ++
        }
        if ($Special) {
            $usableASCII += $specialASCII
            $numTypes ++
        }
        

        # start iterations at 0
        $i = 0
    }
    
    process {
        # captuer the password as a string
        $string = (
            # Join each iteration into one string
            -join $(
                # while iteration is less less that the desired length less 1 incase we need to add an upper, lower, or special
                while ($i -lt ($Length - $numTypes)) {
                    # Pick a random number from our usable ASCSI list and lookup the char
                    $usableASCII | Get-Random | foreach {[char]$_}
                    # Increment befor the next iteration
                    $i++
                }
            )
        )

        [bool]$hasUpper = $false
        [bool]$hasLower = $false
        [bool]$hasNumber = $false
        [bool]$hasSpecial = $false

        foreach ($char in $string.ToCharArray()) {
            $asciiValue = [int][char]$char

            if ($asciiValue -in $upperASCII) {
                $hasUpper = $true
            }

            if ($asciiValue -in $lowerASCII) {
                $hasLower = $true
            }

            if ($asciiValue -in $numberASCII) {
                $hasNumber = $true
            }

            if ($char -in ($specialASCII | foreach {[char]$_})) {
                $hasSpecial = $true
            }

        }

        Write-Debug "Has Lower: $hasLower"
        Write-Debug "Has Upper: $hasUpper"
        Write-Debug "Has Number: $hasNumber"
        Write-Debug "Has Special: $hasSpecial"

        if (-not $hasUpper -and $Upper){
            $char = [char]($upperASCII | Get-Random)
            $string = $string.Insert((Get-Random -Minimum 0 -Maximum $string.Length),$char)
        }

        if (-not $hasLower -and $Lower){
            $char = [char]($lowerASCII | Get-Random)
            $string = $string.Insert((Get-Random -Minimum 0 -Maximum $string.Length),$char)
        }

        if (-not $hasSpecial -and $Special){
            $char = [char]($specialASCII | Get-Random)
            $string = $string.Insert((Get-Random -Minimum 0 -Maximum $string.Length),$char)
        }

        if (-not $hasNumber -and $Number){
            $char = [char]($numberASCII | Get-Random)
            $string = $string.Insert((Get-Random -Minimum 0 -Maximum $string.Length),$char)
        }

        while ($string.Length -lt $Length) {
            $char = [char]($usableASCII | Get-Random)
            $string = $string.Insert((Get-Random -Minimum 0 -Maximum $string.Length),$char)
        }

        $Password = ConvertTo-SecureString -AsPlainText -String $string
    }
    
    end {
        # Return the password as a [SecureString]
        Return $Password
    }
}