# Script to download Burp Suite Community Edition and Java libraries
# Burp Suite Community Edition is free and available from PortSwigger

$ErrorActionPreference = "Stop"
$downloadFolder = $PSScriptRoot

Write-Host "Downloading Burp Suite Community Edition and libraries..." -ForegroundColor Green

# Burp Suite Community Edition download URL
# Note: This is the latest version URL pattern from PortSwigger
# The actual URL may need to be updated with the latest version number
$burpSuiteUrl = "https://portswigger.net/burp/releases/download?product=community&version=2024.1&type=jar"

# Create download function
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )
    
    Write-Host "Downloading $Description..." -ForegroundColor Yellow
    try {
        # Use Invoke-WebRequest with proper headers
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        }
        
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -Headers $headers -UseBasicParsing
        Write-Host "Successfully downloaded: $OutputPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error downloading $Description : $_" -ForegroundColor Red
        return $false
    }
}

# Download Burp Suite Community Edition
$burpSuiteJar = Join-Path $downloadFolder "burpsuite_community.jar"
if (Download-File -Url $burpSuiteUrl -OutputPath $burpSuiteJar -Description "Burp Suite Community Edition") {
    Write-Host "Burp Suite Community Edition downloaded successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to download Burp Suite. Trying alternative method..." -ForegroundColor Yellow
    Write-Host "Please download manually from: https://portswigger.net/burp/communitydownload" -ForegroundColor Cyan
}

# Note: Burp Suite API is typically included in the main JAR file
# For extension development, you can extract the API or use the burp-extensions-api
Write-Host "`nNote: Burp Suite API is included in the main JAR file." -ForegroundColor Cyan
Write-Host "For extension development, the API classes are available within the JAR." -ForegroundColor Cyan

Write-Host "`nDownload complete!" -ForegroundColor Green
Write-Host "Files are saved in: $downloadFolder" -ForegroundColor Green

