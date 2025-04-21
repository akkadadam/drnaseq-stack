#!/bin/bash
# validate_labels.sh - Confirm all required labels exist

# Define expected labels by category
phase_labels=("phase:2.5" "phase:3" "phase:4" "phase:5")
component_labels=("component:logging" "component:basecaller" "component:orchestrator" "component:validation" "component:benchmark" "component:cicd")
status_labels=("status:ready" "status:blocked" "status:in-progress" "status:needs-triage")
priority_labels=("priority:high" "priority:medium" "priority:low")

# Print colorful status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Get all existing labels
info "Fetching existing labels..."
existing_labels=$(gh label list --json name --jq '.[].name')

# Debug: Print all labels to see what we're getting
echo "DEBUG: All labels found:"
echo "$existing_labels"

# Check if label commands executed successfully
if [ -z "$existing_labels" ]; then
  error "Failed to fetch labels. Make sure you're in a git repository and authenticated with GitHub."
  exit 1
fi

# Check if all expected labels exist
missing_labels=()

check_labels() {
  local label_type=$1
  shift
  local labels=("$@")

  info "Checking $label_type labels..."
  for label in "${labels[@]}"; do
    # More flexible grep pattern with word boundaries
    if ! echo "$existing_labels" | grep -E "^${label}$" > /dev/null; then
      missing_labels+=("$label")
      warn "  ❌ Missing: $label"
    else
      success "  ✅ Found: $label"
    fi
  done
}

check_labels "phase" "${phase_labels[@]}"
check_labels "component" "${component_labels[@]}"
check_labels "status" "${status_labels[@]}"
check_labels "priority" "${priority_labels[@]}"

# Report results
if [ ${#missing_labels[@]} -eq 0 ]; then
  success "✅ All required labels exist!"
  exit 0
else
  error "❌ Missing ${#missing_labels[@]} labels. Please create them."
  exit 1
fi
