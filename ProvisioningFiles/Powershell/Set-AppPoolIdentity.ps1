Start-Transcript -Path "C:\ProvisioningFiles\Powershell\Set-AppPoolIdentity.log"
try{
    Import-Module WebAdministration

    Write-Host "Setting HealthRosterBUILD application pool identity"

    #secret requires WindowsCIAgent IAM role
    $secret = Get-SECSecretValue -SecretId devops-build-account 
    $password = ($secret.SecretString | ConvertFrom-Json).password
    $username = "build"

    Set-ItemProperty IIS:\AppPools\HealthRosterBUILD -name processModel -value @{userName=$username;password=$password;identitytype=3}
}
catch {Write-Host $ERROR}
Stop-Transcript