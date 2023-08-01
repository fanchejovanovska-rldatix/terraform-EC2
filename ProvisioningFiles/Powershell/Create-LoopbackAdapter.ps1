  $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
  & "devcon64.exe" install C:\Windows\inf\netloop.inf *msloop
  $adapter = (Get-WmiObject Win32_NetworkAdapter -Filter "Description LIKE 'Microsoft%Loopback Adapter'")
  $adapter.NetConnectionID = "Loopback"
  $adapter.put()
  $adapter.disable()
  $nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Description LIKE 'Microsoft%Loopback Adapter'"
  $nic.EnableStatic("172.16.250.250", "255.255.0.0")
  $nic.SetDynamicDNSRegistration($false)
  & "nvspbind.exe" /d "Loopback" ms_tcpip6