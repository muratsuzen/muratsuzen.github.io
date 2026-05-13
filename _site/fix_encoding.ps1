
$files = Get-ChildItem "C:\Project\blog\_posts\*.md"
foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    
    # Simple check for UTF-8 (this is not exhaustive but works for many cases)
    # We look for common Turkish characters in Windows-1254
    # Ç (0xC7), ğ (0xF0), ı (0xFD), ö (0xF6), ş (0xFE), ü (0xFC)
    # If these exist and are not part of valid UTF-8 sequences, it's likely 1254.
    
    $isUtf8 = $true
    try {
        $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
        $junk = $utf8.GetString($bytes)
    } catch {
        $isUtf8 = $false
    }
    
    if (-not $isUtf8) {
        Write-Host "Converting $($file.Name) from Windows-1254 to UTF-8"
        $enc1254 = [System.Text.Encoding]::GetEncoding(1254)
        $text = [System.IO.File]::ReadAllText($file.FullName, $enc1254)
        [System.IO.File]::WriteAllText($file.FullName, $text, (New-Object System.Text.UTF8Encoding($false)))
    } else {
        # Check if it contains replacement characters which might indicate it was already corrupted
        $text = [System.IO.File]::ReadAllText($file.FullName, (New-Object System.Text.UTF8Encoding($false)))
        if ($text.Contains("")) {
             Write-Host "$($file.Name) contains replacement characters, might be corrupted or mixed."
             # We might want to try 1254 anyway if it's mostly 1254
             $text1254 = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::GetEncoding(1254))
             # If text1254 looks better (less replacement characters), we use it
             # But for now, let's just report.
        }
        Write-Host "$($file.Name) is already UTF-8"
    }
}
