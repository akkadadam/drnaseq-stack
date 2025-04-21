#!/bin/bash
# create_labels.sh - Create all needed labels with consistent formatting

# Print colorful status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Create or update label with proper error handling
create_label() {
  local name="$1"
  local color="$2"
  local description="$3"
  
  info "Creating/updating label: $name"
  gh label create "$name" --color "$color" --description "$description" --force
  if [ $? -eq 0 ]; then
    success "Label created/updated: $name"
  else
    error "Failed to create label: $name"
  fi
}

# Phase labels
create_label "phase:2.5" "9932CC" "Reliability Layer Phase"
create_label "phase:3" "4169E1" "Reality Bridge Phase"
create_label "phase:4" "3CB371" "Orchestrator Phase"
create_label "phase:5" "FF8C00" "Knowledge Scaleout Phase"

# Component labels
create_label "component:logging" "87CEEB" "Logging System"
create_label "component:basecaller" "F08080" "Basecaller Implementation"
create_label "component:orchestrator" "FFD700" "Workflow Orchestration"
create_label "component:validation" "98FB98" "Validation Framework"
create_label "component:benchmark" "DDA0DD" "Performance Benchmarking"
create_label "component:cicd" "20B2AA" "CI/CD Pipeline"

# Status labels
create_label "status:ready" "228B22" "Ready for development"
create_label "status:blocked" "DC143C" "Blocked by dependency"
create_label "status:in-progress" "1E90FF" "Currently in progress"
create_label "status:needs-triage" "8B0000" "Needs review or assignment"

# Priority labels
create_label "priority:high" "FF4500" "High priority task"
create_label "priority:medium" "FFA500" "Medium priority task"
create_label "priority:low" "FFD700" "Low priority task"

success "All labels have been created or updated!"
