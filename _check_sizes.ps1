$ErrorActionPreference = 'Stop'
$base = 'c:/Users/Nan/Documents/GitHub/style4cam/other luts'
$dirs = @('bw','colorslide','fujixtransiii','instant_consumer','instant_pro','negative_color','negative_new','negative_old','print','Fuji','Kodak')
foreach ($d in $dirs) {
    $path = Join-Path $base $d
    $sizes = @{}
    Get-ChildItem -LiteralPath $path -Filter *.cube | ForEach-Object {
        $lines = Get-Content -LiteralPath $_.FullName -Encoding UTF8
        $size = 0
        foreach ($l in $lines) {
            if ($l -match '^LUT_3D_SIZE\s+(\d+)') { $size = [int]$matches[1]; break }
        }
        if ($sizes.ContainsKey($size)) { $sizes[$size]++ } else { $sizes[$size] = 1 }
    }
    $parts = ($sizes.GetEnumerator() | Sort-Object Name | ForEach-Object { "{0}x{1}" -f $_.Name, $_.Value }) -join ' '
    Write-Output ("{0}: {1}" -f $d, $parts)
}
