Start-Transcript -Path "C:\ProvisioningFiles\Powershell\Set-DefaultLanguage.log" -Append
Write-Host $env:USERNAME
$1 = New-WinUserLanguageList en-GB
$1[0].Handwriting = 1
Set-WinUserLanguageList $1 -force
Set-WinSystemLocale en-GB
Get-WinUserLanguageList
Stop-Transcript
