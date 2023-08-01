param(
    $Validation = "HMACSHA256",
    $Decryption = "AES"
)
Write-Host "Setting machine keys..."

Import-Module WebAdministration
  function generateKey($type, $GetCryptoBytes) {
	switch ($type) {	
		"SHA1" {
            [string]$NewKey = "0EEEFEC226D0493FA881481F57D6CA9A1FC2E4F936FBB094D61932CFDCA6CCD40B46DB382D5A25DCA5089D1E35D2946451E6D7B56E3A49AE8B53214C38F41787"
            #[string]$NewKey = $(GetCryptoBytes 64 -AsString)
        }
		"3DES" {
            [string]$NewKey = "BC6D03F8B526B57346E83AA5FD863A04F1711D48E76C77D5"
            #[string]$NewKey = $(GetCryptoBytes 24 -AsString)
        }
        "HMACSHA256" {
            [string]$NewKey = "CCD54C4E72DCA9433C9C7C10FB8CA1DA6BCB968BFBCD4D571FFD975B50BE2F4D21460E4574F3358C9C1B2B0F27E52824E8FDE6AA00E15E4B76DC37A1E7F92C667A8E7A2C7014741AC5C2969313F4A195DF023C4A18367B863DC4D0373D7D648FB652B21B438D93011BB1FFF53C49EF6E94E5827EA17682FC584A6400821E5F0E01EA11016104E7222588D728B88B97FB0FAE2930970BC5D79BDF127B238E99A48796776DE9BBE66DB1DF89BE9E16499BE8253C86F2B2B76BF8D14DBC895562DBED004B579B82A3D0407B8FAF9F142AE947F594FEA8E098E367D8038C6796865A9A6401B10A5B26FE4932353E471B41D9BE695FC61C4780DF33477A20FBCDA9C3"
            #[string]$NewKey = $(GetCryptoBytes 256 -AsString)
        }
        "AES" {
            [string]$NewKey = "DF01077BD933FB3BFADBDD19AECDCBF013BB493555F8A6C84010CFB8E78DC895"
            #[string]$NewKey = $(GetCryptoBytes 32 -AsString)
        }
	}
	return $NewKey
  }
  function GetCryptoBytes {
	param(
	   [Parameter(ValueFromPipeline=$true)]
	   [int[]]$count = 64,
	   [switch]$AsString
	)
	begin {$RNGCrypto = New-Object System.Security.Cryptography.RNGCryptoServiceProvider}
	process {
	   foreach($length in $count) {
		  $bytes = New-Object Byte[] $length
		  $RNGCrypto.GetBytes($bytes)
		  $formatedBytes = ($bytes | ForEach {"{0:X2}" -f $_}) -Join ""
          if($AsString){Write-Output $formatedBytes} else {Write-Output $bytes}
	   }
	}
	end {
	   $RNGCrypto = $null
	}
  }
  
  try {
	  $sitePath = 'IIS:\Sites\Default Web Site'
	  $mk = Get-WebConfiguration -Filter system.web/machineKey	  
	  $NewValidationKey = generateKey $Validation
	  $NewDecryptionKey = generateKey $Decryption
	  $mk.decryption = $Decryption
	  $mk.validation = $Validation
	  $mk.validationKey = $NewValidationKey
	  $mk.decryptionKey = $NewDecryptionKey
	  Set-WebConfigurationproperty -filter system.web/machineKey -PSPath $sitePath -Name decryption -Value $Decryption
	  Set-WebConfigurationproperty -filter system.web/machineKey -PSPath $sitePath -Name validation -Value $Validation 
	  Set-WebConfigurationproperty -filter system.web/machineKey -PSPath $sitePath -Name validationKey -Value $NewValidationKey 
	  Set-WebConfigurationproperty -filter system.web/machineKey -PSPath $sitePath -Name decryptionKey -Value $NewDecryptionKey
  }
  catch {Write-Host "Error";
    Write-Host $ERROR
  }