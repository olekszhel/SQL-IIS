$url = "https://dl.dropboxusercontent.com/s/ghx21onr3tcmyse/rewrite_2.0_rtw_x64.msi?dl=0"
$url_wd = "https://dl.dropboxusercontent.com/s/k7nzicd9s536720/WebDeploy_amd64_en-US.msi?dl=0"

$path = "c:\temp"
$output = "c:\temp\rewrite_2.0_rtw_x64.msi"
$output_wd = "c:\temp\WebDeploy_amd64_en-US.msi"

If(!(test-path $path))
{
   New-Item -ItemType Directory -Force -Path $path
   Write-Host
}

If(!(test-path $output))
{
   Write-Host "Downloading rewrite module..."
   $start_time = Get-Date
   Invoke-WebRequest -Uri $url -OutFile $output
   Write-Output "Time taken: $((Get-Date).Subtract($start_time))"
   Write-Host
}

If(!(test-path $output_wd))
{
   Write-Host "Downloading web deploy module..."
   $start_time = Get-Date
   Invoke-WebRequest -Uri $url_wd -OutFile $output_wd
   Write-Output "Time taken: $((Get-Date).Subtract($start_time))"
   Write-Host
}

## Install IIS
# $cmd = "$setupDriveLetter\Setup.exe /ConfigurationFile=c:\temp\ConfigurationFile.ini /SQLSVCPASSWORD=P2ssw0rd /SAPWD=P2ssw0rd"
Write-Host "Running IIS Install..."
Write-Host
#Invoke-Expression $cmd | Write-Host
Install-WindowsFeature -name Web-Server
Write-Host

## Install rewrite module

# Install URL Rewrite module in Windows Server 2016 for IIS

if ( $osversion -ge "10.0" ) {
	Write-Host "[!] urlrewrite.msi checks the Windows Server IIS version `
		in the registry. This fails on Server 2016. `
		So temporarily change IIS version in the registry."

	$registryPath = 'hklm:Software\Microsoft\InetStp'
Write-Host $registryPath
	$Name = "MajorVersion"
	$currentValue = (Get-ItemProperty "hklm:Software\Microsoft\InetStp").MajorVersion
	$newvalue = "7"
	New-ItemProperty -Path $registryPath -Name $name -Value $newvalue -PropertyType DWORD -Force | Out-Null
}

Write-Host "Running rewrite module Install..."
Write-Host
msiexec /package $output /passive

if ( $osversion -ge "10.0" ) {
	Write-Host "[!] Reset IIS version in the registry"

	$registryPath = "HKLM:\Software\Microsoft\InetStp"
	$Name = "MajorVersion"
	New-ItemProperty -Path $registryPath -Name $name -Value $currentvalue -PropertyType DWORD -Force | Out-Null
}

## Install Web Deploy module
Write-Host "Running Web Deploy module Install..."
Write-Host
msiexec /package $output_wd /passive