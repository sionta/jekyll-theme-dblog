[CmdletBinding()]
param (
    [string]$command
)

function Write-Log {
    param (
        [string]$message,
        [string]$level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] [$level] $message"
}

function Test-Dependencies {
    # Check for required commands
    ('ruby', 'gem', 'bundle', 'jekyll').ForEach({
            if (-not (Get-Command $_ -ErrorAction SilentlyContinue)) {
                Write-Log "Please install $_" 'ERROR'
                exit
            }
        })
}

function Set-ProjectLocation {
    if (Test-Path "$PSScriptRoot/../_config.yml") {
        Set-Location "$PSScriptRoot/../"
        Write-Log 'Changed directory to project root.'
    }
}

function Build {
    Write-Log 'Cleaning Jekyll site...'
    try {
        bundle exec jekyll clean
        Write-Log 'Jekyll cleaned successfully.'

        Write-Log 'Building Jekyll site...'
        bundle exec jekyll build $args
        Write-Log 'Jekyll site built successfully.'

        Write-Log 'Running Gulp...'
        npx gulp
    } catch {
        Write-Log "Failed during build process: $_" 'ERROR'
    }
}

function Serve {
    Write-Log 'Cleaning Jekyll site...'
    bundle exec jekyll clean
    Write-Log 'Starting Jekyll serve...'
    bundle exec jekyll serve --trace --watch --config '_config.yml,_config.dev.yml'
}

# Main script execution
Test-Dependencies
Set-ProjectLocation

if ($command -eq 'build') {
    Build
} elseif ($command -eq 'serve') {
    Serve
} else {
    Write-Log "Invalid command. Use 'build' or 'serve'." 'ERROR'
}
