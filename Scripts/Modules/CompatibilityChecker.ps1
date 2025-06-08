
function Is-Compatible {
    param(
        [string]$id,
        [string]$version,
        [string]$targetFramework
    )

    $compatibilityMap = @{
        "net8.0"  = @("net8.0", "net7.0", "net6.0", "netstandard2.1", "netstandard2.0")
        "net6.0"  = @("net6.0", "net5.0", "netstandard2.1", "netstandard2.0")
        "net5.0"  = @("net5.0", "netcoreapp3.1", "netstandard2.1", "netstandard2.0")
        "netcoreapp3.1" = @("netcoreapp3.1", "netstandard2.1", "netstandard2.0")
    }

    $acceptableTargets = $compatibilityMap[$targetFramework]
    if (-not $acceptableTargets) {
        $acceptableTargets = @($targetFramework)
    }

    $url = "https://api.nuget.org/v3/registration5-semver1/$($id.ToLower())/index.json"
    try {
        $response = Invoke-RestMethod -Uri $url -UseBasicParsing
        foreach ($page in $response.items) {
            foreach ($pkg in $page.items) {
                if ($pkg.catalogEntry.version -eq $version) {
                    foreach ($group in $pkg.catalogEntry.dependencyGroups) {
                        if ($acceptableTargets -contains $group.targetFramework) {
                            return $true
                        }
                    }
                }
            }
        }
        return $false
    } catch {
        return $false
    }
}
