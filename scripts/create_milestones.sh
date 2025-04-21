#!/usr/bin/env bash
# create_milestones.sh - Create milestones and exit checklists
set -euo pipefail

# Basic bash version check
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script requires bash. Please run with: bash $(basename "$0")"
  exit 1
fi

# Define phases as tuples [name, description, due_date]
PHASES=(
  "Phase 2.5: Reliability Layer" 
  "Establish the reliability framework with interface abstractions, logging, and validation" 
  "2024-05-15"
  
  "Phase 3: Reality Bridge" 
  "Bridge to production-grade capabilities with POD5 integration and real basecalling" 
  "2024-06-15"
  
  "Phase 4: Orchestrator" 
  "Implement workflow orchestration and ecosystem integration" 
  "2024-07-15"
  
  "Phase 5: Knowledge Scaleout" 
  "Documentation, knowledge transfer, and community engagement" 
  "2024-08-15"
)

# Allow creating a single milestone by phase
TARGET_PHASE=""
if [[ $# -eq 2 && "$1" == "--phase" ]]; then
  TARGET_PHASE="$2"
  echo "Creating milestone for Phase $TARGET_PHASE only"
fi

# Load environment variables if .env exists
if [ -f .env ]; then
  source .env
  echo "Loaded environment from .env file"
else
  # GitHub repository information from git config
  REPO_OWNER="$(git config --get remote.origin.url | cut -d/ -f4)"
  REPO_NAME="$(git config --get remote.origin.url | cut -d/ -f5 | cut -d. -f1)"
  echo "Using repository information from git config: $REPO_OWNER/$REPO_NAME"
fi

# Loop through phases
for ((i=0; i<${#PHASES[@]}; i+=3)); do
  milestone="${PHASES[$i]}"
  description="${PHASES[$i+1]}"
  due_date="${PHASES[$i+2]}"
  
  # Extract phase number (e.g., "Phase 2.5: Reliability Layer" -> "2.5")
  current_phase=$(echo "$milestone" | grep -oE '[0-9]+(\.[0-9]+)?')
  
  # Skip if we're targeting a specific phase and this isn't it
  if [[ -n "$TARGET_PHASE" && "$current_phase" != "$TARGET_PHASE" ]]; then
    continue
  fi
  
  echo "Creating milestone: $milestone"
  response=$(gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    /repos/$REPO_OWNER/$REPO_NAME/milestones \
    -f title="$milestone" \
    -f state="open" \
    -f description="$description" \
    -f due_on="${due_date}T00:00:00Z")
  
  milestone_number=$(echo $response | jq -r '.number')
  
  # Create exit checklist issue for this phase
  echo "Creating exit checklist for $milestone"
  gh issue create \
    --title "[PHASE-EXIT]: Phase $current_phase Completion Checklist" \
    --body "# Phase $current_phase Exit Checklist

This issue tracks the completion criteria for $milestone.

## Milestone Information
- Due Date: $due_date
- Description: $description
- Milestone: #$milestone_number

## Exit Requirements
- [ ] All critical-path issues are closed
- [ ] Documentation is updated
- [ ] Tests are passing
- [ ] Knowledge artifacts are captured
- [ ] Performance benchmarks are documented
- [ ] Team has conducted phase retrospective

## Success Metrics
*To be defined*

## Next Phase Preparation
*To be defined*

This issue should be used during the phase transition to ensure proper completion and handoff." \
    --milestone $milestone_number \
    --label "documentation,phase:$current_phase"
done

echo "Milestone creation completed successfully!"
