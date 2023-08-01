Start-Transcript -Path "C:\ProvisioningFiles\Powershell\Complete-SqlInstall.log"
try{
    $iso = Get-ChildItem C:\ProvisioningFiles -Recurse -Filter *.iso*
    Mount-DiskImage -ImagePath $iso.FullName
    D:\setup.exe /SQLSYSADMINACCOUNTS=$env:COMPUTERNAME\build /ConfigurationFile=C:\ProvisioningFiles\Complete.ini
}
catch {Write-Host $ERROR}
Stop-Transcript