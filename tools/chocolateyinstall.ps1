$ErrorActionPreference = 'Stop'
$packageName = 'ssms18'
$url = 'https://download.microsoft.com/download/8/a/8/8a8073d2-2e00-472b-9a18-88361d105915/SSMS-Setup-ENU.exe'
$silentArgs = '/Install /Quiet /NoRestart'
$checksum = 'B98E97B83E1068CE322999BE7585868815D3E8A7F2BD8D50A65B501DDC4F0103'
$checksumType = 'sha256'
$exePath = Join-Path $env:TEMP 'SSMS-Setup-ENU.exe'
Get-ChocolateyWebFile -PackageName $packageName `
  -FileFullPath $exePath `
  -Url $url `
  -Checksum $checksum `
  -ChecksumType $checksumType
function Test-Ssms18Installed {
  $paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  foreach ($p in $paths) {
    $hit = Get-ItemProperty $p -ErrorAction SilentlyContinue |
      Where-Object { $_.DisplayName -like 'Microsoft SQL Server Management Studio - 18*' } |
      Select-Object -First 1
    if ($hit) { return $true }
  }
  return $false
}
$proc = Start-Process -FilePath $exePath -ArgumentList $silentArgs -PassThru
$deadline = (Get-Date).AddMinutes(45)
while ((Get-Date) -lt $deadline) {
  if (Test-Ssms18Installed) {
    Write-Host "SSMS 18 detected as installed."
    try {
      if (!$proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    } catch {}
    return
  }
  Start-Sleep -Seconds 10
}
throw "SSMS 18 was not detected as installed within 45 minutes."