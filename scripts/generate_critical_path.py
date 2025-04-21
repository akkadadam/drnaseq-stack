#!/usr/bin/env python3
# generate_critical_path.py - Create Mermaid diagrams from GitHub issues

import os
import subprocess
import json
import re
import sys

def get_repo_info():
    """Get repository owner and name from git config or environment."""
    if os.path.exists('.env'):
        # Simple .env parser
        with open('.env', 'r') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    name, value = line.strip().split('=', 1)
                    os.environ[name] = value
    
    repo_owner = os.environ.get('REPO_OWNER')
    repo_name = os.environ.get('REPO_NAME')
    
    if not repo_owner or not repo_name:
        # Extract from git config
        try:
            origin_url = subprocess.check_output(
                ['git', 'config', '--get', 'remote.origin.url'],
                universal_newlines=True
            ).strip()
            
            # Handle different URL formats
            if 'github.com' in origin_url:
                if origin_url.startswith('https://'):
                    parts = origin_url.split('/')
                    repo_owner = parts[3]
                    repo_name = parts[4].replace('.git', '')
                elif origin_url.startswith('git@'):
                    parts = origin_url.split(':')[1].split('/')
                    repo_owner = parts[0]
                    repo_name = parts[1].replace('.git', '')
        except subprocess.CalledProcessError:
            print("Error: Could not determine repository information.")
            sys.exit(1)
    
    return repo_owner, repo_name

def get_critical_path_issues():
    """Fetch all issues with critical_path: true in their body."""
    repo_owner, repo_name = get_repo_info()
    
    # Get all open issues
    cmd = [
        'gh', 'issue', 'list',
        '--repo', f"{repo_owner}/{repo_name}",
        '--json', 'number,title,body,labels'
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Error fetching issues: {result.stderr}")
        sys.exit(1)
    
    issues = json.loads(result.stdout)
    
    # Filter for critical path issues
    critical_path_issues = []
    for issue in issues:
        if issue['body'] and 'critical_path: true' in issue['body'].lower():
            # Extract phase from labels
            phase = None
            for label in issue['labels']:
                if label['name'].startswith('phase:'):
                    phase = label['name'].replace('phase:', '')
                    break
            
            # Extract component from labels
            component = None
            for label in issue['labels']:
                if label['name'].startswith('component:'):
                    component = label['name'].replace('component:', '')
                    break
            
            # Extract dependencies from body
            dependencies = []
            blocks_pattern = r'Blocks:\s+#?(\d+)'
            blocked_by_pattern = r'Blocked by:\s+#?(\d+)'
            
            blocks_matches = re.findall(blocks_pattern, issue['body'])
            blocked_by_matches = re.findall(blocked_by_pattern, issue['body'])
            
            critical_path_issues.append({
                'number': issue['number'],
                'title': issue['title'],
                'phase': phase,
                'component': component,
                'blocks': blocks_matches,
                'blocked_by': blocked_by_matches
            })
    
    return critical_path_issues

def generate_mermaid_diagram(issues):
    """Generate a Mermaid diagram from critical path issues."""
    # Start building the diagram
    diagram = [
        "```mermaid",
        "graph TD",
        "    %% Critical Path Visualization"
    ]
    
    # Add nodes
    node_defs = []
    for issue in issues:
        safe_title = issue['title'].replace('"', "'")
        if len(safe_title) > 30:
            safe_title = safe_title[:27] + "..."
        
        node_id = f"I{issue['number']}"
        node_def = f"    {node_id}[#{issue['number']}: {safe_title}]"
        node_defs.append(node_def)
    
    diagram.extend(node_defs)
    diagram.append("")
    
    # Add connections
    connections = []
    for issue in issues:
        node_id = f"I{issue['number']}"
        
        # Add "blocks" connections
        for blocks in issue['blocks']:
            connections.append(f"    {node_id} --> I{blocks}")
        
        # Add "blocked by" connections
        for blocked_by in issue['blocked_by']:
            connections.append(f"    I{blocked_by} --> {node_id}")
    
    diagram.extend(connections)
    diagram.append("")
    
    # Add styling
    diagram.append("    %% Styling")
    diagram.append("    classDef phase2_5 fill:#9932CC,color:white;")
    diagram.append("    classDef phase3 fill:#4169E1,color:white;")
    diagram.append("    classDef phase4 fill:#3CB371,color:white;")
    diagram.append("    classDef phase5 fill:#FF8C00,color:white;")
    diagram.append("")
    
    # Apply classes based on phase
    phase_class_assignments = []
    for phase in ['2.5', '3', '4', '5']:
        phase_issues = [f"I{issue['number']}" for issue in issues if issue['phase'] == phase]
        if phase_issues:
            phase_class = f"phase{phase}".replace('.', '_')
            phase_class_assignments.append(f"    class {','.join(phase_issues)} {phase_class};")
    
    diagram.extend(phase_class_assignments)
    diagram.append("```")
    
    return "\n".join(diagram)

def generate_issue_links(issues):
    """Generate Markdown links to issues, organized by phase."""
    # Group issues by phase
    phases = {}
    for issue in issues:
        phase = issue['phase'] or 'unknown'
        if phase not in phases:
            phases[phase] = []
        phases[phase].append(issue)
    
    # Build the links section
    links = ["## Issue Links\n"]
    
    for phase in sorted(phases.keys()):
        if phase == '2.5':
            phase_name = "Phase 2.5: Reliability Layer"
        elif phase == '3':
            phase_name = "Phase 3: Reality Bridge"
        elif phase == '4':
            phase_name = "Phase 4: Orchestrator"
        elif phase == '5':
            phase_name = "Phase 5: Knowledge Scaleout"
        else:
            phase_name = f"Phase {phase}"
        
        links.append(f"### {phase_name}")
        
        for issue in phases[phase]:
            component = issue['component'] or 'general'
            links.append(f"- {component.capitalize()}: #{issue['number']} {issue['title']}")
        
        links.append("")
    
    return "\n".join(links)

def main():
    issues = get_critical_path_issues()
    
    if not issues:
        print("No critical path issues found.")
        return
    
    diagram = generate_mermaid_diagram(issues)
    links = generate_issue_links(issues)
    
    # Combine into a complete markdown document
    markdown = f"""# Critical Path Visualization

This document provides a visualization of dependencies between key components in the drnaseq-stack project.

## Dependency Graph

{diagram}

{links}

*This diagram was automatically generated on {subprocess.check_output(['date', '+%Y-%m-%d']).decode().strip()}*
"""
    
    # Print to stdout
    print(markdown)

if __name__ == "__main__":
    main()
