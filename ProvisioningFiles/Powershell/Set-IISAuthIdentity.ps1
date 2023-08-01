[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration, Version=7.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL")
$iis = [Microsoft.Web.Administration.ServerManager]::OpenRemote("Localhost")
Import-Module webadministration
Write-Host "Setting IIS anonymous auth to app pool identity"
$conf = $iis.GetApplicationHostConfiguration()
$sectionGroup = $conf.RootSectionGroup.SectionGroups['system.webserver'].sectionGroups['security'].sectionGroups['authentication']
$section = $sectionGroup.sections['anonymousAuthentication']
$section.OverrideModeDefault = "Allow"
$iis.CommitChanges()

Set-WebConfigurationProperty -Filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites\Default Web Site" -Name Enabled  -Value $true
Set-WebConfigurationProperty -Filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites\Default Web Site" -Name userName  -Value ""

$iis.Sites["Default Web Site"].Applications | % {
    Set-WebConfigurationProperty -Filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites\Default Web Site\$($_.Name)" -Name Enabled  -Value $true
    Set-WebConfigurationProperty -Filter system.webServer/security/authentication/anonymousAuthentication -PSPath "IIS:\Sites\Default Web Site\$($_.Name)" -Name userName  -Value ""
}

