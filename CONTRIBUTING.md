# Contributing to drnaseq-stack

## Workflow

1. Select an issue to work on
2. Create a branch using the issue number: `git checkout -b feature/issue-<number>`
3. Make your changes
4. Use a phase tag in your commit message: `git commit -m "[phase:X.X] Description"`
5. Create a pull request linking to the issue: `Closes #<issue-number>`
6. Await review from component owner

## Commit Message Format

All commit messages must include a phase tag:
[phase:2.5] Add logging interface

Valid phases are: 1, 2, 2.5, 3, 4, 5

## Label System

Issues are organized by:
- **Phase**: Which development phase the issue belongs to
- **Component**: Which part of the system is affected
- **Status**: Current state of the issue
- **Priority**: How urgent the issue is

## Development Scripts

See [docs/dev-scripts.md](docs/dev-scripts.md) for available utility scripts.
