# Paths to configs in repo
$dotfilesdir = "$PSScriptRoot"
$weztermSource = "$dotfilesdir\wezterm\.wezterm.lua"
$starshipSource = "$dotfilesdir\starship\starship.toml"
$nvimSource = "$dotfilesdir\nvim"
$gituiSource = "$dotfilesdir\gitui\key_bindings.ron"

# Paths for symlinks
$weztermTarget = "$HOME\.wezterm.lua"
$starshipTarget = "$HOME\.config\starship.toml"
$nvimTarget = "$env:LOCALAPPDATA\nvim"
$gituiTarget = "$env:APPDATA\gitui\key_bindings.ron"

Write-Host "=== Dotfiles Installation ===" -ForegroundColor Cyan
Write-Host "Repository: $dotfilesdir" -ForegroundColor Gray
Write-Host ""

$script:successCount = 0
$script:failCount = 0

function New-Symlink {
    param(
        [string]$Source,
        [string]$Target
    )
    
    if (-not (Test-Path $Source)) {
        Write-Host "Source not found: $Source" -ForegroundColor Red
        $script:failCount++
        return
    }

    $isDirectory = Test-Path $Source -PathType Container 

    if (Test-Path $Target) {
        Write-Host "Warning: $Target already exists. Delete it? (y/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -ne 'y') {
            Write-Host "Skipped: $Target" -ForegroundColor Yellow
            $script:failCount++
            return
        }
        Remove-Item $Target -Recurse -Force
        Write-Host "Deleted: $Target" -ForegroundColor Yellow
    }

    $parentDir = Split-Path -Parent $Target
    if ($parentDir -and -not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        Write-Host "Directory created: $parentDir" -ForegroundColor Cyan
    }

    try {
        $absolutePath = Resolve-Path $Source
        New-Item -ItemType SymbolicLink -Path $Target -Target $absolutePath -Force -ErrorAction Stop | Out-Null
        
        $type = if ($isDirectory) { "directory" } else { "file" }
        Write-Host "Symlink created ($type): $Target -> $absolutePath" -ForegroundColor Green
        $script:successCount++
    }
    catch {
        Write-Host "Error with symlink creation for $Target" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        $script:failCount++

        if ($_.Exception.Message -match "privilege|administrator") {
            Write-Host "Help: run PowerShell as administrator or enable Developer Mode in Settings." -ForegroundColor Magenta
        }
    }
}

# Create symlinks
Write-Host "Creating symlinks..." -ForegroundColor Cyan
New-Symlink -Source $weztermSource -Target $weztermTarget
New-Symlink -Source $starshipSource -Target $starshipTarget
New-Symlink -Source $nvimSource -Target $nvimTarget
New-Symlink -Source $gituiSource -Target $gituiTarget

# Print summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

if ($successCount -eq 3 -and $failCount -eq 0) {
    Write-Host "Installation complete! All symlinks created successfully." -ForegroundColor Green
    exit 0
}
elseif ($successCount -gt 0) {
    Write-Host "Installation partially complete." -ForegroundColor Yellow
    Write-Host "Success: $successCount symlink(s)" -ForegroundColor Green
    Write-Host "Failed: $failCount symlink(s)" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "Installation failed! No symlinks were created." -ForegroundColor Red
    Write-Host "Please fix the errors above and try again." -ForegroundColor Yellow
    exit 1
}
