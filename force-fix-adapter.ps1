# Force Fix VirtualBox Host-Only Adapter
# Run as Administrator
# This creates the actual Windows network device

Write-Host "=== VirtualBox Host-Only Adapter Fix ===" -ForegroundColor Cyan
Write-Host ""

$vboxPath = "C:\Program Files\Oracle\VirtualBox"
$vboxManage = Join-Path $vboxPath "VBoxManage.exe"

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Must run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "[1/6] Stopping VirtualBox processes..." -ForegroundColor Yellow
Get-Process VBox* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Write-Host "✅ Done" -ForegroundColor Green
Write-Host ""

Write-Host "[2/6] Removing old VirtualBox host-only adapters..." -ForegroundColor Yellow
$oldAdapters = & $vboxManage list hostonlyifs 2>&1 | Select-String "Name:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
foreach ($adapter in $oldAdapters) {
    Write-Host "  Removing: $adapter" -ForegroundColor Gray
    & $vboxManage hostonlyif remove $adapter 2>&1 | Out-Null
}
Write-Host "✅ Done" -ForegroundColor Green
Write-Host ""

Write-Host "[3/6] Uninstalling VirtualBox network driver..." -ForegroundColor Yellow
cd "$vboxPath\drivers\network\netadp6"
$drivers = pnputil /enum-drivers | Select-String "oem.*\.inf" | ForEach-Object { $_.Matches.Value }
foreach ($driver in $drivers) {
    $driverInfo = pnputil /enum-drivers | Select-String -Context 0,3 $driver
    if ($driverInfo -match "VBoxNetAdp") {
        Write-Host "  Removing driver: $driver" -ForegroundColor Gray
        pnputil /delete-driver $driver /uninstall /force 2>&1 | Out-Null
    }
}
Write-Host "✅ Done" -ForegroundColor Green
Write-Host ""

Write-Host "[4/6] Reinstalling VirtualBox network driver..." -ForegroundColor Yellow
$result = pnputil /add-driver VBoxNetAdp6.inf /install
Write-Host $result -ForegroundColor Gray
Write-Host "✅ Done" -ForegroundColor Green
Write-Host ""

Write-Host "[5/6] Creating new host-only adapter..." -ForegroundColor Yellow
$createResult = & $vboxManage hostonlyif create 2>&1
Write-Host $createResult -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host "✅ Done" -ForegroundColor Green
Write-Host ""

Write-Host "[6/6] Verifying adapter in Windows..." -ForegroundColor Yellow
$windowsAdapter = Get-NetAdapter | Where-Object {$_.Name -like "*VirtualBox*" -or $_.DriverDescription -like "*VirtualBox*"}

if ($windowsAdapter) {
    Write-Host "✅ SUCCESS! Adapter found in Windows:" -ForegroundColor Green
    Write-Host "  Name: $($windowsAdapter.Name)" -ForegroundColor Cyan
    Write-Host "  Status: $($windowsAdapter.Status)" -ForegroundColor Cyan
    Write-Host "  Driver: $($windowsAdapter.DriverDescription)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=== Fix Complete! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  cd C:\code\oci-devops-lab" -ForegroundColor White
    Write-Host "  vagrant destroy -f" -ForegroundColor White
    Write-Host "  vagrant up" -ForegroundColor White
} else {
    Write-Host "⚠️ Adapter created in VirtualBox but not visible in Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "VirtualBox view:" -ForegroundColor Cyan
    & $vboxManage list hostonlyifs
    Write-Host ""
    Write-Host "Windows view:" -ForegroundColor Cyan
    Get-NetAdapter | Select-Object Name, Status, DriverDescription | Format-Table
    Write-Host ""
    Write-Host "Recommended: Reboot Windows and retry" -ForegroundColor Yellow
    Write-Host "  Restart-Computer" -ForegroundColor White
}
