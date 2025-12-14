This is for the g3 app in `~/src/g3`.

*OVERVIEW*

I wish to add a planning mode in g3 that operates in the following manner:

1. Review new requirements (`new_requirements.md`), and suggest improvements to the user (if they want them).
2. Once approved by the user, rename the new requirements to `current_requirements.md`.
3. Implement the requirements. When done, rename it to `completed_requirements_<timestamp>.md` (see spec below)
4. goto 1.

The new workflow also includes git operations.

State machine:


+------------- RECOVERY (Resume) ---------------------+
|                                                     |
|  +---------- RECOVERY (Mark Complete) ----+         |
|  |                                        |         |
^  ^                                        v         v
STARTUP -> PROMPT FOR NEW REQUIREMENTS -> REFINE REQUIREMENTS -> IMPLEMENT REQUIREMENTS -> IMPLEMENTATION COMPLETE +
^                                                                                                         v
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+


*DETAILED DESCRIPTION*

Put as much of the new code for implementing this mode into to the g3-planner crate (i.e. crates/g3-planner/src/...).
Where you need to change the start-up logic (e.g. in controller.rs or g3-cli/src/lib.rs), do so of course, but keep changes to a minimum.
I want the bulk of planner code in the g3-planner crate.

Create a new planning mode as peer to autonomous mode. (see controller.rs or g3-cli/src/lib.rs: to start in that mode, use "--planning" commandline flag).


Change the toplevel config structure (.g3.toml)
-----------------------------------------------

There is a new config for planner, similar to coach and player.
Change how coach and player providers are specified, and also use the new pattern for planner.
Do keep the `default_provider`.

The different providers must be specified differently to what it was in the past. (The old style
config should no longer work, no migration is needed. If g3 encounters the old format, it should give an example for how
to use the new format. Also update the examples in the g3 folder and the README)

Implement the code to match the following logic:
Each mode must specify the full path of the provider config, and there can be different configs
for any given provider:
```toml
[providers]
default_provider = "anthropic.default"  # Format: "<provider_type>.<config_name>"
planner = "anthropic.planner"
coach = "anthropic.default"  
player = "openai.player"

# Named configs per provider type
[providers.anthropic.default]
api_key = "..."
model = "claude-sonnet-4-5"
max_tokens = 64000

[providers.anthropic.planner]
api_key = "..."
model = "claude-opus-4-5"
thinking_budget_tokens = 16000

[providers.openai.player]
api_key = "..."
model = "gpt-5"
```

If `planner` is not specified in [providers], fall back to `default_provider` when in planning mode. (Make SURE to
tell the user this)
If default_provider also doesn't resolve, exit with error showing example config.

Change the existing hardcoded locations of todo
-----------------------------------------------
Allow the planning mode to specify that the todo file written by the LLM is at `<codepath>/g3-plan/todo.g3.md`,
and not just the default todo location. Use that location whenever in planning mode.

Change the existing hardcoded locations of requirements
------------------------------------------------------

Allow the planning mode to specify that project requirements are at `<codepath>/g3-plan/current_requirements.md`,
instead of the default `requirements.md` location in the workspace. Always use the requirements path for planning
mode.

Adding git functionality
------------------------

Add a commandline arg '--no-git' to g3. It's only useful in planning mode. If no-git is specified, all git
functionality described in these requirements must be disabled.

When starting the application, ensure there is a git repo that `<codepath>` sits under. If not, notify user that
they should create one, and quit.

When starting the application, print the current git branch name, and confirm with the user whether it's the correct
branch to start work on. If they say 'No' or quit (or CTRL-C), simply exit the app.

When starting the application, check that there are no untracked, uncommitted or dirty files on the current git branch
(ignore `<codepath>/g3-plan/new_requirements.md`)
of the repo that `<codepath>` sits in. If there are, notify the user and ask whether
to proceed (e.g. if this is a recovery, there WILL be uncommitted files etc..).
If they quit, simply exit the application. Otherwise proceed.

Generating summaries
--------------------

Use the planner agent LLM to generate summaries
- The requirements summary for planner_history.txt
- The git commit summary and description

Provide the current_requirements.md content as context for generation.

(The prompts to be sent to the LLM in this specification are the authoritative text.
Implement them as constants in `prompts.rs`. The implementation
should use these constants, not inline strings.
Put ALL prompts that will be sent to the LLM into `~/src/g3/crates/g3-planner/src/prompts.rs`. DO NOT inline them
with all the rest of the code).


Startup
-------

When starting up, enter planning mode.
Try to determine which codebase needs to be worked in:
If there's a commandline `--codepath=<path>` parameter, use that and print it to the UI, otherwise
prompt the user for the codepath.

(make sure the codepath argument resolves, also make sure that '~' will expand to user's home dir)

The argument `--planning` is mutually exclusive with `--autonomous`, `--auto` and `--chat`, throw an error if more
than one is present. (`--task` is ignored in planning mode).

On startup in planning mode:

If not present, create a top-level directory called: `<codepath>/g3-plan`, and a blank file `<codepath>/g3-plan/planner_history.txt`.

check for these files:
`<codepath>/g3-plan/current_requirements.md`
`<codepath>/g3-plan/todo.g3.md`

If there is a todo file and/or current_requirements, something went wrong in the last g3 implementation loop.
Prompt the user saying there is a `<codepath>/g3_plan/current_requirements.md` file from <SHOW DATE AND TIME OF THE FILE>,
and/or `<codepath>/g3_plan/todo.g3.md`. Print the todo file if present.
"""The last run didn't complete successfully. Found:
- current_requirements.md from <DATE AND TIME>
- todo.g3.md <IF PRESENT, SHOW CONTENTS>

Would you like to resume the previous implementation?
[Y] Yes - Attempt to resume
[N] No - Mark as complete and proceed to review new_requirements.md
[Q] Quit - Exit and investigate manually
"""
If attempting a recovery, go to "implementation recovery" in the "Implement current requirements" step below.
(update the planner_history.txt by saying "2025-12-08 14:31:00 ATTEMPTING RECOVERY")

If "[N] No - Mark as complete" chosen, go to "Implementation recovery skipped" step.

Refine requirements
-------------------

Delete `<codepath>/g3-plan/todo.g3.md` because we're starting with fresh requirements.

Enter into an interactive prompt (similar to accumulation mode).

Prompts:
"""I will help you refine the current requirements of your project.
Please write or edit your requirements in `<codepath>/g3-plan/new_requirements.md`.
Hit enter for me to start a review of that file."""

If `new_requirements.md` does not exist when user hits Enter:
- Display error: "File not found: <path>/g3-plan/new_requirements.md"
- Prompt user to create the file and try again
- Do NOT create an empty file automatically


There is a tag called ORIGINAL_REQUIREMENTS, it literally should read: "{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}"

If the file does not contain the tags ORIGINAL_REQUIREMENTS or `{{CURRENT REQUIREMENTS}}`,
PREPEND ORIGINAL_REQUIREMENTS to `<codepath>/g3-plan/new_requirements.md`.


For g3 add a config for "planner", pattern it on 'coach' and 'player' i.e. Have a top-level config in `providers` called
`planner`,
Use the provider spec for planner to create a new agent instance.
Add a system prompt (the prompt literal (ONLY) MUST be stored in  `~/src/g3/crates/g3-planner/src/prompts.rs`)

"""
You're an experienced software engineering architect. Please help me to ideate and refine
REQUIREMENTS for an implementation (or changes to the existing implementation), at <codepath>.
The requirements will later be used by an LLM.
I wish to have a compact specification, and DO NOT ATTEMPT TO IMPLEMENT OR BUILD ANYTHING.
At this point ONLY suggest improvements to the requirements. Do not implement anything.
DO NOT DO A RE-WRITE, UNLESS THE USER EXPLICITLY ASKS FOR THAT.
If you think the requirements are totally incoherent and unusable, write constructive feedback on
why that is, and suggest (very briefly) that you could rewrite it if explicitly asked to do so.
If the requirements are usable, make some edits/changes/additions as you deem necessary, and
PREPEND them under the heading `{{CURRENT REQUIREMENTS}}` to `<codepath>/g3-plan/new_requirements.md`.
"""

Send this to the LLM, allow it to use tools, use the existing functionality in g3-core or g3-cli to parse
and execute the task.

The planner agent should have access to:
- read_file
- write_file
- shell
- code_search
- str_replace
- final_output


The planner should NOT have access to:
- todo_write

Once the task is done, check that there is a `{{CURRENT REQUIREMENTS}}` heading in `<codepath>/g3-plan/new_requirements.md` file. If not,
log an error saying the llm didn't respond, tell the user that they need to restart the app and quit.

Tell the user that the LLM has updated `<codepath>/g3-plan/new_requirements.md`. Ask them to go and read that file, and if it's acceptable,
to say 'yes', if so, go to "Implement current requirements" step. If not, go to "Refine requirements" step.



planner_history.txt purpose
---------------------------

The file `<codepath>/g3-plan/planner_history.txt` is a summary of planning steps and acts as the comprehensive reference
of historic requirements and implementations undertaken in the code at `<codepath>` and in that git repo.

This file serves as an audit log, also to provide strict ordering information. It is also
the file that will require merging/resolution if updated on separate git branches.

At the start of each step update the planner_history file. See the format below.
Before starting the implementation, write the SHA of the current git HEAD.
At the beginning of the implementation
step, generate a short summary of the requirements. Take care that the most important elements
of the requirements are reflected. Do not go into deep detail. Make the summary at most 5 lines long.
Each line should be at most 120 characters long.

In the completion step ("Implementation is complete"), a git commit is made. Show the commit message (unfortunately
we don't have the SHA since deriving it is a circular reference)

GIT HEAD entries should be written:
- At start of implementation (records starting point for potential rollback)


Format:
"""
2025-12-08 14:31:00 - REFINING REQUIREMENTS (new_requirements.md)
2025-12-08 17:24:05 - GIT HEAD (<SHA>)
2025-12-08 17:25:31 - START IMPLEMENTING (current_requirements.md)
                      <<
                      This is an example of a short summary of what's in the requirements.
                      Keep it indented like this. Generate only a short summary, taking care that the most important elements
                      of the requirements are reflected. Do not go into deep detail. Make the summary at most 5 lines long.
                      Each line should be at most 120 characters long.
                      >>
2025-12-08 18:20:00   ATTEMPTING RECOVERY
2025-12-08 18:30:00 - COMPLETED REQUIREMENTS (completed_requirements_2025-12-08_18-30-00.md,  completed_todo_2025-12-08_18-30-00.md)
2025-12-08 18:30:00 - GIT COMMIT (<MESSAGE>)
2025-12-08 20:33:14 - REFINING REQUIREMENTS (new_requirements.md)
2025-12-09 17:25:05 - GIT HEAD (<SHA>)
2025-12-09 17:25:31 - START IMPLEMENTING (current_requirements.md)
                      <<
                      Lorem ipsum
                      >>
2025-12-09 17:20:12 - COMPLETED REQUIREMENTS (completed_requirements_2025-12-09_12-20-12.md,  completed_todo_2025-12-09_12-20-12.md)
2025-12-09 17:20:30 - GIT COMMIT (<MESSAGE>)
......
"""

Implementation recovery skipped
-------------------------------

Append to planner_history.txt:
"2025-12-08 14:31:00  USER SKIPPED RECOVERY"

go to "Implementation is complete" step.

Implement current requirements
------------------------------

Rename `<codepath>/g3-plan/new_requirements.md` to `<codepath>/g3-plan/current_requirements.md`

("recovery point" -- do not rename new_requirements file in step above, instead use whatever `<codepath>/g3-plan/current_requirements.md` is there..)

Update `planner_history.txt` with a summary of requirements etc.. see format above.

Proceed to the coach/player loop, making sure it uses `<codepath>/g3-plan/current_requirements.md`.

Wait for the coach/player loop to complete.


Implementation is complete
---------------------------

When the coach/player loop has completed (or in recovery mode), make sure the todos are done (check the todo file). If not, prompt the user, and ask whether they consider
the todos and the requirements completed. If the user thinks it's not completed, go back to the coach/player loop.
If they agree, then rename `<codepath>/g3-plan/current_requirements.md` to `completed_requirements_<DATE AND TIME>.md` (see example below).
also rename the todo file to `completed_todo_<DATE AND TIME>.md`.

Stage all changed/new files in `<codepath>/g3-plan` directory.

Stage all new & modified code, configuration and other files in the git repo. Make a special note of file that appear to be
temporary artifacts produced by code execution, or during testing, log files and other temporary detritus, and do not
stage them.

(for example Do NOT stage:
- target/, node_modules/, __pycache__/, .venv/
- *.log, *.tmp, *.bak
- .DS_Store, Thumbs.db
- .pyc
- Files in tmp/ or temp/ directories
- **/__pycache__/
  and any similar files, use your discretion)

Using the planning agent LLM, generate a short summary line for a git commit and well as a description for the
commit (at most 10 lines). Use
the current_requirements and describe the implementation. Take care that only the most important and salient
details are included in the description. ALSO include in the description what the `completed_requirements_<DATE AND TIME>.md`
and `completed_todo_<DATE AND TIME>.md` filenames are.

Print to the UI that g3 is ready to make a git commit. Print the summary and description generated for the git commit.

Tell the user to review the currently staged files, and prompt them to hit continue when they're done. (They may choose
to quit, in which case do nothing (i.e. no git commit, no updates to the planner_history file, and just quit)

Make the git commit with the summary and description generated above.

Go back to "Refine requirements" step.


Exiting Planning Mode
---------------------
User can exit at these points:
- During codepath prompt: Ctrl+C or type "quit"
- During refinement loop: type Ctrl+C "quit" instead of "yes"/"no"
- During implementation: Ctrl+C (state preserved for resume)
- After implementation complete: type "quit" or Ctrl+C when prompted for new requirements

When user quits, do NOT rename incomplete files. Leave state for potential resume.

Git Commit Format
-----------------
Summary line: Max 72 characters, imperative mood (e.g., "Add planning mode with...")
Description: Max 10 lines, each max 72 characters, wrapped properly

Example:
Add user authentication with OAuth2 support

Implements OAuth2 flow for Google and GitHub providers.
Includes token refresh logic and secure storage.

Requirements: completed_requirements_2025-12-08_17-25-31.md
Todo: completed_todo_2025-12-08_17-25-31.md

Timestamp Formats
-----------------
- For filenames: `YYYY-MM-DD_HH-MM-SS` (all hyphens, filesystem-safe)
  Example: completed_requirements_2025-12-08_17-25-31.md

- For planner_history.txt: `YYYY-MM-DD HH:MM:SS` (ISO 8601 for readability)
  Example: 2025-12-08 18:30:00 - COMPLETED REQUIREMENTS

*EXAMPLE FILES*

Example files in `<codepath>/g3-plan`:
`planner_history.txt`
`new_requirements.md` or `current_requirements.md`
`todo.g3.md`
`completed_todo_2025-12-08_17-25-31.md`
`completed_requirements_2025-12-08_17-25-31.md`
`completed_requirements_2025-12-08_17-20-12.md`
