param (
    [string]$SolutionFolder,
    [string]$TargetFramework
)

$ErrorActionPreference = "Stop"

# Import modules
. "$PSScriptRoot\Modules\Utility.ps1"
. "$PSScriptRoot\Modules\PackageParser.ps1"
. "$PSScriptRoot\Modules\CompatibilityChecker.ps1"
. "$PSScriptRoot\Modules\MigrationEngine.ps1"

$solutionFile = Get-ChildItem -Path $SolutionFolder -Filter *.sln | Select-Object -First 1
if (-not $solutionFile) {
    Write-Error "No .sln file found in $SolutionFolder"
    exit 1
}

Write-Host "Parsing solution: $($solutionFile.Name)"
$projectPaths = @()

Get-Content $solutionFile.FullName | ForEach-Object {
    if ($_ -match 'Project\("\{[^}]+\}"\) = "[^"]+", "([^"]+)", "\{[^}]+\}"') {
        $relativePath = $matches[1]
        $projectPath = Join-Path $SolutionFolder $relativePath
        if (Test-Path $projectPath) {
            $projectPaths += $projectPath
        }
    }
}

if (-not $projectPaths) {
    Write-Error "No projects found in solution."
    exit 1
}

$reportsFolder = Join-Path $SolutionFolder "Reports"
Ensure-Directory -Path $reportsFolder

$finalResults = @()

foreach ($project in $projectPaths) {
    $projName = [System.IO.Path]::GetFileNameWithoutExtension($project)
    $logPath = Join-Path $reportsFolder "$projName`_report.txt"
    Write-Host "`nAnalyzing: $projName"

    $packages = Get-Packages -projectPath $project
    $incompatible = @()

    Write-Log -Message "Project: $projName`nTarget: $TargetFramework`nPackages:" -Path $logPath

    foreach ($pkg in $packages) {
        $compatible = Is-Compatible -id $pkg.Id -version $pkg.Version -targetFramework $TargetFramework
        $line = "  - $($pkg.Id) v$($pkg.Version) => " + ($compatible ? "Compatible" : "INCOMPATIBLE")
        Write-Log -Message $line -Path $logPath
        if (-not $compatible) {
            $incompatible += "$($pkg.Id) v$($pkg.Version)"
        }
    }

    $finalResults += [PSCustomObject]@{
        Project = $projName
        Path = $project
        Compatible = ($incompatible.Count -eq 0)
        Issues = $incompatible
    }
}

$incompat = $finalResults | Where-Object { -not $_.Compatible }

if ($incompat.Count -eq 0) {
    Write-Host "`n[OK] All packages are compatible with $TargetFramework"
    Read-Host "Press Enter to begin migration..."

    foreach ($proj in $finalResults) {
        Write-Host "`n[INFO] Migrating: $($proj.Project)"
        Convert-ToSdkStyle -projectPath $proj.Path -targetFramework $TargetFramework -backup $true
        Migrate-PackagesConfig -projectPath $proj.Path -backup $true
        Write-Host "[DONE] Migration complete: $($proj.Project)"
    }
} else {
    Write-Host "`n[ERROR] Some projects have incompatible packages:"
    foreach ($r in $incompat) {
        Write-Host "`nProject: $($r.Project)"
        $r.Issues | ForEach-Object { Write-Host "  - $_" }
    }
}
