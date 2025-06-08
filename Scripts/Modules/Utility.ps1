
function Write-Log {
    param (
        [string]$Message,
        [string]$Path
    )
    Add-Content -Path $Path -Value $Message
}

function Ensure-Directory {
    param ([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}
