function ConvertTo-CesarCipher() {
    param($String)

    begin {
        $sb = New-Object System.Text.StringBuilder
    }

    process {
        $String.ToCharArray() | %{
            $null = $sb.Append([char](([int][char]$_) +1))            
        }
    }

    end {
        $sb.ToString()
    }
}

function ConvertFrom-CesarCipher() {
    param($String)

    begin {
        $sb = New-Object System.Text.StringBuilder
    }

    process {
        $String.ToCharArray() | %{
            $null = $sb.Append([char](([int][char]$_) -1))            
        }
    }

    end {
        $sb.ToString()
    }
}