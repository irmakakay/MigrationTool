# .NET Solution Migration Tool

This tool helps analyze and migrate `.NET Framework` and `.NET Core` projects to a newer .NET version (e.g., .NET 8).

---

## What It Does

1. Takes a solution folder and target .NET version.
2. Scans all projects in the solution:
   - Detects NuGet packages (from `packages.config` or `PackageReference`)
   - Checks if packages are compatible with the target framework (via NuGet.org)
   - Generates detailed reports per project
3. If all packages are compatible, prompts the user and:
   - Converts legacy projects to SDK-style format
   - Migrates `packages.config` to `<PackageReference>`
   - Updates the `TargetFramework`

---

## Files

- `migrate.bat` — Entry point for Windows
- `migrate.ps1` — Main script
- `Modules/` — Helper scripts (modular functions)

---

## Usage

Open a terminal in the `Scripts/` folder and run:

```bash
migrate.bat "C:\Path\To\MySolution" net8.0

