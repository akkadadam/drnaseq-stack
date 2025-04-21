#!/bin/bash
# create_milestones.sh

# Define milestone data with proper quoting for array keys
declare -A milestones
milestones["Phase 2.5: Reliability Layer"]="Establish the reliability framework with interface abstractions, logging, and validation|2024-05-15"
milestones["Phase 3: Reality Bridge"]="Bridge to production-grade capabilities with POD5 integration and real basecalling|2024-06-15"
milestones["Phase 4: Orchestrator"]="Implement workflow orchestration and ecosystem integration|2024-07-15"
milestones["Phase 5: Knowledge Scaleout"]="Documentation, knowledge transfer, and community engagement|2024-08-15"

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

# Create milestone and exit checklist issue for each phase
for milestone in "${!milestones[@]}"; do
  IFS='|' read -r description due_date <<< "${milestones[$milestone]}"
  
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
  
  # Extract phase number from milestone title (e.g., "Phase 2.5" -> "2.5")
  phase_number=$(echo $milestone | grep -oE '[0-9]+(\.[0-9]+)?')
  
  # Create exit checklist issue for this phase
  echo "Creating exit checklist for $milestone"
  gh issue create \
    --title "[PHASE-EXIT]: Phase $phase_number Completion Checklist" \
    --body "# Phase $phase_number Exit Checklist

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
    --label "documentation,phase:$phase_number"
done

echo "All milestones and exit checklists created successfully!"
