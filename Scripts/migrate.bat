@echo off
setlocal

if "%~2"=="" (
    echo Usage: migrate.bat [solution-folder] [target-framework]
    exit /b 1
)

set SOLUTION_FOLDER=%~1
set TARGET_FRAMEWORK=%~2

powershell -ExecutionPolicy Bypass -File migrate.ps1 -SolutionFolder "%SOLUTION_FOLDER%" -TargetFramework "%TARGET_FRAMEWORK%"

endlocal
