# Build script for Email Change Intruder Extension
# This script compiles the Java extension and creates a JAR file

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Email Change Intruder Extension" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Java is installed
try {
    $javaVersion = java -version 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $javaVersion) {
        Write-Host "ERROR: Java is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Java JDK 11 or higher" -ForegroundColor Yellow
        Write-Host "Download from: https://adoptium.net/" -ForegroundColor Cyan
        exit 1
    }
    Write-Host "Java found:" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "ERROR: Java is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Java JDK 11 or higher" -ForegroundColor Yellow
    exit 1
}

# Paths
$burpJar = Join-Path $projectRoot "burpsuite_community.jar"
$sourceFile = Join-Path $scriptDir "EmailChangeIntruderExtension.java"
$outputDir = $scriptDir
$jarFile = Join-Path $outputDir "EmailChangeIntruderExtension.jar"

# Check if Burp Suite JAR exists
if (-not (Test-Path $burpJar)) {
    Write-Host "ERROR: Burp Suite JAR not found at: $burpJar" -ForegroundColor Red
    Write-Host "Please run download_burpsuite_java_libraries.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Check if source file exists
if (-not (Test-Path $sourceFile)) {
    Write-Host "ERROR: Source file not found: $sourceFile" -ForegroundColor Red
    exit 1
}

Write-Host "Compiling extension..." -ForegroundColor Yellow
Write-Host "  Source: $sourceFile" -ForegroundColor Gray
Write-Host "  Burp JAR: $burpJar" -ForegroundColor Gray
Write-Host ""

# Compile
try {
    javac -cp "`"$burpJar`"" -d "$outputDir" "$sourceFile"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Compilation successful!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "ERROR: Compilation failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Compilation failed: $_" -ForegroundColor Red
    exit 1
}

# Check if class file was created
$classFile = Join-Path $outputDir "EmailChangeIntruderExtension.class"
if (-not (Test-Path $classFile)) {
    Write-Host "ERROR: Class file not found after compilation: $classFile" -ForegroundColor Red
    exit 1
}

Write-Host "Creating JAR file..." -ForegroundColor Yellow
Write-Host "  Output: $jarFile" -ForegroundColor Gray
Write-Host ""

# Create JAR file
try {
    # Change to output directory
    Push-Location $outputDir
    
    # Create JAR
    jar cf "EmailChangeIntruderExtension.jar" "EmailChangeIntruderExtension.class"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "JAR file created successfully!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: JAR creation failed" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    
} catch {
    Write-Host "ERROR: JAR creation failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Verify JAR file
if (Test-Path $jarFile) {
    $jarSize = (Get-Item $jarFile).Length / 1KB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Build Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "JAR file: $jarFile" -ForegroundColor White
    Write-Host "Size: $([math]::Round($jarSize, 2)) KB" -ForegroundColor White
    Write-Host ""
    Write-Host "To install in Burp Suite:" -ForegroundColor Yellow
    Write-Host "1. Open Burp Suite" -ForegroundColor White
    Write-Host "2. Go to Extensions tab" -ForegroundColor White
    Write-Host "3. Click 'Add' button" -ForegroundColor White
    Write-Host "4. Select 'Extension type: Java'" -ForegroundColor White
    Write-Host "5. Click 'Select file' and choose: $jarFile" -ForegroundColor White
    Write-Host "6. Click 'Next' then 'Close'" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "ERROR: JAR file not found after creation" -ForegroundColor Red
    exit 1
}

# Clean up class file (optional)
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
if (Test-Path $classFile) {
    Remove-Item $classFile -Force
    Write-Host "Temporary class file removed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green

