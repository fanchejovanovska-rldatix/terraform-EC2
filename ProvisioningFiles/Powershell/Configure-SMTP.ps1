Set-Service -Name 'SMTPSVC' -StartupType 'Automatic'
Start-Service -Name 'SMTPSVC'
  $iis = Get-WmiObject -Namespace "root\MicrosoftIISv2" -Class "IISSMTPServerSetting"
  $iis.LogType = 1
  $iis.AuthAnonymous = $true
  $iis.Put()
  $iis.AuthNTLM = $true
  $iis.RelayForAuth = $false
  $iis.SmartHost = "smtp.allocatesoftware.com"
  $iis.SmartHostType = 0
  $iis.Put()
  
  $ipblock = @(24,0,0,128,32,0,0,128,60,0,0,128,68,0,0,128,1,0,0,0,76,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,2,0,0,0,1,0,0,0,4,0,0,0,0,0,0,0,76,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255)
  $ipList = @()
  $octet = @()      
  $ipList = "127.0.0.1"
  $octet += $ipList.Split(".")
  $octet += Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName localhost | ? {$_.IPEnabled -eq $true} | % {($_.IPAddress -split ",")[0]} | % {$_ -split "\."}
  $ipblock[36] +=2 
  $ipblock[44] +=2;
  $smtpserversetting = get-wmiobject -namespace root\MicrosoftIISv2 -computername localhost -Query "Select * from IIsSmtpServerSetting"
  $ipblock += $octet
  $smtpserversetting.RelayIpList = $ipblock
  $smtpserversetting.put()
 