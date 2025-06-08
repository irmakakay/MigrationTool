
function Convert-ToSdkStyle {
    param (
        [string]$projectPath,
        [string]$targetFramework,
        [bool]$backup = $true
    )

    if ($backup) {
        Copy-Item -Path $projectPath -Destination "$projectPath.backup" -Force
    }

    [xml]$xml = Get-Content $projectPath
    $xml.Project.RemoveAll()

    $projectNode = $xml.CreateElement("Project")
    $projectNode.SetAttribute("Sdk", "Microsoft.NET.Sdk")
    $xml.AppendChild($projectNode) | Out-Null

    $propGroup = $xml.CreateElement("PropertyGroup")
    $tf = $xml.CreateElement("TargetFramework")
    $tf.InnerText = $targetFramework
    $propGroup.AppendChild($tf) | Out-Null
    $projectNode.AppendChild($propGroup) | Out-Null

    $xml.Save($projectPath)
}

function Migrate-PackagesConfig {
    param (
        [string]$projectPath,
        [bool]$backup = $true
    )

    $projectDir = Split-Path $projectPath
    $pkgConfigPath = Join-Path $projectDir "packages.config"

    if (-not (Test-Path $pkgConfigPath)) {
        return
    }

    [xml]$pkgXml = Get-Content $pkgConfigPath
    [xml]$projXml = Get-Content $projectPath

    $itemGroup = $projXml.CreateElement("ItemGroup")

    foreach ($pkg in $pkgXml.packages.package) {
        $ref = $projXml.CreateElement("PackageReference")
        $ref.SetAttribute("Include", $pkg.id)
        $ref.SetAttribute("Version", $pkg.version)
        $itemGroup.AppendChild($ref) | Out-Null
    }

    $projXml.Project.AppendChild($itemGroup) | Out-Null
    $projXml.Save($projectPath)

    Remove-Item $pkgConfigPath -Force
}
