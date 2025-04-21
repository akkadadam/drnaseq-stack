# Phase Transition Process

This document outlines the process for transitioning between phases in the drnaseq-stack project.

## Phase Exit Checklist

Each phase has an exit checklist that must be completed before moving to the next phase. The checklist is created automatically when milestones are set up.

## Using the Phase Exit Script

The `phase_exit.sh` script helps validate whether a phase is ready for completion.

### Usage

```bash
./scripts/phase_exit.sh --phase 3
What the Script Does

Checks Critical Path Issues: Verifies that all critical path issues for the phase are closed.
Validates Phase Exit Checklist: Checks if the phase exit checklist exists and items are checked off.
Ensures Knowledge Artifacts: Confirms that phase completion documentation exists.

Phase Completion Documentation
For each phase, create a phase completion document in knowledge/learned-lessons/phase_X_completion.md (where X is the phase number). The script can generate a template for you if one doesn't exist.
Moving to the Next Phase

Update README Badge: Change the phase badge in the README to reflect the new phase.
Create New Milestones: If not already done, create milestones for the next phase.
Plan Critical Path Issues: Create and assign critical path issues for the next phase.
