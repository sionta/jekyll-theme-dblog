#!/bin/bash

# Function to log messages
log() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message"
}

# Function to check for required commands
check_dependencies() {
    for cmd in ruby gem bundle jekyll; do
        if ! command -v "$cmd" &>/dev/null; then
            log "Please install $cmd" "ERROR"
            exit 1
        fi
    done
}

# Function to set the project location
set_project_location() {
    if [ -f "$PWD/../_config.yml" ]; then
        cd "$PWD/.." || exit
        log "Changed directory to project root."
    fi
}

# Function to build the Jekyll site
build() {
    log "Cleaning Jekyll site..."
    bundle exec jekyll clean && log "Jekyll cleaned successfully."

    log "Building Jekyll site..."
    bundle exec jekyll build "$@" && log "Jekyll site built successfully."

    log "Running Gulp..."
    npx gulp
}

# Function to serve the Jekyll site
serve() {
    log "Cleaning Jekyll site..."
    bundle exec jekyll clean

    log "Starting Jekyll serve..."
    bundle exec jekyll serve --trace --watch --config '_config.yml,_config.dev.yml'
}

# Main script execution
command="$1"
check_dependencies
set_project_location

case "$command" in
build)
    build "${@:2}"
    ;;
serve)
    serve
    ;;
*)
    log "Invalid command. Use 'build' or 'serve'." "ERROR"
    exit 1
    ;;
esac
