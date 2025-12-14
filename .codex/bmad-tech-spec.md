---
description: BMAD Tech Spec - Create context-aware technical specification
argument-hint: <feature or change to specify>
---

# BMAD Tech Spec Workflow

Creating technical specification for: `$ARGUMENTS`

## Step 1: Discovery

**Gathering Context:**
1. Reading existing documentation in `📋 DOCUMENTACAO_FINAL`
2. Analyzing codebase patterns
3. Identifying tech stack and conventions

**Defining Scope:**
- **Problem Statement**: What problem are we solving?
- **In Scope**: What's included?
- **Out of Scope**: What's NOT included?
- **Type**: Greenfield (new) or Brownfield (existing)?

## Step 2: Technical Approach

**Proposing Solution:**
1. High-level overview
2. Files to create/modify
3. Libraries/frameworks (using existing stack)

**I'll present the proposal for your review.**

## Step 3: Specification Document

Creating `DOCS/specs/tech-spec-[feature].md` with:

```markdown
# Technical Specification: [Feature]

## Problem Statement
Why are we doing this?

## Solution Overview
How will it work?

## Implementation Details
- Files to modify
- APIs/interfaces
- Data structures

## Testing Strategy
How will we verify it?

## Rollback Plan
What if it fails?

## Dependencies
What does this need?

## Timeline Estimate
How long will it take?
```

## Step 4: Implementation Plan

**Generating:**
1. Task checklist
2. Order of operations
3. Verification steps

---

**Let's start discovery. Can you describe the problem you're trying to solve?**

Reference: `.agent/workflows/bmad-tech-spec.md`
