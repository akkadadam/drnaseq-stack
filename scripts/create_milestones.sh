#!/usr/bin/env bash
# create_milestones.sh
set -euo pipefail

# Create milestone data as simple arrays
PHASES=(
  "Phase 2.5: Reliability Layer" 
  "Phase 3: Reality Bridge" 
  "Phase 4: Orchestrator" 
  "Phase 5: Knowledge Scaleout"
)

DESCRIPTIONS=(
  "Establish the reliability framework with interface abstractions, logging, and validation"
  "Bridge to production-grade capabilities with POD5 integration and real basecalling"
  "Implement workflow orchestration and ecosystem integration"
  "Documentation, knowledge transfer, and community engagement"
)

DUE_DATES=(
  "2024-05-15"
  "2024-06-15"
  "2024-07-15"
  "2024-08-15"
)

# Process command-line arguments for specific phase
PHASE_FILTER=""
if [[ $# -gt 0 && $1 == "--phase" && $# -gt 1 ]]; then
  PHASE_FILTER=$2
  echo "Creating milestone only for Phase $PHASE_FILTER"
fi

# Get repository info dynamically
REPO_INFO=$(gh repo view --json name,owner --jq '"\(.owner.login)/\(.name)"')
echo "Repository: $REPO_INFO"

# Create each milestone
for i in "${!PHASES[@]}"; do
  phase_name="${PHASES[$i]}"
  description="${DESCRIPTIONS[$i]}"
  due_date="${DUE_DATES[$i]}"
  
  # Skip if filtering by phase and this isn't the requested one
  if [[ -n "$PHASE_FILTER" && ! "$phase_name" =~ $PHASE_FILTER ]]; then
    continue
  fi
  
  echo "Creating milestone: $phase_name"
  response=$(gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO_INFO/milestones" \
    -f title="$phase_name" \
    -f state="open" \
    -f description="$description" \
    -f due_on="${due_date}T00:00:00Z")
  
  # Extract milestone number and ensure it's valid
  echo "Response: $response"
  milestone_number=$(echo "$response" | jq -r '.number')
  echo "Milestone number: $milestone_number"
  
  if [[ -z "$milestone_number" || "$milestone_number" == "null" ]]; then
    echo "Error: Could not get valid milestone number."
    echo "Full response: $response"
    continue
  fi
  
  # Extract phase number from milestone title (e.g., "Phase 2.5" -> "2.5")
  phase_number=$(echo "$phase_name" | grep -oE '[0-9]+(\.[0-9]+)?')
  
  # Create exit checklist issue for this phase with retry logic
  echo "Creating exit checklist for $phase_name"
  for attempt in {1..3}; do
    echo "Attempt $attempt to create issue with milestone $milestone_number"
    # Wait longer between attempts
    sleep 5
    
    if gh issue create \
      --title "[PHASE-EXIT]: Phase $phase_number Completion Checklist" \
      --body "# Phase $phase_number Exit Checklist

This issue tracks the completion criteria for $phase_name.

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
      --milestone "$milestone_number" \
      --label "documentation,phase:$phase_number"; then
      
      echo "✅ Successfully created issue with milestone $milestone_number"
      break
    else
      echo "❌ Failed to create issue with milestone $milestone_number"
      if [ "$attempt" -eq 3 ]; then
        echo "⚠️ Failed to attach issue to milestone after 3 attempts"
      fi
    fi
  done
done

echo "All milestones created successfully!"
