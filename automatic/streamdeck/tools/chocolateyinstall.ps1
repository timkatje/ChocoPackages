﻿$ErrorActionPreference = 'Stop';

$packageName  = 'streamdeck'
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64        = 'https://edge.elgato.com/egc/windows/sd/Stream_Deck_1.2.1.1232.msi'

. "$toolsDir\PSPackageExtensions.ps1"

$tempName     = Get-ChocoUniqueTempName 

$packageArgs = @{
  packageName     = $packageName
  fileType        = 'MSI'
  fileFullPath    = ""
  url64           = $url64
  softwareName    = 'Elgato Stream Deck*'

  checksum64      = 'b5add4d3d05393ccf7034e355fa41b918441c0462e4235af52f9a4515a745d43'
  checksumType64  = 'SHA256'

  silentArgs      = "/quiet"
  validExitCodes  = @(0, 3010, 1641)
}
$packageArgs.fileFullPath = Join-Path -Path (get-ChocoUniqueTempName) -ChildPath "$packageName.$($packageArgs.fileType.ToLower())"

write-debug "OS Name: $($env:OS_NAME)"
if ($env:OS_NAME -ne "Windows 10") {
    throw "Cannot be installed on this version of Windows - $packageName only supports Windows 10 x64 ($($env:OS_NAME))."
}

$ahkExe = 'AutoHotKey'
$ahkFile = Join-Path $toolsDir "$($packageName)Install.ahk"
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList $ahkFile -PassThru
$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

Get-ChocolateyWebFile @packageArgs 
Install-ChocolateyInstallPackage @packageArgs