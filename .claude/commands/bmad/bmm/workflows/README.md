# BMM Workflows

## Available Workflows in bmm

**brainstorm-game**
- Path: `bmad/bmm/workflows/1-analysis/brainstorm-game/workflow.yaml`
- Facilitate game brainstorming sessions by orchestrating the CIS brainstorming workflow with game-specific context, guidance, and additional game design techniques.

**brainstorm-project**
- Path: `bmad/bmm/workflows/1-analysis/brainstorm-project/workflow.yaml`
- Facilitate project brainstorming sessions by orchestrating the CIS brainstorming workflow with project-specific context and guidance.

**document-project**
- Path: `bmad/bmm/workflows/1-analysis/document-project/workflow.yaml`
- Analyzes and documents brownfield projects by scanning codebase, architecture, and patterns to create comprehensive reference documentation for AI-assisted development

**game-brief**
- Path: `bmad/bmm/workflows/1-analysis/game-brief/workflow.yaml`
- Interactive game brief creation workflow that guides users through defining their game vision with multiple input sources and conversational collaboration

**product-brief**
- Path: `bmad/bmm/workflows/1-analysis/product-brief/workflow.yaml`
- Interactive product brief creation workflow that guides users through defining their product vision with multiple input sources and conversational collaboration

**research**
- Path: `bmad/bmm/workflows/1-analysis/research/workflow.yaml`
- Adaptive research workflow supporting multiple research types: market research, deep research prompt generation, technical/architecture evaluation, competitive intelligence, user research, and domain analysis

**workflow-status**
- Path: `bmad/bmm/workflows/1-analysis/workflow-status/workflow.yaml`
- Universal entry point for BMM workflows. Checks for existing workflow status, displays current state, suggests next actions, or helps plan new workflow. Can be invoked by any agent (bmad-master, analyst, pm) to understand where the project is and what to do next.

**gdd**
- Path: `bmad/bmm/workflows/2-plan-workflows/gdd/workflow.yaml`
- Game Design Document workflow for all game project levels - from small prototypes to full AAA games. Generates comprehensive GDD with game mechanics, systems, progression, and implementation guidance.

**narrative**
- Path: `bmad/bmm/workflows/2-plan-workflows/narrative/workflow.yaml`
- Narrative design workflow for story-driven games and applications. Creates comprehensive narrative documentation including story structure, character arcs, dialogue systems, and narrative implementation guidance.

**prd**
- Path: `bmad/bmm/workflows/2-plan-workflows/prd/workflow.yaml`
- Unified PRD workflow for project levels 2-4. Produces strategic PRD and tactical epic breakdown. Hands off to solution-architecture workflow for technical design. Note: Level 0-1 use tech-spec workflow.

**tech-spec-sm**
- Path: `bmad/bmm/workflows/2-plan-workflows/tech-spec/workflow.yaml`
- Technical specification workflow for Level 0 projects (single atomic changes). Creates focused tech spec for bug fixes, single endpoint additions, or small isolated changes. Tech-spec only - no PRD needed.

**ux-spec**
- Path: `bmad/bmm/workflows/2-plan-workflows/ux/workflow.yaml`
- UX/UI specification workflow for defining user experience and interface design. Creates comprehensive UX documentation including wireframes, user flows, component specifications, and design system guidelines.

**tech-spec**
- Path: `bmad/bmm/workflows/3-solutioning/tech-spec/workflow.yaml`
- Generate a comprehensive Technical Specification from PRD and Architecture with acceptance criteria and traceability mapping

**solution-architecture**
- Path: `bmad/bmm/workflows/3-solutioning/workflow.yaml`
- Scale-adaptive solution architecture generation with dynamic template sections. Replaces legacy HLA workflow with modern BMAD Core compliance.

**correct-course**
- Path: `bmad/bmm/workflows/4-implementation/correct-course/workflow.yaml`
- Navigate significant changes during sprint execution by analyzing impact, proposing solutions, and routing for implementation

**create-story**
- Path: `bmad/bmm/workflows/4-implementation/create-story/workflow.yaml`
- Create the next user story markdown from epics/PRD and architecture, using a standard template and saving to the stories folder

**dev-story**
- Path: `bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml`
- Execute a story by implementing tasks/subtasks, writing tests, validating, and updating the story file per acceptance criteria

**retrospective**
- Path: `bmad/bmm/workflows/4-implementation/retrospective/workflow.yaml`
- Run after epic completion to review overall success, extract lessons learned, and explore if new information emerged that might impact the next epic

**review-story**
- Path: `bmad/bmm/workflows/4-implementation/review-story/workflow.yaml`
- Perform a Senior Developer Review on a completed story flagged Ready for Review, leveraging story-context, epic tech-spec, repo docs, MCP servers for latest best-practices, and web search as fallback. Appends structured review notes to the story.

**story-approved**
- Path: `bmad/bmm/workflows/4-implementation/story-approved/workflow.yaml`
- Marks a story as done (DoD complete) and moves it from IN PROGRESS → DONE in the status file. Advances the story queue. Simple status-update workflow with no searching required.

**story-context**
- Path: `bmad/bmm/workflows/4-implementation/story-context/workflow.yaml`
- Assemble a dynamic Story Context XML by pulling latest documentation and existing code/library artifacts relevant to a drafted story

**story-ready**
- Path: `bmad/bmm/workflows/4-implementation/story-ready/workflow.yaml`
- Marks a drafted story as ready for development and moves it from TODO → IN PROGRESS in the status file. Simple status-update workflow with no searching required.

**testarch-atdd**
- Path: `bmad/bmm/workflows/testarch/atdd/workflow.yaml`
- Generate failing acceptance tests before implementation using TDD red-green-refactor cycle

**testarch-automate**
- Path: `bmad/bmm/workflows/testarch/automate/workflow.yaml`
- Expand test automation coverage after implementation or analyze existing codebase to generate comprehensive test suite

**testarch-ci**
- Path: `bmad/bmm/workflows/testarch/ci/workflow.yaml`
- Scaffold CI/CD quality pipeline with test execution, burn-in loops, and artifact collection

**testarch-framework**
- Path: `bmad/bmm/workflows/testarch/framework/workflow.yaml`
- Initialize production-ready test framework architecture (Playwright or Cypress) with fixtures, helpers, and configuration

**testarch-nfr**
- Path: `bmad/bmm/workflows/testarch/nfr-assess/workflow.yaml`
- Assess non-functional requirements (performance, security, reliability, maintainability) before release with evidence-based validation

**testarch-test-design**
- Path: `bmad/bmm/workflows/testarch/test-design/workflow.yaml`
- Plan risk mitigation and test coverage strategy before development with risk assessment and prioritization

**testarch-test-review**
- Path: `bmad/bmm/workflows/testarch/test-review/workflow.yaml`
- Review test quality using comprehensive knowledge base and best practices validation

**testarch-trace**
- Path: `bmad/bmm/workflows/testarch/trace/workflow.yaml`
- Generate requirements-to-tests traceability matrix, analyze coverage, and make quality gate decision (PASS/CONCERNS/FAIL/WAIVED)


## Execution

When running any workflow:
1. LOAD {project-root}/bmad/core/tasks/workflow.xml
2. Pass the workflow path as 'workflow-config' parameter
3. Follow workflow.xml instructions EXACTLY
4. Save outputs after EACH section

## Modes
- Normal: Full interaction
- #yolo: Skip optional steps
