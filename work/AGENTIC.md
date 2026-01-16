# Agentic Work Management (Simple Agile)

This doc proposes a lightweight work management approach (epics → stories → tasks) optimized for collaborating with agentic coding assistants and human developers.

It is intentionally small-team and non-enterprise: plain Markdown files, a small set of statuses, and simple rules that keep long-term intent and short-term execution aligned.

This approach keeps agent state in-repo while keeping planning lightweight.

## Goals

- Keep `ANCHOR.md` as the source of truth for product intent and UX.
- Maintain a long-term backlog (epics/stories) without losing day-to-day clarity (tasks).
- Make work items “promptable”: agents should be able to start from one file, execute, validate, and update status without hunting for context.
- Reduce coordination overhead: prefer flow (Kanban-style pull) over ceremony.

## What we already have (in this repo)

- Backlog index: `WORK.md`
- Work artifacts: `work/epics/`, `work/stories/`, `work/tasks/`
- Templates: `work/epics/epic-template.md`, `work/stories/story-template.md`, `work/tasks/task-template.md`
- Conventions: `work/AGILE.md`
- Long-lived rules: `DIRECTIVES.md`
- Agent workflow: `AGENTS.md`

This proposal builds on those, and adds agent-specific best practices.

## Core model

### Epics (outcome + boundaries)

Epics describe outcomes, scope boundaries, and a rough “appetite” (time/effort budget). They should point back to relevant sections of `ANCHOR.md`.

Recommended additions to epic files (optional fields):
- Appetite: e.g. “1–2 weeks” or “3 sessions”
- Non-goals / out of scope
- Key risks / unknowns (explicitly mark as “spike needed” when appropriate)

### Stories (user value + acceptance criteria)

Stories should be written so a human can validate the experience, and so an agent can translate them into tasks with test/validation steps.

Recommended story writing rules:
- Prefer specific acceptance criteria over implementation details.
- If the story implies validation, write it down: endpoints, UI flows, commands to run, expected outputs.

### Tasks (single deliverable + validation)

Tasks are the unit of execution. To be “agent-ready”, each task should be:
- Small: one primary outcome, preferably completable in one sitting.
- Concrete: clear starting point(s) and a specific “Definition of Done”.
- Verifiable: explicit validation commands or reproduction steps.
- Safe: any expected escalation needs are called out up front (network, docker socket, host access).

Recommended additions to task files (optional fields):
- Preconditions (what must already exist / be true)
- Validation (commands + expected results)
- Escalation needs (if applicable)
- Notes / outcome summary (appended when completed)

## Status + flow (keep it simple)

Use the existing status set: `proposed`, `ready`, `in-progress`, `blocked`, `done`, `parked`.

Flow rules (Kanban-inspired):
- Pull work: only start `in-progress` tasks that are `ready`.
- Limit WIP: aim for 1 `in-progress` task per area (e.g., api/web/infra) at a time.
- If a task is `blocked`, write the unblock condition directly in the task file (one bullet).

## Agent + human collaboration protocol

### When starting a task (agent)

- Read: the task file, linked story, linked epic, then scan `ANCHOR.md` and `DIRECTIVES.md` for relevant constraints.
- Propose a short plan (steps + validation) and explicitly call out escalation needs before running commands.
- If acceptance criteria are ambiguous, stop and ask for clarification (or propose a minimal default).

### While executing (agent)

- Keep changes scoped to the task’s Definition of Done.
- Prefer adding/using validation commands so the agent can self-check (tests, linters, health endpoints).
- Avoid parallel “threads” editing the same files at once; keep one active task per code area.

### When finishing (agent)

- Run the task’s validation steps.
- Update the task’s Status (and add a short “Outcome” note).
- If the work changes product intent/UX, update `ANCHOR.md` (or propose the update).
- If durable working rules changed, update `DIRECTIVES.md`.

### When creating work (human)

- Write epics/stories as outcomes and experiences (not implementation plans).
- Ensure each story has acceptance criteria that a human can verify.
- When asking an agent to do work, link the relevant task file(s) and include any extra constraints (timebox, risk tolerance, no-network, etc.).

## Optional (small) additions to make this easier

These are intentionally optional and can be adopted incrementally:

1) A short-term “Now/Next/Later” queue
- Add `work/BOARD.md` with three sections (Now/Next/Later) linking to tasks.
- This becomes the daily pull list, while `WORK.md` remains the long-term index.

2) Lightweight “run notes” (weekly or per-session)
- Add `work/runs/run-YYYY-MM-DD.md` with:
  - Goal for the run
  - Selected tasks
  - Decisions made (links to `ANCHOR.md`/`DIRECTIVES.md` updates)

3) Task validation standardization
- Add a short rubric for what “good validation” looks like per area (api/web/infra) and bake it into templates.

## References (sources used)

- AGENTS.md format and nesting guidance: https://agents.md/
- Scrum Guide (Definition of Done; goals): https://scrumguides.org/scrum-guide.html
- The Kanban Guide (visualize workflow; manage flow; WIP + flow metrics): https://kanbanguides.org/the-kanban-guide/
- Shape Up (appetite; fixed time/variable scope; shaping): https://basecamp.com/shapeup
