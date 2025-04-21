#!/usr/bin/env bash

# Print all labels in raw format
echo "Fetching all labels..."
gh label list --json name,color,description

# Now fetch just the names for debugging
echo -e "\n\nFetching just the names..."
existing_labels=$(gh label list --json name --jq '.[].name')
echo "$existing_labels"

# Check specifically for our priority labels
echo -e "\n\nSearching for priority labels..."
echo "$existing_labels" | grep -E "priority:"
