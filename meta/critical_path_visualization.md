# Critical Path Visualization

This document provides a visualization of dependencies between key components in the drnaseq-stack project.

## Dependency Graph

```mermaid
graph TD
    %% Critical Path Visualization
    I109[#109: Implementation Selector: Sc...]
    I108[#108: POD5 Integration: Plan Inpu...]
    I107[#107: Golden Dataset Library: Def...]
    I106[#106: BaseCallerInterface Abstrac...]
    I104[#104: Create implementation selec...]
    I103[#103: Implement POD5 integration ...]
    I102[#102: Create golden dataset manif...]
    I101[#101: Add BaseCallerInterface abs...]


    %% Styling
    classDef phase2_5 fill:#9932CC,color:white;
    classDef phase3 fill:#4169E1,color:white;
    classDef phase4 fill:#3CB371,color:white;
    classDef phase5 fill:#FF8C00,color:white;

    class I102,I101 phase2_5;
    class I109,I108,I107,I106,I104,I103 phase3;
```

## Issue Links

### Phase 2.5: Reliability Layer
- Validation: #102 Create golden dataset manifest and validation tools
- Orchestrator: #101 Add BaseCallerInterface abstraction

### Phase 3: Reality Bridge
- Orchestrator: #109 Implementation Selector: Script for Mock/Real/Version Switching
- Basecaller: #108 POD5 Integration: Plan Input Handling and Streaming
- Validation: #107 Golden Dataset Library: Define Manifest and Mock Input
- Basecaller: #106 BaseCallerInterface Abstraction
- Orchestrator: #104 Create implementation selector framework
- Basecaller: #103 Implement POD5 integration strategy


*This diagram was automatically generated on 2025-04-21*

