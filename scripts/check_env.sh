#!/usr/bin/env bash
# check_env.sh - Validate environment setup for drnaseq-stack

set -euo pipefail

# Print colorful status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Check if a command exists
check_command() {
  local cmd="$1"
  local install_hint="$2"
  
  if command -v "$cmd" &> /dev/null; then
    success "$cmd: $(command -v "$cmd")"
    if [[ "$cmd" != "gh" && "$cmd" != "jq" ]]; then
      local version=$($cmd --version 2>&1 | head -n 1)
      info "   Version: $version"
    fi
    return 0
  else
    error "$cmd: Not found"
    if [[ -n "$install_hint" ]]; then
      info "   Install: $install_hint"
    fi
    return 1
  fi
}

# Header
echo "===================================================="
echo "      drnaseq-stack Environment Validator           "
echo "===================================================="

# Check for critical tools
info "Checking development tools..."
check_command "git" "Install Git: https://git-scm.com/downloads"
check_command "gh" "Install GitHub CLI: https://cli.github.com/manual/installation"
check_command "jq" "Install jq: https://stedolan.github.io/jq/download/"
check_command "python3" "Install Python: https://www.python.org/downloads/"

# Check for bioinformatics tools
info "Checking bioinformatics tools..."
check_command "samtools" "Install samtools: http://www.htslib.org/download/"
check_command "minimap2" "Install minimap2: https://github.com/lh3/minimap2"
check_command "seqkit" "Install seqkit: https://bioinf.shenwei.me/seqkit/download/"
check_command "dorado" "Install dorado: Follow ONT instructions"

# Check GitHub authentication
info "Checking GitHub authentication..."
if gh auth status &> /dev/null; then
  success "GitHub: Authenticated"
else
  error "GitHub: Not authenticated"
  info "   Run: gh auth login"
fi

# Check repository structure
info "Checking repository structure..."
required_dirs=(".github" "scripts" "knowledge" "meta" "docs")
for dir in "${required_dirs[@]}"; do
  if [ -d "$dir" ]; then
    success "$dir: Directory exists"
  else
    warn "$dir: Directory missing"
  fi
done

echo ""
echo "===================================================="
echo "              Validation Complete                   "
echo "===================================================="
