{{CURRENT REQUIREMENTS}}

These requirements refine planner history handling in `g3-planner`, focusing on ensuring
that `planner_history.txt` consistently records git commit entries **before** the actual
`git commit` is executed, and on understanding how this invariant was previously lost.

## 1. Guarantee `GIT COMMIT` History Entry Precedes the Commit

**Goal**: In planning mode, every successful git commit initiated by the planner must have a
corresponding `GIT COMMIT (<MESSAGE>)` line written to `<codepath>/g3-plan/planner_history.txt`
*before* the commit is attempted.

**Current behavior (as of this revision)**:
- `crates/g3-planner/src/planner.rs`, function `stage_and_commit()` already contains:
  - A call to `history::write_git_commit(&config.plan_dir(), summary)?;` immediately before
    calling `git::commit(&config.codepath, summary, description)?;`
- This matches the intended ordering, but a previous version had the history write *after* the
  commit. That bug was later “fixed” and then reintroduced once during refactors.

**Required behavior**:
1. Treat the ordering as a strict invariant for all planner-driven commits:
   - `planner_history.txt` must always be updated with a `GIT COMMIT (<MESSAGE>)` line
     **before** calling any function that performs the actual `git commit`.
2. If the commit fails (e.g. git returns error), the `GIT COMMIT` history entry must still
   remain in `planner_history.txt` to reflect the attempted commit.
3. The summary string written to history must match the actual commit summary used in
   `git::commit()`.

**Acceptance criteria**:
- Static inspection: in `stage_and_commit()` (and in any future helper functions that might wrap
  it), the call order is unambiguous and there is no path where `git::commit` can run without the
  preceding `write_git_commit` call.
- Behavioral: in a test/planning run, intentionally cause the commit to fail (e.g. by breaking
  git config) and verify that:
  - A new `GIT COMMIT (<MESSAGE>)` line appears in `planner_history.txt`.
  - No commit is created in git.

## 2. Identify How the Ordering Bug Was Previously Undone

**Goal**: Understand how the previously-correct ordering was lost so that future changes avoid
reintroducing the same bug.

**Investigation requirements**:
1. Use `git` history to find the commit that originally moved `history::write_git_commit` to *after*
   `git::commit` inside `stage_and_commit()`:
   - Search for changes to `crates/g3-planner/src/planner.rs`, function `stage_and_commit`.
   - Identify the commit SHA, author, and commit message where the order became incorrect.
2. Identify the later commit that restored the correct order (writing history before commit):
   - Record the SHA and message for the fix.
3. Summarize in **one short paragraph** (kept outside of the code, e.g. in a planning note or
   as a comment in `planner_history.txt` via a dedicated entry) **why** the ordering regressed.
   Possible root causes to look for:
   - Refactorings that moved staging/commit logic but did not preserve history semantics.
   - Changes that tried to “simplify” logging and accidentally rearranged calls.
   - Copy‑paste from an older version of `stage_and_commit`.

**Output expectations** (for the human operator, not the code):
- A concise explanation along the lines of:
  - “Commit `<SHA1>` refactored `stage_and_commit` and inadvertently moved
     `write_git_commit` after `git::commit`. Commit `<SHA2>` later corrected this by
     restoring the original order. The regression was caused by copying the older
     implementation from `<file/branch>` without re‑applying the earlier fix.”

## 3. Guardrails to Prevent Future Regression

**Goal**: Make it harder to accidentally reintroduce the wrong ordering of history vs. commit.

**Required changes**:
1. Add a short, explicit comment directly above the `write_git_commit` call in
   `stage_and_commit()` explaining the ordering requirement, for example:
   - `// IMPORTANT: Write GIT COMMIT entry to planner_history BEFORE actually running git commit.`
   - `// This is relied on for audit trail and for post‑mortem analysis when commits fail.`
2. Add a lightweight test around `stage_and_commit()` (or a thin wrapper) that asserts the
   intended behavior at a higher level, such as:
   - Using a fake or test double for `git::commit` and `history::write_git_commit` to ensure
     `write_git_commit` is invoked first.
   - This test should live in `crates/g3-planner/tests/` and not depend on a real git repo.
3. Document the invariant in planner‑mode requirements (this document) so that future
   requirement refinements and implementations continue to emphasize:
   - “Always write `GIT COMMIT (<MESSAGE>)` to planner_history.txt before performing the
      actual `git commit`.”

---

{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}


The bug you previously fixed has reappeared. Make SURE the "COMMIT" line to the planner_history
is added BEFORE you make the commit.

Check the history for the previous fix, and identify why the fix was undone?
