#!/usr/bin/env bash
# generate_weekly_digest.sh - Generate a weekly project status digest
set -euo pipefail

# Set date ranges
CURRENT_DATE=$(date +"%Y-%m-%d")
WEEK_AGO=$(date -d "7 days ago" +"%Y-%m-%d" 2>/dev/null || date -v -7d +"%Y-%m-%d")

# Load repo info
REPO_INFO="$(git config --get remote.origin.url | cut -d/ -f4)/$(git config --get remote.origin.url | cut -d/ -f5 | cut -d. -f1)"

# Header
echo "# drnaseq-stack Weekly Digest: $WEEK_AGO to $CURRENT_DATE"
echo ""

# In Progress Issues
echo "## 🚀 In Progress"
echo ""
in_progress=$(gh issue list --repo "$REPO_INFO" --label "status:in-progress" --json number,title,url,labels,assignees)

if [ -n "$in_progress" ]; then
  # Group by component
  gh issue list --repo "$REPO_INFO" --label "status:in-progress" --json number,title,url,labels,assignees | 
  jq -r '.[] | 
    (.labels[] | select(.name | startswith("component:")) | .name | sub("component:"; "")) as $component | 
    (.assignees[0].login // "unassigned") as $assignee |
    [$component, .number, .title, $assignee, .url] | @tsv' | 
  sort | 
  awk -F"\t" '
    BEGIN { last_component = ""; }
    {
      if ($1 != last_component) {
        print "### " $1;
        print "";
        last_component = $1;
      }
      print "- [#" $2 "](" $5 ") " $3 " (@" $4 ")";
    }'
else
  echo "No issues are currently in progress."
  echo ""
fi

# Blocked Issues
echo "## 🚧 Blocked"
echo ""
blocked=$(gh issue list --repo "$REPO_INFO" --label "status:blocked" --json number,title,url,labels,body)

if [ -n "$blocked" ]; then
  gh issue list --repo "$REPO_INFO" --label "status:blocked" --json number,title,url,labels,body | 
  jq -r '.[] | 
    (.labels[] | select(.name | startswith("component:")) | .name | sub("component:"; "")) as $component | 
    (.body | capture("(?:Blocked by:|blocked by:)\\s+#(\\d+)").1 // "Unknown") as $blocker |
    [$component, .number, .title, $blocker, .url] | @tsv' | 
  sort | 
  awk -F"\t" '
    BEGIN { last_component = ""; }
    {
      if ($1 != last_component) {
        print "### " $1;
        print "";
        last_component = $1;
      }
      print "- [#" $2 "](" $5 ") " $3 " (Blocked by: #" $4 ")";
    }'
else
  echo "No issues are currently blocked."
  echo ""
fi

# Recently Completed
echo "## ✅ Recently Completed"
echo ""
completed=$(gh issue list --repo "$REPO_INFO" --state closed --json number,title,url,closedAt --jq '.[] | select(.closedAt >= "'$WEEK_AGO'") | {number, title, url, closedAt}')

if [ -n "$completed" ]; then
  echo "$completed" | jq -r 'sort_by(.closedAt) | reverse | .[] | "- [#\(.number)](\(.url)) \(.title) (closed \(.closedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"'
else
  echo "No issues were closed in the past week."
fi

echo ""
echo "## 📊 Progress by Phase"
echo ""

# Phase statistics
phases=("phase:2.5" "phase:3" "phase:4" "phase:5")
for phase in "${phases[@]}"; do
  total=$(gh issue list --repo "$REPO_INFO" --label "$phase" --json number --jq '. | length')
  closed=$(gh issue list --repo "$REPO_INFO" --label "$phase" --state closed --json number --jq '. | length')
  
  if [ "$total" -gt 0 ]; then
    percentage=$((closed * 100 / total))
    phase_name="${phase#phase:}"
    echo "- Phase $phase_name: $closed/$total ($percentage%)"
  fi
done

echo ""
echo "## 🔮 Coming Up Next"
echo ""
echo "Top 5 ready-to-work issues:"
echo ""

ready=$(gh issue list --repo "$REPO_INFO" --label "status:ready" --limit 5 --json number,title,url,labels)

if [ -n "$ready" ]; then
  echo "$ready" | jq -r '.[] | 
    (.labels[] | select(.name | startswith("priority:")) | .name) as $priority |
    {number: .number, title: .title, url: .url, priority: $priority} |
    "- [#\(.number)](\(.url)) \(.title) (\(.priority // "priority:low"))"' |
    sort -r
else
  echo "No issues are ready for development."
fi

echo ""
echo "Generated on $(date)"
