#!/bin/bash

# Default command is 'build'
COMMAND="${1:-build}"
SKIP_BUNDLE_EXEC=$2

# Function to log messages with timestamp and level-based color
function log_message {
    local message="$1"
    local level="${2:-info}"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_msg="[$timestamp] [$level] $message"

    case "$level" in
    info) echo "$log_msg" ;;
    warning) echo -e "\033[33m$log_msg\033[0m" ;; # Yellow for warnings
    error) echo -e "\033[31m$log_msg\033[0m" ;;   # Red for errors
    *) echo "$log_msg" ;;
    esac
}

# Function to check if required dependencies are installed
function check_dependencies {
    local dependencies=("$@")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_message "$dep is not installed or not in PATH." "error"
            exit 1
        fi
    done
}

# Function to install necessary dependencies for the project
function init_dependencies {
    log_message "Initializing project dependencies..."

    # Run bundle install if bundle is available
    if command -v bundle &>/dev/null; then
        log_message "Running bundle install..."
        if ! bundle install; then
            log_message "Failed to run bundle install." "error"
            exit 1
        fi
        log_message "Bundle install completed successfully."
    else
        log_message "Bundle is not installed or not in PATH. Skipping bundle install." "warning"
    fi

    # Run npm install if npm is available
    if command -v npm &>/dev/null; then
        log_message "Running npm install..."
        if ! npm install; then
            log_message "Failed to run npm install." "error"
            exit 1
        fi
        log_message "NPM install completed successfully."
    else
        log_message "NPM is not installed or not in PATH. Skipping npm install." "warning"
    fi
}

# Function to clean Jekyll site
function clean_site {
    log_message "Cleaning Jekyll site..."
    if [ "$SKIP_BUNDLE_EXEC" = true ]; then
        jekyll clean
    else
        bundle exec jekyll clean
    fi
    log_message "Jekyll site cleaned successfully."
}

# Function to build Jekyll site and run Gulp tasks
function build_site {
    clean_site

    log_message "Building Jekyll site..."
    if [ "$SKIP_BUNDLE_EXEC" = true ]; then
        jekyll build "$@"
    else
        bundle exec jekyll build "$@"
    fi
    log_message "Jekyll site built successfully."

    log_message "Running Gulp tasks..."
    if ! npx gulp; then
        log_message "Gulp task failed." "error"
        exit 1
    fi
    log_message "Gulp tasks completed successfully."
}

# Function to serve Jekyll site with development configuration
function serve_site {
    clean_site

    log_message "Starting Jekyll serve..."
    if [ "$SKIP_BUNDLE_EXEC" = true ]; then
        jekyll serve --trace --watch --config '_config.yml,_config.dev.yml' "$@"
    else
        bundle exec jekyll serve --trace --watch --config '_config.yml,_config.dev.yml' "$@"
    fi
    log_message "Jekyll serve started successfully."
}

# Set working directory to project root if _config.yml exists
if [ -f "$PWD/_config.yml" ]; then
    PROJECT_DIR=$(realpath "$PWD")
    cd "$PROJECT_DIR" || exit 1
    log_message "Changed directory to project root: $PROJECT_DIR"
else
    log_message "_config.yml not found in the current directory. Ensure you are in the correct location." "error"
    exit 1
fi

# Dependency check for essential tools
check_dependencies "bundle" "jekyll" "npx"

# Main command switch to execute appropriate function based on user input
case "$COMMAND" in
"init") init_dependencies ;;
"clean") clean_site ;;
"build") build_site "$@" ;;
"serve") serve_site "$@" ;;
*)
    log_message "Invalid command. Use 'init', 'build', 'serve', or 'clean'." "error"
    exit 1
    ;;
esac
