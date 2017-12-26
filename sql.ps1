param
(
   [String]
   $WinSources='d:\windows\sxs',

   [Parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [String]
   $domAccount
)

Write-Host
Write-Host "Please type: sql.ps1 -WinSources <path-to-src> to change source directory"
Write-Host

$url = "https://dl.dropboxusercontent.com/s/r8bk89s3tc40lbd/SQLServer2016SP1-FullSlipstream-x64-ENU.iso?dl=0"
$url_ini = "https://dl.dropboxusercontent.com/s/cyg2fcikpuxhfp8/ConfigurationFile.ini?dl=0"
$url_smss = "https://dl.dropboxusercontent.com/s/tg8knuntyy576uh/SSMS-Setup-ENU.exe?dl=0"
$path = "c:\temp"
$output = "c:\temp\SQLServer2016SP1-FullSlipstream-x64-ENU.iso"
$output_ini = "c:\temp\ConfigurationFile.ini"
$output_smss = "c:\temp\SSMS-Setup-ENU.exe"


If(!(test-path $path))
{
   New-Item -ItemType Directory -Force -Path $path
   Write-Host
}

If(!(test-path $output))
{
   Write-Host "Downloading MSSQL..."
   $start_time = Get-Date
   Invoke-WebRequest -Uri $url -OutFile $output
   Write-Output "Time taken: $((Get-Date).Subtract($start_time))"
   Write-Host
}


if (Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 393295 })
{
   Write-Host 'NET Framework -- Intalled'
   Write-Host
}
else
{
   Install-WindowsFeature NET-Framework-45-Core -source $WinSources
}

if ($PSVersionTable.PSVersion.Major -ge 3)
{
   Write-Host 'Powershell -- Installed'
   Write-Host
}
else
{
   Write-Host 'ERROR: You have to install Powershell v3 or higher!'
   break
}

# copy the ini file to the temp folder
If(!(test-path $output_ini))
{
   Write-Host "Downloading config..."
   $start_time = Get-Date
   Invoke-WebRequest -Uri $url_ini -OutFile $output_ini
   Write-Output "Time taken: $((Get-Date).Subtract($start_time))"
   Write-Host
}

# copy SMSS installer to the temp folder
If(!(test-path $output_smss))
{
   Write-Host "Downloading SMSS..."
   $start_time = Get-Date
   Invoke-WebRequest -Uri $url_smss -OutFile $output_smss
   Write-Output "Time taken: $((Get-Date).Subtract($start_time))"
}


# Alias           % -> ForEach-Object                                            
# Alias           ? -> Where-Object
# Alias           gwmi -> Get-WmiObject
#                 @{} -- array

$sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql" -and $_.PathName -match "sqlservr.exe" } | % { $_.Name }
$res = $sqlInstances -ne $null -and $sqlInstances -gt 0
$vals = @{
Installed = $res;
InstanceCount = $sqlInstances.count
}
$vals
Write-Host



$sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql" -and $_.PathName -match "sqlservr.exe" } | % { $_.Name }
$res = $sqlInstances -ne $null -and $sqlInstances -gt 0
if ($res) {
   Write-Host "SQL Server is already installed"
   Write-Host
   }
else
{
   # Mount the iso
   $setupDriveLetter = (Mount-DiskImage -ImagePath c:\temp\SQLServer2016SP1-FullSlipstream-x64-ENU.iso -PassThru | Get-Volume).DriveLetter + ":"
   if ($setupDriveLetter -eq $null) {
   throw "Could not mount SQL install iso"
   }
   Write-Host "Drive letter for iso is: $setupDriveLetter"
   Write-Host
   Write-Host "SQL Server is not installed"
   Write-Host
   # Run the installer using the ini file
   $cmd = "$setupDriveLetter\Setup.exe /ConfigurationFile=c:\temp\ConfigurationFile.ini /ADDCURRENTUSERASSQLADMIN=$domAccount /SQLSVCPASSWORD=P2ssw0rd /SAPWD=P2ssw0rd"
   Write-Host "Running SQL Install - check %programfiles%\Microsoft SQL Server\120\Setup Bootstrap\Log\ for logs..."
   Write-Host
   Invoke-Expression $cmd | Write-Host
}


# Run the SMSS installer

$cmd = "$output_smss /install /passive /norestart"

Write-Host "Running SMSS Install..."
Write-Host
Invoke-Expression $cmd | Write-Host
Write-Host "Use sa P2ssw0rd to access MSSQL"