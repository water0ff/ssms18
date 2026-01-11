$ErrorActionPreference = 'Stop'
function Get-Ssms18UninstallEntry {
  $paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  foreach ($p in $paths) {
    $app = Get-ItemProperty $p -ErrorAction SilentlyContinue |
      Where-Object { $_.DisplayName -like 'Microsoft SQL Server Management Studio - 18*' } |
      Select-Object -First 1
    if ($app) { return $app }
  }
  return $null
}
$app = Get-Ssms18UninstallEntry
if (-not $app) {
  Write-Host "SSMS 18 not found. Nothing to uninstall."
  return
}
$uninstallString = $app.UninstallString
if ([string]::IsNullOrWhiteSpace($uninstallString)) {
  throw "UninstallString not found for SSMS 18."
}
if ($uninstallString -notmatch '(?i)\s/quiet\b') {
  $uninstallString = "$uninstallString /quiet"
}
$cmdArgs = "/c $uninstallString"
Start-ChocolateyProcessAsAdmin -ExeToRun 'cmd.exe' -Statements $cmdArgs -ValidExitCodes @(0,3010,1605,1614,1641)