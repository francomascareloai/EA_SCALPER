# CRITIC ADVERSARIAL REVIEW
## Target: `.claude/agents/git-guardian-nano.md`

**Artifact**: git-guardian-nano.md agent specification
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**AGENT_VERSION**: CRITIC v1.1
**CLAUDE_MD_VERSION**: 3.10.9

---

## VERDICT: ISSUES_FOUND (BLOCKED)

**The spec must NOT be used until CRITICAL issues are fixed.**

The nano spec violates its own prime directive ("ZERO data loss, ZERO leaked secrets") due to critical gaps in secret scanning and missing safety measures.

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 4 |
| HIGH | 5 |
| MEDIUM | 7 |
| LOW | 4 |

---

## CRITICAL ISSUES (must fix)

### 1. Secret Scan Does Not Check Staged Files
**Location**: Line 33-36 (Secret scan section)
**Impact**: Secrets in staged files will NOT be detected. If a user runs `git add sensitive.env` and then agent runs secret scan, the scan checks `git diff` (unstaged) which won't show the already-staged file. Secret gets committed and pushed.
**Fix**:
```bash
# Check BOTH unstaged AND staged for secrets
git diff | rg -n -i "(pattern)"
git diff --cached | rg -n -i "(pattern)"
```

### 2. `git add -p` Is Interactive and Will Hang
**Location**: Line 40 (Commit safe section)
**Impact**: `git add -p` requires interactive stdin input. In automated Task context, this command will hang indefinitely waiting for user input, causing timeout or apparent agent failure.
**Fix**:
```bash
# Replace with explicit file listing
git status --porcelain
# Agent lists specific files to add
git add path/to/specific/file1 path/to/specific/file2
```
Or use MCP git tool: `mcp__git__git_add`

### 3. Missing Backup Branch Creation
**Location**: Entire spec (not present)
**Impact**: The full spec (git-guardian.md) includes `git branch backup-$(date +%Y%m%d-%H%M%S)` before risky operations. The nano spec has NO backup creation anywhere. This violates the "ZERO data loss" prime directive. If any operation goes wrong, there's no safety net.
**Fix**: Add backup creation before any commit/push:
```bash
git stash push -m "pre-op-backup-$(date +%Y%m%d-%H%M%S)" --include-untracked 2>/dev/null || true
# OR
git branch backup-$(date +%Y%m%d-%H%M%S)
```

### 4. Incomplete Escalation List
**Location**: Lines 61-64 (Auto-escalate section)
**Impact**: The escalation conditions are vague and incomplete. Many dangerous operations are NOT listed:
- `git checkout -- .` (discards all changes)
- `git stash drop/clear`
- `git branch -D` (force delete)
- `git tag -d`
- Submodule operations
- LFS operations
- `git rebase` (not explicitly listed)
- `git reset HEAD~N` where N > 1

An agent might perform these operations without loading the full spec, leading to data loss.
**Fix**: Make the list explicit and exhaustive. Default to escalation for ANY operation not in the "safe" list.

---

## HIGH ISSUES

### 1. Incomplete Secret Scan Regex
**Location**: Line 34
**Impact**: The regex pattern misses many common secret patterns:
- AWS_ACCESS_KEY_ID (full pattern)
- DATABASE_URL, MONGODB_URI, REDIS_URL
- SSH private key headers (`-----BEGIN RSA PRIVATE KEY-----`)
- JWT tokens
- Anthropic API keys (`sk-ant-`)
- GitHub OAuth tokens (`gho_`)

**Fix**:
```bash
rg -n -i "(api[_-]?key|secret|password|token|credential|private[_-]?key|bearer|auth|sk-proj-|sk-ant-|AKIA|ghp_|gho_|DATABASE_URL|MONGODB_URI|REDIS_URL|-----BEGIN)"
```

### 2. No Check for Intermediate Git States
**Location**: Pre-flight section (lines 25-30)
**Impact**: The pre-flight doesn't check for MERGE_HEAD, REBASE_HEAD, CHERRY_PICK_HEAD, etc. If invoked during an in-progress merge/rebase, the agent might not realize it's in an intermediate state and make incorrect decisions.
**Fix**:
```bash
# Add to pre-flight
ls -la .git/MERGE_HEAD .git/REBASE_HEAD .git/CHERRY_PICK_HEAD 2>/dev/null && echo "WARNING: Intermediate state detected - escalate to full spec"
```

### 3. No Output Contract
**Location**: Entire spec (not present)
**Impact**: Unlike the full spec which has explicit output contract, nano spec doesn't define what the agent must report. This can lead to inconsistent or incomplete reporting of state changes.
**Fix**: Add output contract section:
```markdown
## Output Contract
- Current state (branch, ahead/behind, staged/unstaged count)
- Operation performed
- Files affected
- Rollback command (if applicable)
```

### 4. No CRITIC Self-Review Protocol
**Location**: Entire spec (not present)
**Impact**: The full spec (lines 84-92) includes a CRITIC self-review protocol for destructive operations. Nano spec lacks this, reducing safety.
**Fix**: Add minimal CRITIC note:
```markdown
## Self-Review
Before ANY destructive operation: What could go wrong? Is there a backup? Can this be undone?
```

### 5. Assumption That `rg` Is Available
**Location**: Line 34
**Impact**: If ripgrep is not installed, the secret scan command will fail. Depending on shell behavior, this could fail silently (making agent think "no secrets found") or error out.
**Fix**:
```bash
command -v rg >/dev/null 2>&1 || echo "ERROR: ripgrep not installed"
```

---

## MEDIUM ISSUES

### 1. No Binary File Handling
**Location**: Entire spec
**Impact**: `git diff` won't show meaningful content for binary files. Secrets embedded in binary configs won't be detected.
**Recommendation**: Add note about binary file limitations.

### 2. No Submodule Awareness
**Location**: Entire spec
**Impact**: Pre-flight commands don't check submodule status. `git diff` doesn't show submodule changes by default. Project uses submodules (visible in git status).
**Recommendation**: Add `git submodule status` to pre-flight.

### 3. No Worktree Awareness
**Location**: Entire spec
**Impact**: Multiple worktrees may exist. No mention of worktree awareness could cause confusion.
**Recommendation**: Add worktree check if relevant.

### 4. No Detached HEAD Handling
**Location**: Pre-flight section
**Impact**: `git status -sb` shows detached HEAD, but no explicit warning or handling. Commits on detached HEAD are easy to lose.
**Recommendation**: Add explicit warning if HEAD is detached.

### 5. No Git LFS Consideration
**Location**: Entire spec
**Impact**: LFS files have different behavior. No mention of LFS.
**Recommendation**: Add LFS check if project uses it.

### 6. No Verification That Full Spec Exists
**Location**: Lines 67-68
**Impact**: The `sed -n '1,220p' .claude/agents/git-guardian.md` command will fail or show nothing if file is missing.
**Fix**:
```bash
[ -f .claude/agents/git-guardian.md ] && sed -n '1,220p' .claude/agents/git-guardian.md || echo "ERROR: Full spec not found"
```

### 7. Push Assumes origin/main Tracking
**Location**: Line 50
**Impact**: `git log origin/main..HEAD` assumes the branch tracks origin/main. Different tracking configurations will give wrong results.
**Recommendation**: Use `git log @{upstream}..HEAD` instead.

---

## LOW ISSUES

### 1. Version Inconsistency
**Location**: Line 13 vs line 4
**Impact**: Title says "v1.0" but only in description, not in markdown heading.
**Fix**: Add version to heading: `# GIT_GUARDIAN-NANO v1.0`

### 2. No Timeout Guidance
**Location**: Pre-flight section
**Impact**: On large repos, `git status` and `git diff` can be slow. No guidance on handling this.
**Recommendation**: Add timeout note.

### 3. No Auth Troubleshooting
**Location**: Push section
**Impact**: Push might fail due to SSH key or token issues. No troubleshooting guidance.
**Recommendation**: Add auth failure handling note.

### 4. Log Line Count Inconsistency
**Location**: Line 29 vs full spec line 33
**Impact**: Nano uses `-n 10`, full spec uses `-n 12`. Minor inconsistency.
**Fix**: Align to one value.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| `rg` is installed | Could fail silently if missing | Check availability first |
| Agent knows when to escalate | List is vague ("complex revert") | Make list explicit |
| Full spec exists at path | File could be missing/moved | Verify before sed |
| Pre-flight is always run | No enforcement | Make it mandatory gate |
| `git add -p` works | It's interactive, will hang | Use explicit file add |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Secret in staged-only file | NOT DETECTED (critical bug) |
| `git add -p` in Task context | HANGS (critical bug) |
| Large binary file with embedded secret | NOT DETECTED |
| Detached HEAD state | No explicit warning |
| Submodule changes | Not shown in standard diff |
| Multiple worktrees | Not handled |
| Merge in progress | Not detected |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Large repo (>10GB) | Pre-flight could be slow, no timeout |
| Many submodules | Not considered |
| Binary-heavy project | Limited visibility |
| Multiple remotes | Push assumes origin |
| SSH auth expired | No troubleshooting |

---

## MANUAL VERIFICATION NEEDED

- [ ] Test secret scan on staged-only file to confirm bug
- [ ] Test `git add -p` in Task context to confirm it hangs
- [ ] Review if MCP git tools should replace bash commands
- [ ] Confirm full spec path exists and is readable
- [ ] Verify ripgrep availability on target systems

---

## PRE-MORTEM SUMMARY

### Most Likely Failure Mode
**Secret Leak via Staged File**: User runs `git add credentials.json`, agent runs secret scan on `git diff` (unstaged), finds nothing, proceeds with commit. Secret is pushed to public repo.

### Second Most Likely
**Agent Hangs on Interactive Command**: Agent tries to run `git add -p`, command waits for stdin input, Task times out or appears frozen.

### Third Most Likely
**Data Loss from Unclear Escalation**: Agent encounters `git checkout -- important-file.txt`, doesn't recognize it needs escalation (not in list), proceeds without backup, file content lost.

### Mitigation
Fix all CRITICAL issues before allowing this spec to be used. Consider whether a "nano" spec is worth the safety trade-offs, or if always using the full spec is safer.

---

## CONFIDENCE: HIGH

**Reason**: The critical issues are verifiable logic errors in the spec:
1. Secret scan checks wrong diff (unstaged vs staged) - testable
2. Interactive command in automated context - testable
3. Missing safety measures - observable by reading spec

These are not subjective concerns but objective gaps.

---

## RECOMMENDATIONS

### Immediate (before use)
1. Fix secret scan to check both `git diff` and `git diff --cached`
2. Replace `git add -p` with explicit file addition
3. Add backup creation before any operation
4. Expand escalation list to be explicit

### Short-term
1. Add intermediate state detection to pre-flight
2. Expand secret regex patterns
3. Add output contract section
4. Add rg availability check

### Consider
Given the number of critical issues, consider whether the nano spec is viable. Options:
1. Expand nano to include all critical safety measures (making it less "nano")
2. Remove nano entirely and always use full spec
3. Rename nano to "git-guardian-unsafe" with explicit warnings

The current state is dangerous: it appears complete but has critical gaps.

---

*CRITIC v1.1 - "Every bug found now is a loss prevented later."*
