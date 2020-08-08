$ErrorActionPreference = 'Stop';


$packageName= 'azurepowershell'
$moduleVersion = [version]'6.10.0' # Define variable to detect if version is already installed

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url           = 'https://github.com/Azure/azure-powershell/releases/download/v6.10.0-October2018/Azure-Cmdlets-6.10.0.23377-x86.msi' # download url, HTTPS preferred
  url64         = 'https://github.com/Azure/azure-powershell/releases/download/v6.10.0-October2018/Azure-Cmdlets-6.10.0.23377-x64.msi' # 64bit URL here (HTTPS preferred) or remove - if installer contains both (very rare), use $url

  #softwareName  = 'NewMsiPackage*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique

  checksum      = '1427b61411c491625311f8151fc0350db3c74af6088ef9e555e128fa105a9942'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  checksum64    = '232ee32f9ced848ee04dbd511a8d2007a0230d41f0e69556ca5a63ade8943009'
  checksumType64= 'sha256'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes= @(
      0,    # success
      3010, # success, reboot required
      1641  # success, reboot initiated (overridden by /norestart flag above)
    )
}

# Load functions from helpers.ps1 script
. (Join-Path -Path $toolsDir -ChildPath helpers.ps1)

# Check for PowerShell 5.0+
Ensure-RequiredPowerShellVersionPresent -RequiredVersion '5.0'

# Verify that AzurePowershell module version isn't already installed
if (Test-AzurePowerShellInstalled -RequiredVersion $moduleVersion)
{
    return
}

#https://chocolatey.org/docs/helpers-install-chocolatey-package
Install-ChocolateyPackage @packageArgs

#Write-Warning 'You may need to close and reopen PowerShell before the Azure PowerShell modules become available.'



