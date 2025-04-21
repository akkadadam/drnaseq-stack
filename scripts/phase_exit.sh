#!/usr/bin/env bash
# phase_exit.sh - Generate phase exit report and validation

# Print colorful status messages
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Check arguments
if [ $# -ne 1 ]; then
  error "Usage: $0 <phase_number>"
  echo "Example: $0 2.5"
  exit 1
fi

PHASE=$1

# Validate phase number
if ! [[ "$PHASE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  error "Invalid phase number: $PHASE"
  echo "Phase must be a number like 2.5, 3, 4, or 5"
  exit 1
fi

# Get repository information
REPO_INFO=$(gh repo view --json name,owner --jq '"\(.owner.login)/\(.name)"')

info "Generating exit report for Phase $PHASE"

# Check label structure
info "Validating label structure..."
if [ -f scripts/validate_labels.sh ]; then
  ./scripts/validate_labels.sh
  if [ $? -ne 0 ]; then
    error "Label validation failed. Please fix missing labels."
    exit 1
  fi
else
  warn "Label validation script not found. Skipping validation."
fi

# Check critical path issues for phase
info "Checking critical path issues for Phase $PHASE..."

critical_issues=$(gh issue list --repo "$REPO_INFO" --json number,title,state,labels --jq '.[] | select(.labels[].name == "phase:'$PHASE'") | select(.labels[].name == "priority:high") | {number, title, state}')

if [ -z "$critical_issues" ]; then
  warn "No critical path issues found for Phase $PHASE"
else
  echo "$critical_issues" | jq -r '.number, .title, .state' | paste - - - | while read -r number title state; do
    if [ "$state" == "OPEN" ]; then
      warn "  ❌ #$number $title is still OPEN"
    else
      success "  ✅ #$number $title is CLOSED"
    fi
  done
fi

# Check for phase exit checklist
info "Checking phase exit checklist..."
exit_checklist=$(gh issue list --repo "$REPO_INFO" --json number,title,body --jq '.[] | select(.title | contains("[PHASE-EXIT]: Phase '$PHASE'")) | {number, title, body}')

if [ -z "$exit_checklist" ]; then
  warn "No phase exit checklist found. Creating one..."
  
  if [ -f scripts/create_milestones.sh ]; then
    info "Creating phase exit checklist using create_milestones.sh..."
    # TODO: Implement selective creation of a single phase exit checklist
    warn "For now, please run create_milestones.sh to create all milestones and exit checklists."
  else
    warn "Milestone creation script not found. Please create exit checklist manually."
  fi
else
  checklist_number=$(echo "$exit_checklist" | jq -r '.number')
  success "Found exit checklist: #$checklist_number"
  
  # Extract completion status
  completion_items=$(echo "$exit_checklist" | jq -r '.body' | grep -E '^\s*-\s+\[[ x]\]')
  completed=$(echo "$completion_items" | grep -c '\[x\]')
  total=$(echo "$completion_items" | wc -l)
  
  info "Completion status: $completed/$total items checked"
  
  if [ "$completed" -eq "$total" ]; then
    success "All exit checklist items are complete!"
  else
    warn "Exit checklist is not complete. Please review and update."
  fi
fi

# Check for knowledge artifacts
info "Checking for knowledge artifacts..."
knowledge_path="knowledge/learned-lessons/phase_${PHASE/./_}_completion.md"

if [ -f "$knowledge_path" ]; then
  success "Found phase completion document: $knowledge_path"
else
  warn "No phase completion document found."
  info "Creating template from meta/phase-reflections/template.md..."
  
  mkdir -p knowledge/learned-lessons
  if [ -f meta/phase-reflections/template.md ]; then
    sed "s/X\.X/$PHASE/g" meta/phase-reflections/template.md > "$knowledge_path"
    success "Created template at $knowledge_path"
  else
    warn "Template not found. Please create phase completion document manually."
  fi
fi

success "Phase $PHASE exit report completed!"
