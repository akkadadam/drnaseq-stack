#!/usr/bin/env bash
# bootstrap_phase.sh - Bootstrap a new phase

set -euo pipefail

# Check arguments
if [ $# -ne 1 ]; then
  echo "Usage: $0 <phase-number>"
  echo "Example: $0 4"
  exit 1
fi

PHASE="$1"
PREV_PHASE=$(echo "$PHASE - 0.5" | bc)

echo "Bootstrapping Phase $PHASE..."

# Verify phase exit checklist for previous phase
./scripts/phase_exit.sh --phase "$PREV_PHASE"

# Create milestone for the new phase
./scripts/create_milestones.sh --phase "$PHASE"

# Update README badge
sed -i '' "s/Phase-[0-9.]* [A-Za-z ]*/Phase-$PHASE $(grep "Phase $PHASE:" scripts/create_milestones.sh | head -1 | cut -d':' -f2 | cut -d'"' -f1)/" README.md

# Create or update documentation
mkdir -p docs/phase-$PHASE
touch docs/phase-$PHASE/README.md

echo "Phase $PHASE bootstrap complete!"
echo "Next steps:"
echo "1. Create critical path issues for Phase $PHASE"
echo "2. Set up GitHub Project views for the new phase"
echo "3. Update the roadmap documentation"
