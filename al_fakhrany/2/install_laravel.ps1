# Laravel Installation Script for Windows
# This script installs PHP, Composer, and Laravel

Write-Host "Laravel Installation Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Warning: Some operations may require Administrator privileges." -ForegroundColor Yellow
    Write-Host ""
}

# Method 1: Check if Laravel Herd is installed (Recommended for Windows)
Write-Host "Checking for Laravel Herd..." -ForegroundColor Green
$herdPath = "$env:LOCALAPPDATA\Programs\Herd"
if (Test-Path $herdPath) {
    Write-Host "Laravel Herd is already installed!" -ForegroundColor Green
    $env:Path += ";$herdPath\bin"
} else {
    Write-Host "Laravel Herd not found. Would you like to install it? (Recommended)" -ForegroundColor Yellow
    Write-Host "Laravel Herd is the easiest way to run Laravel on Windows." -ForegroundColor Yellow
    Write-Host "Download from: https://herd.laravel.com/windows" -ForegroundColor Cyan
    Write-Host ""
}

# Method 2: Install PHP manually
Write-Host "Checking for PHP..." -ForegroundColor Green
$phpInstalled = $false
try {
    $phpVersion = php --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PHP is already installed: $($phpVersion -split "`n" | Select-Object -First 1)" -ForegroundColor Green
        $phpInstalled = $true
    }
} catch {
    Write-Host "PHP is not installed." -ForegroundColor Yellow
}

if (-not $phpInstalled) {
    Write-Host ""
    Write-Host "To install PHP manually:" -ForegroundColor Cyan
    Write-Host "1. Download PHP from: https://windows.php.net/download/" -ForegroundColor White
    Write-Host "2. Extract to C:\php" -ForegroundColor White
    Write-Host "3. Add C:\php to your PATH environment variable" -ForegroundColor White
    Write-Host "4. Copy php.ini-development to php.ini" -ForegroundColor White
    Write-Host ""
}

# Method 3: Install Composer
Write-Host "Checking for Composer..." -ForegroundColor Green
$composerInstalled = $false
try {
    $composerVersion = composer --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Composer is already installed: $($composerVersion -split "`n" | Select-Object -First 1)" -ForegroundColor Green
        $composerInstalled = $true
    }
} catch {
    Write-Host "Composer is not installed." -ForegroundColor Yellow
}

if (-not $composerInstalled) {
    Write-Host ""
    Write-Host "To install Composer manually:" -ForegroundColor Cyan
    Write-Host "1. Download Composer-Setup.exe from: https://getcomposer.org/download/" -ForegroundColor White
    Write-Host "2. Run the installer (it will detect PHP automatically)" -ForegroundColor White
    Write-Host ""
}

# If both PHP and Composer are installed, install Laravel
if ($phpInstalled -and $composerInstalled) {
    Write-Host ""
    Write-Host "Installing Laravel..." -ForegroundColor Green
    
    # Check if Laravel installer is available globally
    try {
        $laravelVersion = laravel --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Laravel installer is already available!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Installing Laravel installer globally..." -ForegroundColor Yellow
        composer global require laravel/installer
        
        # Add Composer global bin to PATH if not already there
        $composerGlobalBin = "$env:APPDATA\Composer\vendor\bin"
        if ($env:Path -notlike "*$composerGlobalBin*") {
            Write-Host "Adding Composer global bin to PATH for this session..." -ForegroundColor Yellow
            $env:Path += ";$composerGlobalBin"
        }
    }
    
    Write-Host ""
    Write-Host "Laravel installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To create a new Laravel project, run:" -ForegroundColor Cyan
    Write-Host "  laravel new project-name" -ForegroundColor White
    Write-Host "or" -ForegroundColor White
    Write-Host "  composer create-project laravel/laravel project-name" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Please install PHP and Composer first, then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "RECOMMENDED: Install Laravel Herd for the easiest setup:" -ForegroundColor Cyan
    Write-Host "  https://herd.laravel.com/windows" -ForegroundColor White
}

Write-Host ""
Write-Host "Script completed." -ForegroundColor Green

