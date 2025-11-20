# Paths to check
$symlinks = @(
    @{
        Name = "WezTerm"
        Path = "$HOME\.wezterm.lua"
        ExpectedTarget = "$PSScriptRoot\wezterm\.wezterm.lua"
    },
    @{
        Name = "Starship"
        Path = "$HOME\.config\starship.toml"
        ExpectedTarget = "$PSScriptRoot\starship\starship.toml"
    },
    @{
        Name = "Neovim"
        Path = "$env:LOCALAPPDATA\nvim"
        ExpectedTarget = "$PSScriptRoot\nvim"
    },
    @{
        Name = "gitui"
        Path = "$env:APPDATA\gitui\key_bindings.ron"
        ExpectedTarget = "$PSScriptRoot\gitui\key_bindings.ron"
    }
)

Write-Host ""
Write-Host "=== Symlinks Status Check ===" -ForegroundColor Cyan
Write-Host "Repository: $PSScriptRoot" -ForegroundColor Gray
Write-Host ""

$allOk = $true

foreach ($link in $symlinks) {
    Write-Host "Checking $($link.Name)..." -ForegroundColor White
    Write-Host "  Path: $($link.Path)" -ForegroundColor Gray
    
    # Check if path exists
    if (-not (Test-Path $link.Path)) {
        Write-Host "  Status: NOT FOUND" -ForegroundColor Red
        Write-Host ""
        $allOk = $false
        continue
    }
    
    # Get item info
    $item = Get-Item $link.Path -Force
    
    # Check if it's a symlink
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "  Type: Symbolic Link" -ForegroundColor Green
        
        # Get target
        $actualTarget = $item.Target
        
        # Resolve expected target to absolute path
        $expectedTargetResolved = Resolve-Path $link.ExpectedTarget -ErrorAction SilentlyContinue
        
        # Display target
        Write-Host "  Target: $actualTarget" -ForegroundColor Cyan
        
        # Check if target matches expected
        if ($actualTarget -eq $expectedTargetResolved.Path) {
            Write-Host "  Match: OK" -ForegroundColor Green
        } else {
            Write-Host "  Match: INCORRECT" -ForegroundColor Yellow
            Write-Host "  Expected: $($expectedTargetResolved.Path)" -ForegroundColor Yellow
            $allOk = $false
        }
        
        # Check if target exists
        if (Test-Path $actualTarget) {
            Write-Host "  Target exists: YES" -ForegroundColor Green
        } else {
            Write-Host "  Target exists: NO (BROKEN LINK)" -ForegroundColor Red
            $allOk = $false
        }
        
    } else {
        Write-Host "  Type: NOT A SYMLINK" -ForegroundColor Red
        if ($item.LinkType) {
            Write-Host "  Actual type: $($item.LinkType)" -ForegroundColor Yellow
        } else {
            Write-Host "  Actual type: Regular file/directory" -ForegroundColor Yellow
        }
        $allOk = $false
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "All symlinks are correctly configured!" -ForegroundColor Green
} else {
    Write-Host "Some symlinks have issues. Run install.ps1 to fix." -ForegroundColor Yellow
}
Write-Host ""
