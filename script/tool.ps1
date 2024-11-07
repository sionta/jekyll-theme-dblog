[CmdletBinding()]
param (
    [ValidateSet('serve', 'build', 'clean', 'init')]
    [string]$Command = 'build',

    [switch]$SkipBundleExec
)

# Function to log messages with timestamp and level-based color
function Write-Logger {
    param (
        [string]$Message,
        [ValidateSet('info', 'warning', 'error')]
        [string]$Level = 'info'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $msg = "$timestamp [$($Level.ToUpper())] $Message"

    switch ($Level) {
        'info' { Write-Host $msg }
        'warning' { Write-Warning $msg }
        'error' { Write-Error $msg }
    }
}

# Function to check if required dependencies are installed
function Check-Dependencies {
    param (
        [string[]]$Dependencies
    )

    foreach ($dependency in $Dependencies) {
        if (-not (Get-Command $dependency -ErrorAction SilentlyContinue)) {
            Write-Logger "$dependency is not installed or not in PATH." 'error'
            exit 1
        }
    }
}

# Function to install necessary dependencies for the project (bundle install and npm install)
function Init-Dependencies {
    Write-Logger 'Initializing project dependencies...'

    # Run bundle install if bundle is available
    if (Get-Command bundle -ErrorAction SilentlyContinue) {
        Write-Logger 'Running bundle install...'
        if (-not (bundle install)) {
            Write-Logger 'Failed to run bundle install.' 'error'
            exit 1
        }
        Write-Logger 'Bundle install completed successfully.'
    } else {
        Write-Logger 'Bundle is not installed or not in PATH. Skipping bundle install.' 'warning'
    }

    # Run npm install if npm is available
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Logger 'Running npm install...'
        if (-not (npm install)) {
            Write-Logger 'Failed to run npm install.' 'error'
            exit 1
        }
        Write-Logger 'NPM install completed successfully.'
    } else {
        Write-Logger 'NPM is not installed or not in PATH. Skipping npm install.' 'warning'
    }
}

# Function to clean Jekyll site
function Clean-Site {
    Write-Logger 'Cleaning Jekyll site...'
    if ($SkipBundleExec) {
        jekyll clean
    } else {
        bundle exec jekyll clean
    }
    Write-Logger 'Jekyll site cleaned successfully.'
}

# Function to build Jekyll site and run Gulp tasks
function Build-Site {
    Clean-Site

    Write-Logger 'Building Jekyll site...'
    if ($SkipBundleExec) {
        jekyll build @args
    } else {
        bundle exec jekyll build @args
    }
    Write-Logger 'Jekyll site built successfully.'

    Write-Logger 'Running Gulp tasks...'
    try {
        npx gulp @args
        Write-Logger 'Gulp tasks completed successfully.'
    } catch {
        Write-Logger "Gulp task failed: $_" 'error'
    }
}

# Function to serve Jekyll site with development configuration
function Serve-Site {
    Clean-Site

    Write-Logger 'Starting Jekyll serve...'
    if ($SkipBundleExec) {
        jekyll serve --trace --watch --config '_config.yml,_config.dev.yml' @args
    } else {
        bundle exec jekyll serve --trace --watch --config '_config.yml,_config.dev.yml' @args
    }
    Write-Logger 'Jekyll serve started successfully.'
}

# Set working directory to project root if _config.yml exists
if (Test-Path "$PSScriptRoot/../_config.yml") {
    $project = Resolve-Path "$PSScriptRoot/.."
    Set-Location $project
    Write-Logger "Changed directory to project root: $project"
} else {
    Write-Logger '_config.yml not found in parent directory. Ensure you are in the correct location.' 'error'
    exit 1
}

# Dependency check for essential tools
Check-Dependencies -Dependencies @('bundle', 'jekyll', 'npx')

# Main command switch to execute appropriate function based on user input
switch ($Command) {
    'init' { Init-Dependencies }
    'clean' { Clean-Site }
    'build' { Build-Site }
    'serve' { Serve-Site }
    default { Write-Logger "Invalid command. Use 'init', 'build', 'serve', or 'clean'." 'error'; exit 1 }
}
