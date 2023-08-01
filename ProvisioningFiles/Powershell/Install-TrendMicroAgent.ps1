#requires -version 4.0

# instance should have acess to AWS secret key trendmicro

# PowerShell 4 or up is required to run this script
# This script detects platform and architecture.  It then downloads and installs the relevant Deep Security Agent package

if(!(Test-Path ("HKLM:SOFTWARE\TrendMicro\Deep Security Agent"))) {

    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
       Write-Warning "You are not running as an Administrator. Please try again with admin privileges."
       exit 1
    }
    
    if (!$env:path) {
       $env:path = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
    }
    $env:path = $env:path += ";C:\ProgramData\chocolatey\bin"
    $env:path = $env:path += ";C:\Program Files\Amazon\AWSCLIV2"
    choco install -y jq --no-progress
    refreshenv
    
    $managerUrl="https://app.deepsecurity.trendmicro.com:443/"
    
    $env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
    New-Item -path $env:LogPath -type directory
    Start-Transcript -path "$env:LogPath\dsa_deploy.log" -append
    
    Write-Output "$(Get-Date -format T) - DSA download started"
    if ( [intptr]::Size -eq 8 ) { 
       $sourceUrl=-join($managerUrl, "software/agent/Windows/x86_64/agent.msi") }
    else {
       $sourceUrl=-join($managerUrl, "software/agent/Windows/i386/agent.msi") }
    Write-Output "$(Get-Date -format T) - Download Deep Security Agent Package" $sourceUrl
    
    $ACTIVATIONURL="dsm://agents.deepsecurity.trendmicro.com:443/"
    
    aws --version
    jq --version
    
    $trendmicro_id = aws secretsmanager get-secret-value --secret-id "trendmicro" | jq -r .SecretString | jq -r .ID
    $trendmicro_token = aws secretsmanager get-secret-value --secret-id "trendmicro" | jq -r .SecretString | jq -r .Token
    
    $WebClient = New-Object System.Net.WebClient
    
    # Add agent version control info
    $WebClient.Headers.Add("Agent-Version-Control", "on")
    $WebClient.QueryString.Add("tenantID", "57898")
    $WebClient.QueryString.Add("windowsVersion", (Get-CimInstance Win32_OperatingSystem).Version)
    $WebClient.QueryString.Add("windowsProductType", (Get-CimInstance Win32_OperatingSystem).ProductType)
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    
    try {
        $WebClient.DownloadFile($sourceUrl,  "$env:temp\agent.msi")
    } 
    catch [System.Net.WebException] {
        Write-Output " Please check that your Workload Security Manager TLS certificate is signed by a trusted root certificate authority."
        exit 2;
    }
    
    if ( (Get-Item "$env:temp\agent.msi").length -eq 0 ) {
       Write-Output "Failed to download the Deep Security Agent. Please check if the package is imported into the Workload Security Manager. "
       exit 1
    }
    Write-Output "$(Get-Date -format T) - Downloaded File Size:" (Get-Item "$env:temp\agent.msi").length
    
    Write-Output "$(Get-Date -format T) - DSA install started"
    
    $agent_process = Start-Process $env:temp\agent.msi -ArgumentList "/quiet ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru
    Write-Output "$(Get-Date -format T) - Installer Exit Code: $agent_process.ExitCode"  
    Write-Output "$(Get-Date -format T) - DSA activation started"
    
    & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r 
    & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a $ACTIVATIONURL $trendmicro_id $trendmicro_token "policyid:1602" 
    Stop-Transcript
    Write-Output "$(Get-Date -format T) - DSA Deployment Finished"
    Write-Output "$(Get-Date -format T) - Starting services..."
    Start-Service -Name "ds_*"
    }
    else {Write-host "Trend Micro Agent already installed. Exiting..."}