{{CURRENT REQUIREMENTS}}

These requirements extend the existing planner history invariants for `g3-planner` and make
explicit what must be verified to ensure the `GIT COMMIT` entry is reliably written to
`planner_history.txt` **before** any git commit is attempted.

They assume the previous requirements in
`completed_requirements_2025-12-10_16-55-05.md` have already been implemented.

## 1. Re‑assert the History Ordering Invariant (No Behavioral Change Intended)

**Goal**: Treat the ordering of history writes vs. git commits as a non‑negotiable
invariant and make the expected behavior fully observable and testable.

1. The required behavior remains:
   - `history::write_git_commit(&plan_dir, summary)` (or equivalent) must always be
     called **before** any function that can perform a git commit (e.g.
     `git::commit(&codepath, summary, description)`).
   - If the commit later fails, the `GIT COMMIT (<MESSAGE>)` entry must still remain
     in `planner_history.txt`.
   - The `<MESSAGE>` written to history must exactly match the commit summary passed
     to `git::commit`.
2. Treat this as a **hard invariant** for planner‑mode commits and document it in
   code comments where the behavior is enforced.
3. No change in the user‑visible semantics is desired here; the purpose of these
   requirements is to make the invariant harder to accidentally violate and easier
   to verify.

## 2. Verify `append_entry` Is Not the Root Cause

The user speculates that flushing might be needed in the helper that appends to
`planner_history.txt`:

```rust
/// Append an entry to planner_history.txt
fn append_entry(plan_dir: &Path, entry: &str) -> Result<()> {
    let history_path = plan_dir.join("planner_history.txt");
    
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&history_path)
        .context("Failed to open planner_history.txt for appending")?;
    
    writeln!(file, "{}", entry)
        .context("Failed to write to planner_history.txt")?;
    
    Ok(())
}
```

**Requirements**:
1. Locate the actual implementation of `append_entry` (or equivalent) in
   `crates/g3-planner` and confirm it behaves as above (OpenOptions with
   `.append(true)` and a single `writeln!`).
2. Decide whether an explicit flush is necessary:
   - If the file handle is dropped immediately after `writeln!`, an additional
     `file.flush()` is **not** expected to change durability semantics for normal
     operation, but adding it is acceptable if it simplifies reasoning.
   - If the file handle is reused across multiple calls or buffered beyond the
     scope of `append_entry`, add an explicit `file.flush()` before returning and
     document why.
3. Record the conclusion in a short code comment **inside** `append_entry` to make
   clear that the function is not responsible for the observed ordering bug in
   planner history (which is about **call order**, not I/O buffering), unless you
   have strong evidence to the contrary.

## 3. Git History Analysis: Confirm the Regression Story

These requirements complement the earlier investigation requirements by
emphasizing a sanity check against the most recent regression.

1. Re‑use (do not duplicate) the existing investigation logic that finds:
   - The commit that moved `write_git_commit` after `git::commit`.
   - The later commit that restored the correct order.
2. For the current regression that prompted these requirements, confirm via `git
   log -p` on `crates/g3-planner/src/planner.rs`:
   - That `stage_and_commit()` (or any wrapper that performs commits) currently
     calls `write_git_commit` before `git::commit`.
   - That any temporary reordering that reintroduced the bug is now gone.
3. Update the existing external note / explanation (from the previous
   requirements) with a **one‑sentence addendum** that explicitly mentions this
   latest regression was again caused by call‑order changes, not by I/O buffering
   in `append_entry`.

## 4. Explicit End‑to‑End Verification Using a Throwaway Repo

**Goal**: The planner behavior must be verified end‑to‑end in an isolated test
repository so that both the human user and the coach can see evidence that the
history/commit ordering is correct.

1. Create a throwaway git repository at `/tmp/commit_test`:
   - Initialize a repo: `git init /tmp/commit_test`.
   - Create a minimal, valid Rust or placeholder project that allows running g3
     in planning mode against it.
2. Run g3 **in planning mode** with that repo as the codepath (and a workspace of
   your choice), using the recommended CLI flags from previous requirements.
3. Go through a minimal planning cycle that performs a **successful** commit from
   planner mode.
4. After the commit:
   - Inspect `/tmp/commit_test/g3-plan/planner_history.txt`.
   - Confirm that the **last history entry at the time of the commit** is a
     `GIT COMMIT (<MESSAGE>)` line, and that `<MESSAGE>` matches the actual git
     commit summary.
5. Save the exact shell commands used and the relevant excerpt of
   `planner_history.txt` (last ~10 lines) in a short note (e.g. a comment block
   in `planner_history.txt` or a separate markdown file under `g3-plan`) so that
   the coach can verify the test was truly executed.
6. These verification artifacts are for humans; the application itself does not
   need to parse or enforce them.

## 5. Strengthen Guardrails Against Future Regressions

These guardrails build on those already specified in
`completed_requirements_2025-12-10_16-55-05.md` and should be updated rather
than duplicated.

1. In the **same location** where you previously added the comment explaining the
   ordering requirement above `write_git_commit` in `stage_and_commit()`, extend
   the comment to explicitly reference:
   - That this ordering has regressed multiple times
   - That changes to staging/committing logic **must** keep `write_git_commit`
     before `git::commit`.
2. If not already done, ensure there is at least one test in
   `crates/g3-planner/tests/` that:
   - Uses a fake/simulated `git::commit` implementation.
   - Asserts that `write_git_commit` is invoked before the fake commit function.
   - Fails loudly if the order is reversed.
3. Make sure any new helper function that performs commits (e.g. a shared
   `commit_with_history()` function, if introduced) encapsulates the invariant:
   - Callers **must not** be allowed to call `git::commit` directly from planner
     mode without going through the history‑aware helper.

---

{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}

Despite the previous fix, the COMMIT. Make SURE the "COMMIT" line to the planner_history
is added BEFORE you make the commit.

Maybe there needs to be a flush in
```
/// Append an entry to planner_history.txt
fn append_entry(plan_dir: &Path, entry: &str) -> Result<()> {
    let history_path = plan_dir.join("planner_history.txt");
    
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&history_path)
        .context("Failed to open planner_history.txt for appending")?;
    
    writeln!(file, "{}", entry)
        .context("Failed to write to planner_history.txt")?;
    
    Ok(())
}
``` ?

Check the history for the previous fix, and identify what went wrong?

you MUST run an actual test of the application with a test repo in /tmp/commit_test. COACH: DO NOT APPROVE UNTIL THERE
IS CLEAR EVIDENCE THAT THE TEST WAS PERFORMED AND YOU CAN SEE THE LAST COMMIT OF THE planner history has a "COMMIT" as
the last entry.
