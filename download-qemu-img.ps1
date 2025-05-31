# PowerShell script to download and install qemu-img-windows-x64
# Downloads the latest release zip file, extracts it to temp folder, and adds to PATH

param(
    [string]$TargetFolder = "$env:TEMP/qemu-img-windows-x64"
)

Write-Host "Installing qemu-img-windows-x64..." -ForegroundColor Green
try {
    # Get the latest release information from GitHub API
    Write-Host "Fetching latest release information..." -ForegroundColor Yellow
    $releaseUrl = "https://api.github.com/repos/fdcastel/qemu-img-windows-x64/releases/latest"
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers @{"User-Agent" = "PowerShell"}

    # Find the zip file asset
    $zipAsset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1

    if (-not $zipAsset) {
        throw "No zip file found in the latest release assets"
    }

    Write-Host "Found zip file: $($zipAsset.name)" -ForegroundColor Cyan
    Write-Host "Download URL: $($zipAsset.browser_download_url)" -ForegroundColor Cyan

    # Create/recreate target folder
    Write-Host "Preparing target folder: $TargetFolder" -ForegroundColor Yellow
    if (Test-Path $TargetFolder) {
        Remove-Item $TargetFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

    # Download the zip file
    $tempZipPath = Join-Path $env:TEMP "qemu-img-temp.zip"
    Write-Host "Downloading $($zipAsset.name)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $tempZipPath -UserAgent "PowerShell"

    # Extract the zip file
    Write-Host "Extracting to $TargetFolder..." -ForegroundColor Yellow
    Expand-Archive -Path $tempZipPath -DestinationPath $TargetFolder -Force

    # Clean up temporary zip file
    Remove-Item $tempZipPath -Force

    # Add to PATH for current session
    Write-Host "Adding to PATH for current session..." -ForegroundColor Yellow
    $env:PATH = "$TargetFolder;$env:PATH"

    # Verify installation
    Write-Host "Verifying installation..." -ForegroundColor Yellow
    $qemuImgPath = Join-Path $TargetFolder "qemu-img.exe"
    if (Test-Path $qemuImgPath) {
        Write-Host "[OK] qemu-img.exe found at: $qemuImgPath" -ForegroundColor Green
        # Try to run qemu-img to verify it works
        try {
            $version = & $qemuImgPath --version 2>$null
            if ($version) {
                Write-Host "[OK] qemu-img is working: $($version.Split([Environment]::NewLine)[0])" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "[WARNING] qemu-img.exe exists but may have dependency issues" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[ERROR] qemu-img.exe not found in extracted files" -ForegroundColor Red
    }

    Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
    Write-Host "qemu-img is now available in your current PowerShell session." -ForegroundColor Green
    Write-Host "You can run 'qemu-img --version' to test it." -ForegroundColor Cyan
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
