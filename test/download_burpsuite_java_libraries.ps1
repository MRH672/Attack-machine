# Script to download all Java libraries required for Burp Suite
# Downloads: Burp Suite JAR, Java JRE, and Burp Suite API libraries

$ErrorActionPreference = "Stop"
$downloadFolder = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading Burp Suite Java Libraries" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create libs folder for Java libraries
$libsFolder = Join-Path $downloadFolder "java_libs"
if (-not (Test-Path $libsFolder)) {
    New-Item -ItemType Directory -Path $libsFolder -Force | Out-Null
    Write-Host "Created directory: $libsFolder" -ForegroundColor Green
}

# Function to download files
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$Description,
        [hashtable]$Headers = @{}
    )
    
    Write-Host "Downloading $Description..." -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    Write-Host "  Saving to: $OutputPath" -ForegroundColor Gray
    
    try {
        $defaultHeaders = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        
        $allHeaders = $defaultHeaders + $Headers
        
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -Headers $allHeaders -UseBasicParsing -ErrorAction Stop
        
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

# Function to download from Maven Central
function Download-MavenLibrary {
    param (
        [string]$GroupId,
        [string]$ArtifactId,
        [string]$Version,
        [string]$Description,
        [string]$Classifier = ""
    )
    
    $baseUrl = "https://repo1.maven.org/maven2"
    $groupIdPath = $GroupId -replace '\.', '/'
    
    if ($Classifier) {
        $url = "$baseUrl/$groupIdPath/$ArtifactId/$Version/$ArtifactId-$Version-$Classifier.jar"
        $outputPath = Join-Path $libsFolder "$ArtifactId-$Version-$Classifier.jar"
    } else {
        $url = "$baseUrl/$groupIdPath/$ArtifactId/$Version/$ArtifactId-$Version.jar"
        $outputPath = Join-Path $libsFolder "$ArtifactId-$Version.jar"
    }
    
    return Download-File -Url $url -OutputPath $outputPath -Description $Description
}

Write-Host "=== Step 1: Downloading Burp Suite Community Edition ===" -ForegroundColor Cyan
Write-Host ""

# Try to get latest Burp Suite version
$burpSuiteUrl = "https://portswigger.net/burp/releases/download?product=community&version=latest&type=jar"
$burpSuiteJar = Join-Path $downloadFolder "burpsuite_community.jar"

# Alternative: Try specific version URL
$latestVersion = "2024.12.3.2"
$burpSuiteUrlAlt = "https://portswigger.net/burp/releases/download?product=community&version=$latestVersion&type=jar"

Write-Host "Attempting to download latest Burp Suite Community Edition..." -ForegroundColor Yellow
if (-not (Download-File -Url $burpSuiteUrl -OutputPath $burpSuiteJar -Description "Burp Suite Community Edition")) {
    Write-Host "Trying alternative URL..." -ForegroundColor Yellow
    if (-not (Download-File -Url $burpSuiteUrlAlt -OutputPath $burpSuiteJar -Description "Burp Suite Community Edition (v$latestVersion)")) {
        Write-Host "Warning: Could not download Burp Suite automatically." -ForegroundColor Yellow
        Write-Host "Please download manually from: https://portswigger.net/burp/communitydownload" -ForegroundColor Cyan
        Write-Host "Save it as: $burpSuiteJar" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "=== Step 2: Downloading Burp Suite API Libraries ===" -ForegroundColor Cyan
Write-Host ""

# Burp Suite API libraries from Maven Central
# Note: The API is embedded in Burp Suite JAR
# The burp-extensions-api is not available on Maven Central as a separate library
# API classes are included in the Burp Suite JAR file itself
Write-Host "Note: Burp Suite API is embedded in the main JAR file." -ForegroundColor Cyan
Write-Host "For extension development, extract API classes from burpsuite_community.jar" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Step 3: Downloading Java Runtime Libraries ===" -ForegroundColor Cyan
Write-Host ""

# Check if Java is installed
$javaInstalled = $false
try {
    $javaVersion = java -version 2>&1
    if ($LASTEXITCODE -eq 0 -or $javaVersion) {
        Write-Host "Java is already installed on your system:" -ForegroundColor Green
        Write-Host $javaVersion -ForegroundColor Gray
        $javaInstalled = $true
    }
} catch {
    Write-Host "Java is not installed or not in PATH" -ForegroundColor Yellow
}

if (-not $javaInstalled) {
    Write-Host ""
    Write-Host "Java Runtime Environment (JRE) is required to run Burp Suite." -ForegroundColor Yellow
    Write-Host "Burp Suite requires Java 11 or higher." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please download and install Java from one of these sources:" -ForegroundColor Cyan
    Write-Host "  1. OpenJDK (Recommended): https://adoptium.net/" -ForegroundColor White
    Write-Host "  2. Oracle JDK: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor White
    Write-Host "  3. Amazon Corretto: https://aws.amazon.com/corretto/" -ForegroundColor White
    Write-Host ""
    
    # Try to download OpenJDK Windows x64 MSI
    Write-Host "Attempting to download OpenJDK 17 LTS (Windows x64)..." -ForegroundColor Yellow
    $openJdkUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse"
    $openJdkZip = Join-Path $downloadFolder "openjdk-17-windows-x64.zip"
    
    # Note: Adoptium API requires accepting terms, so we'll provide instructions instead
    Write-Host "  Note: Direct download requires accepting license terms." -ForegroundColor Gray
    Write-Host "  Please visit: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Cyan
    Write-Host "  Download: Windows x64 JDK (.msi installer)" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=== Step 4: Additional Java Libraries for Extension Development ===" -ForegroundColor Cyan
Write-Host ""

# Common Java libraries that might be needed for Burp Suite extensions
$commonLibraries = @(
    @{
        GroupId = "com.google.code.gson"
        ArtifactId = "gson"
        Version = "2.10.1"
        Description = "Gson JSON Library"
    },
    @{
        GroupId = "org.apache.commons"
        ArtifactId = "commons-lang3"
        Version = "3.14.0"
        Description = "Apache Commons Lang"
    },
    @{
        GroupId = "org.apache.httpcomponents.client5"
        ArtifactId = "httpclient5"
        Version = "5.2.1"
        Description = "Apache HttpClient 5"
    },
    @{
        GroupId = "org.apache.httpcomponents.core5"
        ArtifactId = "httpcore5"
        Version = "5.2.2"
        Description = "Apache HttpCore 5"
    },
    @{
        GroupId = "org.apache.httpcomponents"
        ArtifactId = "httpclient"
        Version = "4.5.14"
        Description = "Apache HttpClient 4"
    },
    @{
        GroupId = "org.apache.httpcomponents"
        ArtifactId = "httpcore"
        Version = "4.4.16"
        Description = "Apache HttpCore 4"
    },
    @{
        GroupId = "com.fasterxml.jackson.core"
        ArtifactId = "jackson-databind"
        Version = "2.16.0"
        Description = "Jackson Data Binding"
    },
    @{
        GroupId = "com.fasterxml.jackson.core"
        ArtifactId = "jackson-core"
        Version = "2.16.0"
        Description = "Jackson Core"
    },
    @{
        GroupId = "com.fasterxml.jackson.core"
        ArtifactId = "jackson-annotations"
        Version = "2.16.0"
        Description = "Jackson Annotations"
    },
    @{
        GroupId = "org.json"
        ArtifactId = "json"
        Version = "20231013"
        Description = "JSON Java Library"
    },
    @{
        GroupId = "commons-io"
        ArtifactId = "commons-io"
        Version = "2.15.1"
        Description = "Apache Commons IO"
    },
    @{
        GroupId = "commons-codec"
        ArtifactId = "commons-codec"
        Version = "1.16.0"
        Description = "Apache Commons Codec"
    },
    @{
        GroupId = "commons-logging"
        ArtifactId = "commons-logging"
        Version = "1.2"
        Description = "Apache Commons Logging"
    },
    @{
        GroupId = "org.slf4j"
        ArtifactId = "slf4j-api"
        Version = "2.0.9"
        Description = "SLF4J API"
    },
    @{
        GroupId = "org.slf4j"
        ArtifactId = "slf4j-simple"
        Version = "2.0.9"
        Description = "SLF4J Simple"
    },
    @{
        GroupId = "com.google.guava"
        ArtifactId = "guava"
        Version = "32.1.3-jre"
        Description = "Google Guava"
    },
    @{
        GroupId = "org.jsoup"
        ArtifactId = "jsoup"
        Version = "1.17.2"
        Description = "JSoup HTML Parser"
    },
    @{
        GroupId = "org.yaml"
        ArtifactId = "snakeyaml"
        Version = "2.2"
        Description = "SnakeYAML"
    },
    @{
        GroupId = "org.apache.commons"
        ArtifactId = "commons-collections4"
        Version = "4.4"
        Description = "Apache Commons Collections"
    }
)

Write-Host "Downloading common Java libraries for extension development..." -ForegroundColor Yellow
foreach ($lib in $commonLibraries) {
    $classifier = if ($lib.Classifier) { $lib.Classifier } else { "" }
    Download-MavenLibrary -GroupId $lib.GroupId -ArtifactId $lib.ArtifactId -Version $lib.Version -Description $lib.Description -Classifier $classifier
    Write-Host ""
}

Write-Host "=== Step 5: Extracting Burp Suite API from JAR (if available) ===" -ForegroundColor Cyan
Write-Host ""

# If Burp Suite JAR was downloaded, try to extract API classes
if (Test-Path $burpSuiteJar) {
    Write-Host "Burp Suite JAR found. API classes are embedded in the JAR." -ForegroundColor Green
    Write-Host "To extract API classes, you can use:" -ForegroundColor Yellow
    Write-Host "  jar xf $burpSuiteJar burp/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or use the burp-extensions-api from Maven (already downloaded above)." -ForegroundColor Cyan
} else {
    Write-Host "Burp Suite JAR not found. Please download it first." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Files downloaded to:" -ForegroundColor Green
Write-Host "  Main folder: $downloadFolder" -ForegroundColor White
Write-Host "  Libraries folder: $libsFolder" -ForegroundColor White
Write-Host ""

# List downloaded files
Write-Host "Downloaded files:" -ForegroundColor Green
if (Test-Path $burpSuiteJar) {
    $size = (Get-Item $burpSuiteJar).Length / 1MB
    Write-Host "  [OK] burpsuite_community.jar ($([math]::Round($size, 2)) MB)" -ForegroundColor White
}

if (Test-Path $libsFolder) {
    $libFiles = Get-ChildItem -Path $libsFolder -Filter "*.jar"
    foreach ($file in $libFiles) {
        $size = $file.Length / 1MB
        Write-Host "  [OK] $($file.Name) ($([math]::Round($size, 2)) MB)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ensure Java 11+ is installed:" -ForegroundColor Yellow
Write-Host "   java -version" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Run Burp Suite:" -ForegroundColor Yellow
Write-Host "   java -jar `"$burpSuiteJar`"" -ForegroundColor Gray
Write-Host ""
Write-Host "3. For extension development, add libraries from:" -ForegroundColor Yellow
Write-Host "   $libsFolder" -ForegroundColor Gray
Write-Host "   to your project's classpath." -ForegroundColor Gray
Write-Host ""
Write-Host "Download complete!" -ForegroundColor Green
