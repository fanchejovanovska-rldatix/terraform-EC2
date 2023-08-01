$secret = Get-SECSecretValue -SecretId devops-build-account 
$password = ($secret.SecretString | ConvertFrom-Json).password
$username = ($secret.SecretString | ConvertFrom-Json).username
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
$script = 'C:\ProvisioningFiles\Powershell\Set-DefaultLanguage.ps1'
Start-Process -FilePath Powershell -RedirectStandardOutput output.txt -RedirectStandardError err.txt  -LoadUserProfile -Credential $credential -ArgumentList '-File', $script