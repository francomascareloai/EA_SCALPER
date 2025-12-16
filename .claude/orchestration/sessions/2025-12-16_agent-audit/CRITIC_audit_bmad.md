# CRITIC Adversarial Audit: bmad-builder.md

**Auditor**: CRITIC (Adversarial Review)
**Target**: `.claude/agents/bmad-builder.md`
**Date**: 2025-12-16
**Status**: COMPLETE

---

## Executive Summary

The BMAD Builder agent spec is a meta-agent designed to create, edit, and audit BMAD workflows and agents. While the persona and menu-driven interface are well-defined, the spec has significant gaps around error handling, validation, security, and integration with the EA_SCALPER_XAUUSD project's trading context.

**Severity Counts**:
- CRITICAL: 2
- HIGH: 4
- MEDIUM: 5
- LOW: 3

---

## CRITIC Technique Analysis

### 1. INVERSION (What would make this fail?)

| Finding | Severity | Details |
|---------|----------|---------|
| Missing config.yaml path resolution | CRITICAL | Step 2 references `{project-root}/{bmad_folder}/bmb/config.yaml` but `{bmad_folder}` is never defined. The agent has no way to resolve this path. |
| No fallback for missing workflows | HIGH | Menu items reference workflows like `{project-root}/.bmad/bmb/workflows/create-agent/workflow.yaml`. If these don't exist, only "todo" check handles missing files - no graceful degradation. |
| Circular dependency risk | MEDIUM | The agent creates/edits workflows that may include agents that need this agent. No circular dependency detection. |

### 2. PRE-MORTEM (Assume it failed - why?)

| Finding | Severity | Details |
|---------|----------|---------|
| No output validation | HIGH | Step 5 of workflow handler says "Save outputs after completing EACH workflow step" but provides no validation that outputs are correct, complete, or don't overwrite existing files. |
| No rollback mechanism | HIGH | If a multi-step workflow fails mid-execution, there's no way to undo partial changes. Created files remain orphaned. |
| Session variable persistence | MEDIUM | "Store ALL fields as session variables" - unclear how these persist across tool calls. Claude's session state is not guaranteed across function calls. |

### 3. STRESS TEST (Edge cases and limits)

| Finding | Severity | Details |
|---------|----------|---------|
| No concurrency handling | MEDIUM | What if two users run BMAD Builder simultaneously editing the same workflow? No locking or conflict detection. |
| No size limits on generated content | LOW | Creating agents/workflows could generate arbitrarily large files. No constraints specified. |
| Menu scaling issues | LOW | Only 10 menu items currently. What happens with 50+ items? No pagination or search. |

### 4. EDGE CASES

| Finding | Severity | Details |
|---------|----------|---------|
| Malformed YAML handling | HIGH | The agent loads YAML configs and workflows but has no explicit error handling for malformed YAML. Will fail cryptically. |
| Empty or minimal configs | MEDIUM | What if config.yaml exists but is empty or missing required fields? No schema validation specified. |
| Non-English communication_language | LOW | While {communication_language} is referenced, there's no validation that workflows/templates exist in that language. |

### 5. ASSUMPTION AUDIT

| Assumption | Risk | Mitigation Needed |
|------------|------|-------------------|
| `{project-root}` is always resolvable | HIGH | Explicit definition or fallback to CWD |
| `.bmad/` folder structure exists | MEDIUM | Pre-flight check for required directories |
| `workflow.xml` is a valid workflow engine | MEDIUM | No spec for workflow.xml format or capabilities |
| User will pick valid menu numbers | LOW | Already handled with "Not recognized" message |

---

## Integration Gaps with EA_SCALPER_XAUUSD

| Finding | Severity | Details |
|---------|----------|---------|
| No trading-context awareness | CRITICAL | This agent can create/edit agents but has NO awareness of CLAUDE.md's trading constraints (Apex, DD limits, validation gates). A created agent could violate trading rules. |
| Missing CRITIC integration | MEDIUM | CLAUDE.md mandates CRITIC review for all artifacts. BMAD Builder doesn't invoke CRITIC after creating agents/workflows. |
| No model policy alignment | MEDIUM | CLAUDE.md specifies opus for trading-critical agents, haiku for simple tasks. BMAD Builder doesn't enforce these when creating new agent specs. |

---

## Specific Recommendations

### CRITICAL Fixes (Must Address)

1. **Define `{bmad_folder}` explicitly**
   ```xml
   <config>
     <bmad_folder>.bmad</bmad_folder>
     <config_path>{project-root}/{bmad_folder}/bmb/config.yaml</config_path>
   </config>
   ```

2. **Add trading-context validation for created agents**
   ```xml
   <validation>
     <check>If creating agent with intent="trading|risk|sizing|apex" → MUST include Apex constraints from CLAUDE.md</check>
     <check>If creating agent with model="opus" trigger → verify it's trading-critical per model_policy</check>
   </validation>
   ```

### HIGH Priority Fixes

3. **Add YAML error handling**
   ```xml
   <error-handling>
     <yaml-parse-error>Report line number, suggest fix, do NOT proceed with corrupted config</yaml-parse-error>
     <missing-file>List expected path, offer to create from template</missing-file>
   </error-handling>
   ```

4. **Add rollback mechanism**
   ```xml
   <workflow-safety>
     <backup>Before editing any file, create backup at {file}.bak.{timestamp}</backup>
     <rollback-cmd>*rollback - Restore from most recent backup</rollback-cmd>
   </workflow-safety>
   ```

5. **Add output validation**
   ```xml
   <output-validation>
     <check>Verify file was written successfully</check>
     <check>Validate generated YAML/XML syntax</check>
     <check>Confirm no overwrite of user-protected files</check>
   </output-validation>
   ```

6. **Integrate CRITIC review**
   ```xml
   <post-create-hook>
     After creating agent/workflow:
     1. Invoke CRITIC self-review (adversarial mindset)
     2. Check for trading/risk/Apex implications
     3. Report findings before marking complete
   </post-create-hook>
   ```

### MEDIUM Priority Fixes

7. **Add schema validation for config.yaml**
   ```yaml
   # Expected config.yaml schema
   required:
     - user_name: string
     - communication_language: string
     - output_folder: string
   optional:
     - theme: string
     - verbose: boolean
   ```

8. **Document workflow.xml dependency**
   - Add reference to where workflow.xml spec is documented
   - Define expected inputs/outputs for workflow engine

9. **Add directory pre-flight check**
   ```xml
   <startup-validation>
     <check-dir>{project-root}/.bmad/bmb/</check-dir>
     <check-dir>{project-root}/.bmad/bmb/workflows/</check-dir>
     <check-file>{project-root}/.bmad/bmb/core/tasks/workflow.xml</check-file>
     <on-missing>Report missing structure, offer to initialize</on-missing>
   </startup-validation>
   ```

### LOW Priority Fixes

10. **Add menu pagination for scaling**
11. **Add file size limits for generated content**
12. **Add language validation for templates**

---

## Missing Capabilities

1. **No version tracking** - Created agents don't get version numbers
2. **No dependency declaration** - No way to specify what an agent depends on
3. **No testing/dry-run mode** - Can't preview what will be created
4. **No undo stack** - Only single-level backup suggested, no multi-level undo
5. **No integration with project's validation_gate** - Created code isn't automatically tested

---

## Verdict

**NEEDS REVISION** before production use in EA_SCALPER_XAUUSD context.

The agent is well-structured for general BMAD workflow management but lacks critical safeguards for a trading system context. The two CRITICAL issues (undefined variables, no trading-context awareness) must be addressed to prevent the agent from creating non-compliant sub-agents that could violate Apex rules.

---

## Appendix: Full Audit Checklist

- [x] INVERSION applied
- [x] PRE-MORTEM applied
- [x] STRESS TEST applied
- [x] EDGE CASES analyzed
- [x] ASSUMPTION AUDIT completed
- [x] Integration with CLAUDE.md reviewed
- [x] Specific recommendations provided
- [x] Severity ratings assigned
- [x] Verdict delivered
