# Domain to File Converter - PowerShell Version
# Converts domain or subdomain to a text file with the same name

param(
    [Parameter(Mandatory=$true)]
    [string]$Domain
)

# Color settings
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Magenta = "Magenta"
$Cyan = "Cyan"

# Function for colored output
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status) {
        "INFO" { Write-Host "[INFO] $Message" -ForegroundColor $Blue }
        "SUCCESS" { Write-Host "[SUCCESS] $Message" -ForegroundColor $Green }
        "WARNING" { Write-Host "[WARNING] $Message" -ForegroundColor $Yellow }
        "ERROR" { Write-Host "[ERROR] $Message" -ForegroundColor $Red }
        "STEP" { Write-Host "[STEP] $Message" -ForegroundColor $Magenta }
    }
}

# Function to show banner
function Show-Banner {
    Clear-Host
    Write-Host @"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║    ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗        ║
    ║    ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║        ║
    ║    ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║        ║
    ║    ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║        ║
    ║    ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║        ║
    ║    ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝        ║
    ║                                                              ║
    ║              Domain to File Converter                        ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor $Cyan
}

# Function to extract domain name
function Get-DomainName {
    param([string]$Domain)
    
    # Remove protocol if present
    $domain = $Domain -replace '^https?://', ''
    $domain = $domain -replace '^www\.', ''
    
    # Extract first part before dot
    $domainName = $domain.Split('.')[0]
    return $domainName
}

# Function to create domain file
function New-DomainFile {
    param(
        [string]$Domain,
        [string]$DomainName
    )
    
    $outputFile = "$DomainName.txt"
    
    Write-Status "INFO" "Input domain: $Domain"
    Write-Status "INFO" "Output file: $outputFile"
    
    # Check if file exists
    if (Test-Path $outputFile) {
        Write-Status "WARNING" "File $outputFile already exists"
        $replace = Read-Host "Do you want to replace it? (y/n)"
        if ($replace -eq "y" -or $replace -eq "Y") {
            Remove-Item $outputFile -Force
            Write-Status "INFO" "Old file deleted"
        } else {
            Write-Status "INFO" "Operation cancelled"
            exit 0
        }
    }
    
    # Create file content
    $fileContent = @"
# Domain Information
Original Domain: $Domain
File Name: $outputFile
Created: $(Get-Date)
==========================================

# You can add subdomains here
# Examples:
# www.$Domain
# mail.$Domain
# ftp.$Domain
# admin.$Domain

# Or use other tools like:
# subfinder -d $Domain -o $outputFile
# assetfinder --subs-only $Domain >> $outputFile
"@
    
    # Write file
    $fileContent | Out-File -FilePath $outputFile -Encoding UTF8
    
    Write-Status "SUCCESS" "File created: $outputFile"
    Write-Status "INFO" "You can now add subdomains to this file"
}

# Function to show usage
function Show-Usage {
    Write-Host "Usage:" -ForegroundColor $Yellow
    Write-Host "  .\domain_to_file.ps1 -Domain [DOMAIN]"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Yellow
    Write-Host "  .\domain_to_file.ps1 -Domain zdev.net"
    Write-Host "  .\domain_to_file.ps1 -Domain example.com"
    Write-Host "  .\domain_to_file.ps1 -Domain subdomain.example.com"
    Write-Host ""
    Write-Host "Description:" -ForegroundColor $Yellow
    Write-Host "  Converts domain or subdomain to a text file with the same name"
    Write-Host "  Example: zdev.net → zdev.txt"
}

# Main function
function Main {
    Show-Banner
    
    # Validate domain format
    if ($Domain -notmatch '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') {
        Write-Status "ERROR" "Invalid domain format: $Domain"
        Write-Status "INFO" "Make sure the domain contains a dot and valid extension"
        Show-Usage
        exit 1
    }
    
    # Extract domain name
    $domainName = Get-DomainName -Domain $Domain
    
    # Create file
    New-DomainFile -Domain $Domain -DomainName $domainName
    
    Write-Host ""
    Write-Status "SUCCESS" "Operation completed successfully!"
    Write-Status "INFO" "You can now use the file with other tools:"
    Write-Host "  subfinder -d $Domain -o $domainName.txt" -ForegroundColor $Cyan
    Write-Host "  assetfinder --subs-only $Domain >> $domainName.txt" -ForegroundColor $Cyan
    Write-Host "  httpx -l $domainName.txt" -ForegroundColor $Cyan
}

# Run main function
Main