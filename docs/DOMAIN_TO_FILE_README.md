# Domain to File Converter

This tool converts a domain or subdomain to a text file with the same name.

## Examples
- `zdev.net` → `zdev.txt`
- `example.com` → `example.txt`
- `subdomain.example.com` → `subdomain.txt`

## Available Scripts

### 1. PowerShell Version (Recommended for Windows)
```powershell
.\domain_to_file.ps1 -Domain zdev.net
```

### 2. Batch File Version (Simple Windows)
```cmd
domain_to_file.bat zdev.net
```

### 3. Bash Version (Linux/WSL/Git Bash)
```bash
./domain_to_file.sh zdev.net
```

## Features
- ✅ Extracts domain name from full domain
- ✅ Removes protocol (http://, https://)
- ✅ Removes www prefix
- ✅ Creates organized text file with examples
- ✅ Checks for existing files
- ✅ Provides usage examples for other tools

## Generated File Content
The script creates a text file with:
- Domain information
- Creation timestamp
- Example subdomains
- Usage examples for subfinder, assetfinder, and httpx

## Usage Examples

### Basic Usage
```powershell
.\domain_to_file.ps1 -Domain zdev.net
```

### With Subdomain
```powershell
.\domain_to_file.ps1 -Domain admin.example.com
```

### Batch File Usage
```cmd
domain_to_file.bat zdev.net
```

## Integration with Other Tools

After creating the file, you can use it with:

```bash
# Find subdomains
subfinder -d zdev.net -o zdev.txt

# Add more subdomains
assetfinder --subs-only zdev.net >> zdev.txt

# Check HTTP status
httpx -l zdev.txt

# Remove duplicates
cat zdev.txt | anew >> zdev_clean.txt
```

## File Structure
```
Attack-machine/
├── domain_to_file.ps1      # PowerShell version
├── domain_to_file.bat      # Batch file version
├── domain_to_file.sh       # Bash version
├── zdev.txt               # Example output file
└── example.txt            # Another example
```

## Requirements
- Windows PowerShell (for .ps1)
- Windows Command Prompt (for .bat)
- Bash shell (for .sh)
- No additional dependencies required
