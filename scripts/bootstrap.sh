#!/usr/bin/env bash
# bootstrap.sh - Quick setup script for drnaseq-stack repository

set -e  # Exit on any error

# Print colorful status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Check if we're in a git repository
if [ ! -d .git ]; then
  error "Not in a git repository root. Please run from the repository root."
  exit 1
fi

info "Starting drnaseq-stack repository bootstrap..."

# Check GitHub CLI installation
if ! command -v gh &> /dev/null; then
    error "GitHub CLI not found. Please install it: https://cli.github.com/manual/installation"
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &> /dev/null; then
    error "Not authenticated with GitHub. Please run: gh auth login"
    exit 1
fi

# Create essential directories
info "Creating directory structure..."
mkdir -p .github/{ISSUE_TEMPLATE,workflows}
mkdir -p knowledge/{learned-lessons,benchmarks,publications}
mkdir -p scripts
mkdir -p meta/{phase-reflections,docs}
mkdir -p docs
success "Directory structure created."

success "✅ Repository setup complete! Your drnaseq-stack is ready for development."
