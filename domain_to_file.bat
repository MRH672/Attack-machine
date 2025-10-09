@echo off
setlocal enabledelayedexpansion

REM Domain to File Converter - Batch Version
REM Converts domain or subdomain to a text file with the same name

if "%~1"=="" (
    echo Usage: domain_to_file.bat [DOMAIN]
    echo.
    echo Examples:
    echo   domain_to_file.bat zdev.net
    echo   domain_to_file.bat example.com
    echo   domain_to_file.bat subdomain.example.com
    echo.
    echo Description:
    echo   Converts domain or subdomain to a text file with the same name
    echo   Example: zdev.net ^-^> zdev.txt
    exit /b 1
)

set "DOMAIN=%~1"

REM Extract domain name (remove protocol and www if present)
set "CLEAN_DOMAIN=%DOMAIN%"
set "CLEAN_DOMAIN=!CLEAN_DOMAIN:https://=!"
set "CLEAN_DOMAIN=!CLEAN_DOMAIN:http://=!"
set "CLEAN_DOMAIN=!CLEAN_DOMAIN:www.=!"

REM Get first part before dot
for /f "tokens=1 delims=." %%a in ("!CLEAN_DOMAIN!") do set "DOMAIN_NAME=%%a"

set "OUTPUT_FILE=!DOMAIN_NAME!.txt"

echo [INFO] Input domain: %DOMAIN%
echo [INFO] Output file: !OUTPUT_FILE!

REM Check if file exists
if exist "!OUTPUT_FILE!" (
    echo [WARNING] File !OUTPUT_FILE! already exists
    set /p "REPLACE=Do you want to replace it? (y/n): "
    if /i "!REPLACE!"=="y" (
        del "!OUTPUT_FILE!"
        echo [INFO] Old file deleted
    ) else (
        echo [INFO] Operation cancelled
        exit /b 0
    )
)

REM Create file content
(
echo # Domain Information
echo Original Domain: %DOMAIN%
echo File Name: !OUTPUT_FILE!
echo Created: %DATE% %TIME%
echo ==========================================
echo.
echo # You can add subdomains here
echo # Examples:
echo # www.%DOMAIN%
echo # mail.%DOMAIN%
echo # ftp.%DOMAIN%
echo # admin.%DOMAIN%
echo.
echo # Or use other tools like:
echo # subfinder -d %DOMAIN% -o !OUTPUT_FILE!
echo # assetfinder --subs-only %DOMAIN% ^>^> !OUTPUT_FILE!
) > "!OUTPUT_FILE!"

echo [SUCCESS] File created: !OUTPUT_FILE!
echo [INFO] You can now add subdomains to this file
echo.
echo [SUCCESS] Operation completed successfully!
echo [INFO] You can now use the file with other tools:
echo   subfinder -d %DOMAIN% -o !OUTPUT_FILE!
echo   assetfinder --subs-only %DOMAIN% ^>^> !OUTPUT_FILE!
echo   httpx -l !OUTPUT_FILE!
