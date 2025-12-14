# AGENTS.md Optimization Prompt

## Objective
Optimize the AGENTS.md file (currently 2,500+ lines) to reduce size, eliminate redundancy, and improve relevance while maintaining ALL critical functionality. The optimized version should be significantly more concise and token-efficient without losing any essential guidance for the agent system.

## Context
Current file: @AGENTS.md
Current size: 2,500+ lines
Current issues:
- Excessive verbosity and repetition
- Multiple examples that could be consolidated
- Redundant explanations across sections
- Overly detailed templates that could be compressed

## Requirements

### Pre-Optimization Safety
**CRITICAL**: Before making ANY changes:
1. Create backup: `AGENTS.md.backup` (copy of current version)
2. Validate backup exists and is readable
3. Note current line count and estimated token count for baseline metrics

This ensures rollback capability if optimization introduces any issues.

### Analysis Phase
1. **Read and analyze the current AGENTS.md structure**
   - Identify all major sections and their purposes
   - Map dependencies between sections
   - Detect redundancies and duplications
   - Identify critical vs. optional content

2. **Classify content by priority**
   - CRITICAL: Core agent identity, routing rules, Apex compliance, safety protocols
   - HIGH: Strategic intelligence, mandatory reflection, error recovery
   - MEDIUM: Templates, examples, patterns
   - LOW: Verbose explanations, redundant examples, optional guidelines

3. **Detect optimization opportunities**
   - Repeated concepts that can be referenced once
   - Long examples that can be shortened
   - Verbose XML that can be compressed
   - Sections that can be merged
   - Templates that can use more concise formats

### Optimization Strategy
Apply these techniques systematically:

1. **Structural Compression**
   - Merge related sections (e.g., multiple "intelligence" sections into one)
   - Use XML attributes instead of nested tags where possible
   - Convert long prose to bulleted lists
   - Replace lengthy examples with concise patterns

2. **Content Deduplication**
   - Identify and eliminate repeated concepts
   - Use references (e.g., "See X section") instead of repeating
   - Consolidate similar examples into one representative example
   - Remove redundant explanations

3. **Template Optimization**
   - Reduce template verbosity (keep structure, remove filler)
   - Use table formats instead of long CDATA sections
   - Compress checklists to essential items only
   - Remove example templates if pattern is clear

4. **Example Consolidation**
   - Keep 1-2 best examples per concept, remove others
   - Shorten example explanations
   - Remove obvious/trivial examples
   - Focus on complex edge cases only

5. **Prose Reduction**
   - Convert explanatory prose to concise directives
   - Remove motivational/philosophical content
   - Eliminate redundant warnings
   - Use imperative voice ("Do X" not "You should do X")

**Execution Order**: Apply techniques in the sequence listed above (Structural → Content → Template → Example → Prose). This macro-to-micro approach prevents optimization conflicts and ensures systematic improvement. After each phase, validate that all quality gates still pass before proceeding to the next phase.

### Quality Gates
The optimized version MUST preserve:
- ✅ All agent identities and roles
- ✅ All routing rules and decision hierarchies
- ✅ All Apex Trading constraints and risk management rules
- ✅ All mandatory protocols (reflection, error recovery, etc.)
- ✅ All platform support details (Nautilus/MQL5)
- ✅ All critical safety mechanisms
- ✅ All essential templates and patterns
- ✅ Version number and changelog metadata

The optimized version SHOULD reduce:
- ❌ Repetitive examples (keep 1-2 best per concept)
- ❌ Verbose explanations (prefer concise directives)
- ❌ Redundant warnings (state once, reference elsewhere)
- ❌ Optional philosophical content
- ❌ Overly detailed templates (keep structure, remove filler)
- ❌ Long CDATA sections (compress or use tables)

### Target Metrics
- **Line count**: Reduce from 2,500+ to ~1,200-1,500 lines (40-50% reduction)
- **Token count**: Reduce by 40-50%
- **Readability**: Improve by increasing signal-to-noise ratio
- **Maintainability**: Improve by reducing duplication
- **Completeness**: 100% - no critical functionality lost

## Output Specification

### 1. Create Analysis Report
Save to: `.prompts/011-agents-md-optimization/agents-optimization-analysis.md`

Structure:
```xml
<optimization_analysis>
  <current_state>
    <line_count>{number}</line_count>
    <estimated_tokens>{number}</estimated_tokens>
    <major_sections>{list of section titles}</major_sections>
  </current_state>
  
  <findings>
    <redundancies>
      <item section="{name}" issue="{description}" savings="{estimated lines}"/>
      <!-- List all detected redundancies -->
    </redundancies>
    
    <optimization_opportunities>
      <opportunity type="{structural|content|template|example}" 
                    section="{name}" 
                    description="{what to optimize}" 
                    impact="{high|medium|low}"/>
      <!-- List all opportunities -->
    </optimization_opportunities>
    
    <critical_content>
      <section name="{name}" reason="{why must preserve}"/>
      <!-- List all content that must be preserved exactly -->
    </critical_content>
  </findings>
  
  <optimization_plan>
    <phase number="1" focus="Structural compression">
      <action>{description}</action>
      <!-- List actions -->
    </phase>
    <phase number="2" focus="Content deduplication">
      <action>{description}</action>
    </phase>
    <phase number="3" focus="Template optimization">
      <action>{description}</action>
    </phase>
  </optimization_plan>
  
  <projected_outcome>
    <target_line_count>{number}</target_line_count>
    <target_tokens>{number}</target_tokens>
    <reduction_percentage>{number}%</reduction_percentage>
    <risks>{any risks to functionality}</risks>
  </projected_outcome>
</optimization_analysis>
```

### 2. Create Optimized AGENTS.md
Save to: `.prompts/011-agents-md-optimization/AGENTS-optimized.md`

Requirements:
- Maintain the same XML structure and section organization
- Preserve ALL critical functionality listed in Quality Gates
- Update version to 3.5.0 in metadata
- Add changelog entry: "v3.5.0: Major optimization - reduced file size by ~50% while preserving all critical functionality"
- Include inline comments `<!-- OPTIMIZED: {what was changed} -->` in sections that were significantly modified

### 3. Create Comparison Report
Save to: `.prompts/011-agents-md-optimization/optimization-comparison.md`

Structure:
```markdown
# AGENTS.md Optimization Comparison

## Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Lines | {number} | {number} | {-X%} |
| Estimated Tokens | {number} | {number} | {-X%} |
| Major Sections | {number} | {number} | {=} |
| Examples | {number} | {number} | {-X} |
| Templates | {number} | {number} | {-X} |

## Changes by Section

### {Section Name}
- **Before**: {brief description, size}
- **After**: {brief description, size}
- **Optimizations applied**: {list}
- **Functionality preserved**: {yes/no/modified}
- **Lines saved**: {number}

{Repeat for each major section}

## Quality Assurance

### Preserved ✅
- {list all critical functionality that was preserved}

### Removed ❌
- {list what was removed and why it's safe}

### Modified ⚠️
- {list what was modified and how it still fulfills original purpose}

## Validation Checklist

- [ ] All agent identities preserved
- [ ] All routing rules intact
- [ ] All Apex constraints documented
- [ ] All mandatory protocols present
- [ ] Platform support complete
- [ ] Error recovery mechanisms functional
- [ ] Version updated correctly
- [ ] Changelog accurate

## Risks & Mitigation

### Identified Risks
1. {Risk description}
   - Mitigation: {how addressed}

### Testing Recommendations
1. {Test to verify functionality preserved}
2. {Test to verify routing still works}
3. {Test to verify protocols still trigger}
```

### 4. Create SUMMARY.md
Save to: `.prompts/011-agents-md-optimization/SUMMARY.md`

Structure (follow meta-prompts template):
```markdown
# AGENTS.md Optimization Summary

**Reduced AGENTS.md from 2,500+ to ~1,500 lines (40-50% reduction) while preserving all critical functionality**

## Version
v1 - Initial optimization

## Key Findings
• {Most significant optimization opportunity}
• {Second most significant}
• {Third most significant}
• Projected token savings: {X%}
• All critical functionality preserved (validated)

## Files Created
- `agents-optimization-analysis.md` - Detailed analysis and plan
- `AGENTS-optimized.md` - Optimized version (v3.5.0)
- `optimization-comparison.md` - Before/after comparison
- `SUMMARY.md` - This file

## Decisions Needed
• Review optimized version for approval
• Decide on backup strategy for current version
• Approve replacement of current AGENTS.md

## Blockers
None

## Next Step
Review `AGENTS-optimized.md` and if approved, replace current `AGENTS.md` with optimized version
```

## Success Criteria
- ✅ Analysis report created with detailed findings
- ✅ Optimized AGENTS.md created (v3.5.0)
- ✅ Line count reduced by 40-50%
- ✅ Token count reduced by 40-50%
- ✅ All critical functionality preserved (per quality gates)
- ✅ Comparison report shows exactly what changed
- ✅ SUMMARY.md provides clear next steps
- ✅ Validation checklist all items pass
- ✅ No breaking changes to agent behavior
- ✅ Improved readability and maintainability

## Execution Notes
- Use sequential-thinking for complex optimization decisions
- Verify each optimization preserves functionality before applying
- Test critical sections against quality gates continuously
- Document all significant changes in inline comments
- Prioritize safety and correctness over maximum compression
