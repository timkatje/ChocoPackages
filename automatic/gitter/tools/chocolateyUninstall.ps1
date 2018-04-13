$ErrorActionPreference = 'Stop'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    softwareName   = "gitter*" 
    fileType       = 'EXE'
    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
    validExitCodes = @(0)
}

[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs.softwareName
if ($key.Count -eq 1) {
    $key | ForEach-Object {
        $packageArgs.file = $_.UninstallString
        Uninstall-ChocolateyPackage @packageArgs
    }
}
elseif ($key.Count -eq 0) {
    Write-Warning "$packageName has already been uninstalled by other means."
}
elseif ($key.Count -gt 1) {
    Write-Warning "$key.Count matches found!"
    Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
    Write-Warning "Please alert package maintainer the following keys were matched:"
    $key | % {Write-Warning "- $_.DisplayName"}
}

# Remove the Start Menu shortcuts from the All Users profile we created at install
Remove-Item -Path (Join-Path -Path ([Environment]::GetFolderPath('CommonPrograms')) -ChildPath 'Gitter') -Recurse