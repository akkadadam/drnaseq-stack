# Phase Transition Guide

This document describes the process for transitioning between phases in the drnaseq-stack project.

## Phase Transition Process

1. Run the exit checklist for the current phase:
   ```bash
   ./scripts/phase_exit.sh X.X
Where X.X is the phase number (e.g., 2.5, 3, 4, 5)

Create the milestone for the next phase:
bash./scripts/create_milestones.sh --phase Y
Where Y is the next phase number
Bootstrap the next phase:
bash./scripts/bootstrap_phase.sh Y
Where Y is the next phase number
Update the README badge:
bashsed -i '' '1s|^.*Phase-.*-.*)]|[![Phase: Y - Phase Name](https://img.shields.io/badge/Phase-Y%20Phase%20Name-COLOR)]|' README.md
Replace Y, "Phase Name", and COLOR with appropriate values
Create/update critical path issues for the new phase
Generate a new critical path visualization:
bash./scripts/generate_critical_path.py > meta/critical_path_visualization.md
gh issue create --title "Critical Path Visualization" --body-file meta/critical_path_visualization.md --label "documentation"


Phase Completion Criteria
Each phase has specific criteria that must be met before transitioning:

All critical path issues closed
Documentation updated
Tests passing
Knowledge artifacts captured
Performance benchmarks documented
Team retrospective conducted

Use the exit checklist issue automatically created with each phase to track completion.
