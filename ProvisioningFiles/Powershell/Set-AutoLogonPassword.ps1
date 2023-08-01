param($xmlPath,$password)
Start-Transcript -Path "C:\ProvisioningFiles\Powershell\Set-AutoLogonPassword.log" -Append
Write-Host "Setting autologon password for $xmlPath"
[xml]$xml= Get-Content $xmlPath
$xml.unattend.settings.component.autologon.password.value = $password
$xml.Save($xmlPath)
Stop-Transcript