# CRITIC ADVERSARIAL AUDIT: git-guardian.md

**Artifact**: `.claude/agents/git-guardian.md`
**Type**: Sub-agent specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**Status**: COMPLETE

---

## VERDICT: ISSUES_FOUND

**Severity Summary**:
| Severity | Count |
|----------|-------|
| CRITICAL | 2 |
| HIGH | 4 |
| MEDIUM | 6 |
| LOW | 2 |

**Confidence**: HIGH - Gaps are clear and measurable.

---

## CRITICAL ISSUES (must fix)

### C1. SECRET SCAN REGEX IS INCOMPLETE

**Location**: Lines 37-39 (Secret scan section)

**Current Pattern**:
```bash
git diff | rg -n -i "(api[_-]?key|secret|password|token|credential|private[_-]?key|bearer|auth|sk-proj-|AKIA|ghp_)"
```

**Impact**: The regex misses many modern credential patterns:
- AWS: `A3T[A-Z0-9]{16}`, full secret key patterns
- GCP: `AIza[0-9A-Za-z_-]{35}` (API keys)
- Azure: GUID patterns for service principal secrets
- Slack: `xox[baprs]-[0-9a-zA-Z]{10,}`
- JWT: `eyJ[A-Za-z0-9_-]*\.eyJ`
- Connection strings: `postgres://`, `mongodb://`, `mysql://`
- Generic: `password\s*=`, `secret\s*=`
- SSH private keys: `-----BEGIN.*PRIVATE KEY-----`

**Fix**: Replace with comprehensive multi-pattern scan:
```bash
# Comprehensive secret patterns
PATTERNS='(api[_-]?key|secret|password|token|credential|private[_-]?key|bearer|auth|sk-proj-|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|gho_|ghu_|ghs_|AIza[0-9A-Za-z_-]{35}|xox[baprs]-|eyJ[A-Za-z0-9_-]+\.eyJ|-----BEGIN.*PRIVATE KEY|postgres://|mongodb://|mysql://)'
git diff | rg -n -i "$PATTERNS"
git diff --cached | rg -n -i "$PATTERNS"  # CRITICAL: Also scan staged!
```

---

### C2. STAGED FILES NOT SCANNED FOR SECRETS

**Location**: Lines 37-39 (Secret scan section)

**Current Behavior**: Only runs `git diff` which shows UNSTAGED changes.

**Problem**: If a developer runs `git add secret.env` first, then runs the secret scan, the scan sees nothing because the secret is now in the staging area, not in unstaged changes.

**Impact**: Direct security breach - secrets committed despite "passing" the scan.

**Fix**: Add staged file scan:
```bash
## Secret scan (before add/commit) - BOTH unstaged AND staged
# Scan unstaged changes
git diff | rg -n -i "$PATTERNS"
# Scan staged changes (CRITICAL)
git diff --cached | rg -n -i "$PATTERNS"
# Check for suspicious file additions
git status --porcelain | rg "^[AM].*\.(env|pem|key|p12|pfx|credentials)" && echo "WARNING: Sensitive file type detected"
```

---

## HIGH ISSUES (should fix)

### H1. NO ERROR HANDLING GUIDANCE

**Location**: Entire spec - missing section

**Problem**: Commands can fail for many reasons (network, permissions, corrupted repo, conflicts). No guidance on:
- How to interpret error messages
- What to do when commands fail
- Fallback procedures

**Impact**: Agent could get stuck or make incorrect decisions when commands fail.

**Fix**: Add section:
```markdown
## Error Recovery

Common errors and responses:
| Error | Cause | Action |
|-------|-------|--------|
| "fatal: not a git repository" | Wrong directory | Navigate to repo root |
| "error: failed to push" | Protected branch or conflicts | Check branch protection, pull first |
| "CONFLICT (content)" | Merge conflict | List conflicts, resolve one by one |
| "fatal: refusing to merge unrelated histories" | Different root commits | Use --allow-unrelated-histories carefully |
| "error: cannot lock ref" | Concurrent operation | Wait and retry |

If error is unclear: `git status`, `git log --oneline -5`, then escalate to user.
```

---

### H2. MISSING COMMON GIT OPERATIONS

**Location**: Entire spec - coverage gap

**Missing Operations**:
- `git cherry-pick` - common for hotfixes
- `git revert` - undo commits safely
- `git bisect` - find bugs
- `git worktree` - multiple working directories
- `git remote` - managing remotes
- `git submodule` - submodule operations

**Impact**: Agent unprepared for common workflows, may give incorrect guidance.

**Fix**: Add sections for each operation with safety protocols similar to existing merge/rebase section.

---

### H3. TOOL DEPENDENCY NOT VALIDATED

**Location**: Line 38 - `rg` command

**Problem**: Assumes ripgrep (`rg`) is installed. No fallback if unavailable.

**Impact**: Secret scan could fail silently or with confusing error.

**Fix**: Add dependency check:
```bash
## Prerequisites
- ripgrep (rg) must be installed for secret scanning
- Fallback: use grep -rE if rg unavailable

## Secret scan with fallback
if command -v rg &> /dev/null; then
  git diff | rg -n -i "$PATTERNS"
else
  git diff | grep -n -i -E "$PATTERNS"
fi
```

---

### H4. NOT USING SAFER MCP GIT TOOLS

**Location**: Entire spec - uses bash commands

**Problem**: The MCP git server (`mcp__git__*`) provides safer, structured operations. The spec exclusively uses bash commands which are more error-prone and less observable.

**Impact**: Less safety, harder to audit, more error-prone.

**Fix**: Add guidance:
```markdown
## Tool Preference

Prefer MCP git tools when available:
- `mcp__git__git_status` instead of `git status`
- `mcp__git__git_diff` instead of `git diff`
- `mcp__git__git_commit` instead of `git commit`

Use bash only for:
- Complex pipelines (e.g., secret scan with rg)
- Operations not available in MCP
```

---

## MEDIUM ISSUES (consider fixing)

### M1. Unclear Escalation Paths

**Problem**: No guidance on when to escalate to other agents or human.

**Fix**: Add escalation table similar to CRITIC spec.

---

### M2. No Submodule Handling

**Problem**: Submodules can have their own uncommitted changes, dirty state. Not mentioned.

**Fix**: Add submodule section with `git submodule status` and safety protocols.

---

### M3. Assumes origin/main Default

**Location**: Line 55 - `git log origin/main..HEAD`

**Problem**: Many repos use `master`, `develop`, or other defaults.

**Fix**: Use dynamic detection:
```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
git log origin/$DEFAULT_BRANCH..HEAD --oneline
```

---

### M4. No Collaborative Workflow Guidance

**Problem**: No mention of pull requests, code review, fork workflows.

**Fix**: Add section on PR-based workflows and how git-guardian supports them.

---

### M5. Version History Not Tracked

**Problem**: Header says v1.1 but no changelog. CRITIC spec references v1.0.

**Fix**: Add changelog section in spec header.

---

### M6. Relationship with git-guardian-nano Unclear

**Problem**: Both specs have overlapping triggers. Routing ambiguous.

**Fix**:
1. Clearly define which operations go to which agent
2. Add explicit note in each spec about the other
3. Ensure router distinguishes correctly

---

## LOW ISSUES (nice to have)

### L1. Date Format Assumption

**Location**: Line 67 - `date +%Y%m%d-%H%M%S`

**Problem**: Works on Linux/Mac but may differ on other systems.

**Impact**: Minimal - backup branch naming is cosmetic.

---

### L2. Large Repo Performance Not Addressed

**Problem**: No guidance for repos with 100K+ files where status/diff can be slow.

**Fix**: Add note about using `git status --short` and limiting diff scope.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| rg (ripgrep) is available | May not be installed | Add fallback to grep |
| git diff shows all secrets | Misses staged changes | Add git diff --cached |
| Regex catches all secrets | Pattern is incomplete | Expand pattern list |
| User can confirm operations | Confirmation mechanism unclear | Define how confirmation works |
| origin/main is default | Many use master/develop | Detect dynamically |
| Reflog has recovery info | Can be pruned for old ops | Document limitations |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Empty repo (no commits) | `git log` fails - NOT HANDLED |
| Detached HEAD state | Pre-flight shows it, but no special handling |
| Binary file with secret | Secret scan fails - NOT HANDLED |
| Staged but not committed secret | MISSED by current scan |
| Corrupt .git/index | No recovery guidance |
| 50+ merge conflicts | "Resolve one by one" insufficient |
| Pre-commit hook failure | No guidance provided |
| Multiple remotes | Assumes single origin |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Large repo (100K files) | Status/diff slow - no mitigation |
| Many conflicts | Inadequate guidance |
| Shallow clone | Some operations behave differently - not documented |
| LFS files | Not addressed at all |
| Protected branches | Push rejection not handled |

---

## MANUAL VERIFICATION NEEDED

- [ ] Test secret scan with actual credential patterns (use test strings)
- [ ] Verify ripgrep is installed in target environments
- [ ] Confirm MCP git tools availability and suitability
- [ ] Clarify relationship with git-guardian-nano in router
- [ ] Test edge cases: empty repo, corrupted index, detached HEAD
- [ ] Validate the regex patterns against common secret types

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**:
SECRET LEAK - The incomplete regex and missing staged file scan means a credential will slip through. Agent reports "no secrets found" but the secret was in `git diff --cached`, not `git diff`. Credential is committed and pushed. Security incident ensues.

**Second most likely**:
DATA LOSS ON RESET - User asks to "clean up" a messy repo. Agent runs `git reset --hard` then `git clean -fd`. But user had important untracked files that are now permanently deleted. Reflog doesn't help for untracked files.

**Third most likely**:
HISTORY REWRITE DISASTER - Agent does `push --force` to "fix" something, but timing is wrong and teammate's work is overwritten. No clear guidance on when force push is truly safe (e.g., only on personal branches never pushed before).

---

## RECOMMENDED IMPROVEMENTS (Priority Order)

### Immediate (Security Critical)
1. Fix secret scan to include `git diff --cached`
2. Expand secret regex patterns
3. Add .env and sensitive file type detection

### Soon (Operational Safety)
4. Add error handling section
5. Integrate MCP git tools as preferred option
6. Add missing common operations (cherry-pick, revert)
7. Validate tool dependencies (ripgrep)

### Later (Completeness)
8. Add submodule handling
9. Add collaborative workflow guidance
10. Document edge cases and stress scenarios
11. Clarify relationship with git-guardian-nano
12. Add version changelog

---

## FINAL ASSESSMENT

**git-guardian.md v1.1** has solid foundations (Prime Directives, pre-flight checks, CRITIC self-review protocol) but contains critical security gaps in secret scanning that could allow credentials to be committed. The spec is suitable for SIMPLE git workflows in small repos with single remote, but will fail in more complex scenarios or when actual secrets need to be reliably caught.

**Recommendation**: Do NOT use for security-critical operations until CRITICAL issues C1 and C2 are fixed.

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
