#import-module au

. $PSScriptRoot\..\..\scripts\all.ps1

$releases = 'https://github.com/Azure/azure-powershell/releases?after=AzureRM.Netcore.0.13.2-December2018'

function global:au_SearchReplace {
    @{
        '.\azurepowershell.nuspec' = @{
            # Update version numbers referenced in the <ReleaseNotes> section
            '(^[\d\.]+\d)(\:)'                                  = "$($Latest.Version)`$2"
            '(software\s+version\s+)([\d\.]+\d)'                = "`${1}$($Latest.SoftwareVersion)"
        }
        
        '.\tools\ChocolateyInstall.ps1' = @{
            # Update the $ModuleVersion variable with the latest version number
            '(^\s*\$moduleVersion\s*=\s*\[version\])(''.*'')'   = "`$1'$($Latest.SoftwareVersion)'"

            # Update the x86 file specifications
            '(^\s*\$url\s*=\s*)(''.*'')'                        = "`$1'$($Latest.Url32)'"
            '(^\s*\$checksum\s*=\s*)(''.*'')'                   = "`$1'$($Latest.Checksum32)'"
            '(^\s*\$checksumType\s*=\s*)(''.*'')'               = "`$1'$($Latest.ChecksumType32)'"

            # Update the x64 file specifications
            '(^\s*url64\s*=\s*)(''.*'')'                        = "`$1'$($Latest.Url64)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')"                 = "`$1'$($Latest.Checksum64)'"
            "(?i)(^\s*checksumType64\s*=\s*)('.*')"             = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

function global:au_BeforeUpdate() {
}

function global:au_AfterUpdate { 
    Set-DescriptionFromReadme -SkipFirst 2 
}

function global:au_GetLatest {
    $page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $regexUrl = '/download/[^/]+/azure-cmdlets\-(?<version>6\.\d+\.\d+)\.(?<revision>\d+)-'
    $urls = $page.links | Where-Object href -match $regexUrl | Select-Object -First 2 -expand href
    $version = $matches.version
    $rev = $matches.revision
    $baseUrl = "https://github.com"
    return @{
        SoftwareVersion = $version
        Version = $version
        Url64   = $baseUrl + $urls[0]
        Url32   = $baseUrl + $urls[1]
    }
}

update -ChecksumFor all
