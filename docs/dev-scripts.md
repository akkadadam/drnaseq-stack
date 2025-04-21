# Development Scripts

This document describes the utility scripts available in the `scripts/` directory.

## Bootstrap Scripts

### `bootstrap.sh`

**Purpose**: Quick setup script for the drnaseq-stack repository.
**Usage**: `./scripts/bootstrap.sh`
**Features**:
- Creates directory structure
- Validates GitHub CLI installation and authentication
- Checks and creates required labels
- Sets up initial project structure

## Label Management

### `create_labels.sh`

**Purpose**: Creates all required labels with consistent formatting.
**Usage**: `./scripts/create_labels.sh`
**Features**:
- Creates phase, component, status, and priority labels
- Uses consistent color schemes
- Handles errors gracefully

### `validate_labels.sh`

**Purpose**: Validates that all required labels exist.
**Usage**: `./scripts/validate_labels.sh`
**Features**:
- Checks for all required phase, component, status, and priority labels
- Reports any missing labels

## Project Management

### `create_milestones.sh`

**Purpose**: Creates project milestones with exit checklists.
**Usage**: `./scripts/create_milestones.sh`
**Features**:
- Creates milestones for each project phase
- Adds phase exit checklist issues linked to milestones
- Sets due dates and descriptions
