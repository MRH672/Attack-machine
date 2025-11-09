# Script to download popular Burp Suite Extensions from BApp Store
# Note: BApp Store extensions are typically downloaded through Burp Suite UI
# This script downloads some popular open-source extensions from GitHub

$ErrorActionPreference = "Stop"
$downloadFolder = $PSScriptRoot
$extensionsFolder = Join-Path $downloadFolder "extensions"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading Popular Burp Suite Extensions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create extensions folder
if (-not (Test-Path $extensionsFolder)) {
    New-Item -ItemType Directory -Path $extensionsFolder -Force | Out-Null
    Write-Host "Created directory: $extensionsFolder" -ForegroundColor Green
}

# Function to download files
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )
    
    Write-Host "Downloading $Description..." -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
    try {
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        }
        
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -Headers $headers -UseBasicParsing -ErrorAction Stop
        
        if (Test-Path $OutputPath) {
            $fileSize = (Get-Item $OutputPath).Length / 1MB
            Write-Host "  [OK] Successfully downloaded ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  [ERROR] File not found after download" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "  [ERROR] Error: $_" -ForegroundColor Red
        return $false
    }
}

# Function to download from GitHub releases
function Download-GitHubRelease {
    param (
        [string]$Owner,
        [string]$Repo,
        [string]$AssetName,
        [string]$OutputName,
        [string]$Description
    )
    
    # Try to get latest release
    $releaseUrl = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    
    try {
        $headers = @{
            "User-Agent" = "Mozilla/5.0"
            "Accept" = "application/vnd.github.v3+json"
        }
        
        $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -ErrorAction Stop
        
        # Find the asset
        $asset = $release.assets | Where-Object { $_.name -like "*$AssetName*" } | Select-Object -First 1
        
        if ($asset) {
            $outputPath = Join-Path $extensionsFolder $OutputName
            return Download-File -Url $asset.browser_download_url -OutputPath $outputPath -Description $Description
        } else {
            Write-Host "  [WARNING] Asset '$AssetName' not found in latest release" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  [ERROR] Could not fetch release info: $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "=== Popular Burp Suite Extensions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Most extensions are available through BApp Store in Burp Suite UI" -ForegroundColor Yellow
Write-Host "This script downloads some open-source extensions from GitHub" -ForegroundColor Yellow
Write-Host ""

# List of popular extensions (open-source ones available on GitHub)
$extensions = @(
    @{
        Owner = "PortSwigger"
        Repo = "turbo-intruder"
        AssetName = ".jar"
        OutputName = "turbo-intruder.jar"
        Description = "Turbo Intruder - High-speed request engine"
    },
    @{
        Owner = "PortSwigger"
        Repo = "param-miner"
        AssetName = ".jar"
        OutputName = "param-miner.jar"
        Description = "Param Miner - Parameter discovery"
    },
    @{
        Owner = "PortSwigger"
        Repo = "collaborator-everywhere"
        AssetName = ".jar"
        OutputName = "collaborator-everywhere.jar"
        Description = "Collaborator Everywhere"
    }
)

Write-Host "Attempting to download extensions from GitHub..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($ext in $extensions) {
    if (Download-GitHubRelease -Owner $ext.Owner -Repo $ext.Repo -AssetName $ext.AssetName -OutputName $ext.OutputName -Description $ext.Description) {
        $successCount++
    } else {
        $failCount++
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully downloaded: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if (Test-Path $extensionsFolder) {
    $extFiles = Get-ChildItem -Path $extensionsFolder -Filter "*.jar"
    if ($extFiles.Count -gt 0) {
        Write-Host "Downloaded extensions:" -ForegroundColor Green
        foreach ($file in $extFiles) {
            $size = $file.Length / 1MB
            Write-Host "  [OK] $($file.Name) ($([math]::Round($size, 2)) MB)" -ForegroundColor White
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "How to Install Extensions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Burp Suite" -ForegroundColor Yellow
Write-Host "2. Go to Extensions tab" -ForegroundColor Yellow
Write-Host "3. Click 'Add' button" -ForegroundColor Yellow
Write-Host "4. Select 'Extension type: Java'" -ForegroundColor Yellow
Write-Host "5. Click 'Select file' and choose the .jar file from:" -ForegroundColor Yellow
Write-Host "   $extensionsFolder" -ForegroundColor Gray
Write-Host "6. Click 'Next' then 'Close'" -ForegroundColor Yellow
Write-Host ""
Write-Host "OR use BApp Store (recommended):" -ForegroundColor Cyan
Write-Host "1. Open Burp Suite → Extensions → BApp Store" -ForegroundColor Yellow
Write-Host "2. Browse and install extensions directly" -ForegroundColor Yellow
Write-Host ""
Write-Host "Download complete!" -ForegroundColor Green

