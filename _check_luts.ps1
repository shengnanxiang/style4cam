$ErrorActionPreference = 'Stop'
$base = 'c:/Users/Nan/Documents/GitHub/style4cam/other luts'
$dirs = @('bw','colorslide','fujixtransiii','instant_consumer','instant_pro','negative_color','negative_new','negative_old','print','Fuji','Kodak','实验工艺系列')
$totalFiles = 0
$badFiles = 0
foreach ($d in $dirs) {
    $path = Join-Path $base $d
    if (-not (Test-Path -LiteralPath $path)) { Write-Output ("MISSING_DIR: {0}" -f $d); continue }
    $files = Get-ChildItem -LiteralPath $path -Filter *.cube
    $okCount = 0
    $badNames = @()
    foreach ($f in $files) {
        $lines = Get-Content -LiteralPath $f.FullName -Encoding UTF8
        $size = 0
        foreach ($l in $lines) {
            if ($l -match '^LUT_3D_SIZE\s+(\d+)') { $size = [int]$matches[1]; break }
        }
        $dataCount = 0
        foreach ($l in $lines) {
            $t = $l.Trim()
            if ($t -and $t -notmatch '^(#|//|TITLE|LUT_3D_SIZE|DOMAIN)') {
                $p = $t -split '\s+'
                if ($p.Count -ge 3) { $dataCount++ }
            }
        }
        $expected = $size * $size * $size
        if ($dataCount -eq $expected) { $okCount++ } else { $badNames += ($f.Name + "(size=$size data=$dataCount exp=$expected)") }
        $totalFiles++
    }
    Write-Output ("DIR={0}`tfiles={1}`tok={2}`tbad={3}" -f $d, $files.Count, $okCount, ($badNames.Count))
    foreach ($b in $badNames) { Write-Output ("   BAD: {0}" -f $b) }
    if ($badNames.Count) { $badFiles += $badNames.Count }
}
Write-Output ("TOTAL={0}`tBAD={1}" -f $totalFiles, $badFiles)
