# Paths to symlinks
$symlinks = @(
    @{
        Name = "WezTerm"
        Path = "$HOME\.wezterm.lua"
    },
    @{
        Name = "Starship"
        Path = "$HOME\.config\starship.toml"
    },
    @{
        Name = "Neovim"
        Path = "$env:LOCALAPPDATA\nvim"
    },
    @{
        Name = "gitui"
        Path = "$env:APPDATA\gitui\key_bindings.ron"
    }
)

Write-Host ""
Write-Host "=== Dotfiles Uninstallation ===" -ForegroundColor Cyan
Write-Host "This will remove all symlinks created by install.ps1" -ForegroundColor Gray
Write-Host ""

# Confirmation
Write-Host "Are you sure you want to remove all dotfiles symlinks? (y/n)" -ForegroundColor Yellow
$confirm = Read-Host

if ($confirm -ne 'y') {
    Write-Host "Uninstallation cancelled." -ForegroundColor Gray
    exit
}

Write-Host ""

$removedCount = 0
$skippedCount = 0

foreach ($link in $symlinks) {
    Write-Host "Processing $($link.Name)..." -ForegroundColor White
    
    # Check if path exists
    if (-not (Test-Path $link.Path)) {
        Write-Host "  Status: Not found (already removed or never created)" -ForegroundColor Gray
        $skippedCount++
        Write-Host ""
        continue
    }
    
    # Get item info
    $item = Get-Item $link.Path -Force
    
    # Check if it's a symlink
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "  Type: Symbolic Link" -ForegroundColor Cyan
        Write-Host "  Target: $($item.Target)" -ForegroundColor Gray
        
        try {
            # Safely delete symlink using .Delete() method
            # This works reliably for both files and directories
            $item.Delete()
            Write-Host "  Status: Removed successfully" -ForegroundColor Green
            $removedCount++
        }
        catch {
            Write-Host "  Status: Failed to remove" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            $skippedCount++
        }
    }
    else {
        Write-Host "  Type: NOT A SYMLINK" -ForegroundColor Yellow
        Write-Host "  Status: Skipped (not removing regular files/directories)" -ForegroundColor Yellow
        $skippedCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Removed: $removedCount symlink(s)" -ForegroundColor Green
if ($skippedCount -gt 0) {
    Write-Host "Skipped: $skippedCount item(s)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Your dotfiles repository remains intact at:" -ForegroundColor Gray
Write-Host "$PSScriptRoot" -ForegroundColor White
Write-Host ""
