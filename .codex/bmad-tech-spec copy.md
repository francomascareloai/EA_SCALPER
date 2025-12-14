---
description: "BMAD Tech Spec - Create a context-aware technical specification."
---

# BMAD Tech Spec Workflow

This workflow guides you through creating a detailed technical specification for a feature or change.

## Step 1: Discovery
1.  **Gather Context**:
    *   Read existing documentation in `📋 DOCUMENTACAO_FINAL`.
    *   Analyze the codebase to understand existing patterns (use `list_dir` and `view_file_outline`).
    *   Identify the tech stack and conventions.
2.  **Define Scope**:
    *   Ask the user for the problem statement.
    *   Clarify what is IN scope and OUT of scope.
    *   Determine if this is a "Greenfield" (new) or "Brownfield" (existing) change.

## Step 2: Technical Approach
1.  **Propose Solution**:
    *   Draft a high-level solution overview.
    *   Identify necessary changes (files to create/modify).
    *   Select libraries/frameworks (stick to existing stack if possible).
2.  **Review with User**: Present the proposal and get feedback.

## Step 3: Write Specification
1.  **Create Spec File**: Create `docs/specs/tech-spec-[feature-name].md`.
2.  **Fill Sections**:
    *   **Problem Statement**: Why are we doing this?
    *   **Solution Overview**: How will it work?
    *   **Implementation Details**: Specific file changes, APIs, data structures.
    *   **Testing Strategy**: How will we verify it?
    *   **Rollback Plan**: What if it fails?

## Step 4: Implementation Plan
1.  **Create Task List**: Generate a checklist of steps to implement the spec.
2.  **Save**: Append the task list to the spec file or create a separate `implementation_plan.md`.
