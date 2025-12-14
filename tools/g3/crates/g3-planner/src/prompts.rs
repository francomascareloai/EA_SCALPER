//! Prompts used for planning mode and discovery phase
//!
//! This module contains all LLM prompts used in the planner crate.
//! All prompts are defined as constants to ensure consistency and maintainability.

// =============================================================================
// DISCOVERY PHASE PROMPTS (existing)
// =============================================================================

/// System prompt for discovery mode - instructs the LLM to analyze codebase and generate exploration commands
pub const DISCOVERY_SYSTEM_PROMPT: &str = r#"You are an expert code analyst. Your task is to analyze a codebase structure and generate shell commands to explore it further.

You will receive:
1. User requirements describing what needs to be implemented
2. A codebase report showing the structure and key elements of the codebase

Your job is to:
1. Understand the requirements and identify what parts of the codebase are relevant
2. Generate shell commands to explore those parts in more detail

IMPORTANT: Do NOT attempt to implement anything. Only generate exploration commands."#;

/// Discovery prompt template - used when we have a codebase report.
/// The codebase report should be appended after this prompt.
pub const DISCOVERY_REQUIREMENTS_PROMPT: &str = r#"**CRITICAL**: DO ABSOLUTELY NOT ATTEMPT TO IMPLEMENT THESE REQUIREMENTS AT THIS POINT. ONLY USE THEM TO
UNDERSTAND WHICH PARTS OF THE CODE YOU MIGHT BE INTERESTED IN, AND WHAT SEARCH/GREP EXPRESSIONS YOU MIGHT WANT TO USE
TO GET A BETTER UNDERSTANDING OF THE CODEBASE.

Your task is to analyze the codebase overview provided below and generate shell commands to explore it further - in particular, those
you deem most relevant to the requirements given below.

Your output MUST include:
1. A summary report.  Use the heading {{SUMMARY BASED ON INITIAL INFO}}.
   - retain as much information of that as you consider relevant to the requirements, and for making an implementation plan.
   - Ideally that should not be more than 10000 tokens.
2. A list of shell commands to explore the code. Use the heading {{CODE EXPLORATION COMMANDS}}.
   - Try plan ahead for what you need for a deep dive into the code. Make sure the information is sparing.
   - Carefully consider which commands give you the most relevant information, pick the top 25 commands.
   - Use tools like `ls`, `rg` (ripgrep), `grep`, `sed`, `cat`, `head`, `tail` etc.
   - Focus on commands that will help understand the code STRUCTURE without dumping large sections of file.
   - e.g. for Rust you might try `rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rs' '^(pub )?(struct|enum|type|union)`
   - Mark the beginning and end of the commands with "```".

DO NOT ADD ANY COMMENTS OR OTHER EXPLANATION IN THE COMMANDS SECTION, JUST INCLUDE THE SHELL COMMANDS."#;

// =============================================================================
// PLANNING MODE PROMPTS
// =============================================================================

/// System prompt for requirements refinement phase
pub const REFINE_REQUIREMENTS_SYSTEM_PROMPT: &str = r#"You're an experienced software engineering architect. Please help me to ideate and refine
REQUIREMENTS for an implementation (or changes to the existing implementation), at the specified codepath.
The requirements will later be used by an LLM.

IMPORTANT: Before suggesting changes, you MUST:
1. Read and understand the existing codebase at the specified codepath using read_file, shell commands, and code_search
2. Read the `<codepath>/g3-plan/` directory to understand past requirements and implementation history
   - Pay particular attention to `planner_history.txt` which contains a chronological record of all planning activities
   - Review any `completed_requirements_*.md` files to understand what has been implemented before
3. Use this context to ensure your suggestions are consistent with the existing codebase architecture

I wish to have a compact specification, and DO NOT ATTEMPT TO IMPLEMENT OR BUILD ANYTHING.
At this point ONLY suggest improvements to the requirements. Do not implement anything.
DO NOT DO A RE-WRITE, UNLESS THE USER EXPLICITLY ASKS FOR THAT.
If you think the requirements are totally incoherent and unusable, write constructive feedback on
why that is, and suggest (very briefly) that you could rewrite it if explicitly asked to do so.
If the requirements are usable, make some edits/changes/additions as you deem necessary, and
PREPEND them under the heading `{{CURRENT REQUIREMENTS}}` to the `<codepath>/g3-plan/new_requirements.md` file.

The codepath will be provided in the user message."#;

/// System prompt for generating requirements summary for planner_history.txt
pub const GENERATE_REQUIREMENTS_SUMMARY_PROMPT: &str = r#"Generate a short summary of the following requirements.
Take care that the most important elements of the requirements are reflected.
Do not go into deep detail. Make the summary at most 5 lines long.
Each line should be at most 120 characters long.
Output ONLY the summary text, no headers or formatting.

Requirements:
{requirements}"#;

/// System prompt for generating git commit message
pub const GENERATE_COMMIT_MESSAGE_PROMPT: &str = r#"Generate a git commit message for the following implementation.

REQUIREMENTS THAT WERE IMPLEMENTED:
{requirements}

COMPLETED FILES:
- Requirements: {requirements_file}
- Todo: {todo_file}

Generate a commit message with:
1. A summary line (max 72 characters, imperative mood, e.g., "Add planning mode with...")
2. A blank line
3. A description (max 10 lines, each max 72 characters, wrapped properly)

The description should:
- Describe the implementation concisely
- Include only the most important and salient details
- Mention the completed_requirements and completed_todo filenames

Output format:
{{COMMIT_SUMMARY}}
<summary line here>
{{COMMIT_DESCRIPTION}}
<description here>"#;

// =============================================================================
// CONFIG ERROR MESSAGES
// =============================================================================

/// Error message for old config format
pub const OLD_CONFIG_FORMAT_ERROR: &str = r#"Your configuration file uses an old format that is no longer supported.

Please update your configuration to use the new provider format:

```toml
[providers]
default_provider = "anthropic.default"  # Format: "<provider_type>.<config_name>"
planner = "anthropic.planner"           # Optional: specific provider for planner
coach = "anthropic.default"             # Optional: specific provider for coach
player = "openai.player"                # Optional: specific provider for player

# Named configs per provider type
[providers.anthropic.default]
api_key = "your-api-key"
model = "claude-sonnet-4-5"
max_tokens = 64000

[providers.anthropic.planner]
api_key = "your-api-key"
model = "claude-opus-4-5"
thinking_budget_tokens = 16000

[providers.openai.player]
api_key = "your-api-key"
model = "gpt-5"
```

Each mode (planner, coach, player) can specify a full path like "<provider_type>.<config_name>".
If not specified, they fall back to `default_provider`."#;

