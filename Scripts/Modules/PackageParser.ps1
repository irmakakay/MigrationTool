
function Get-Packages {
    param($projectPath)

    $packages = @()
    $projectDir = Split-Path $projectPath
    $pkgConfig = Join-Path $projectDir "packages.config"

    if (Test-Path $pkgConfig) {
        [xml]$xml = Get-Content $pkgConfig
        foreach ($pkg in $xml.packages.package) {
            $packages += [PSCustomObject]@{
                Id      = $pkg.id
                Version = $pkg.version
            }
        }
    } else {
        [xml]$projXml = Get-Content $projectPath
        $projXml.Project.ItemGroup.PackageReference | ForEach-Object {
            $packages += [PSCustomObject]@{
                Id      = $_.Include
                Version = $_.Version
            }
        }
    }

    return $packages
}
