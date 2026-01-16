# Agile Artifacts

This repo uses lightweight agile artifacts stored in `work/` to coordinate planning and delivery.

For agent-specific collaboration conventions (how humans and coding assistants should shape/execute tasks), see `work/AGENTIC.md`.

## Artifact types
- Epics: group related stories and tasks.
- Stories: describe user value and experience; reference one or more tasks.
- Tasks: actionable units of work; reference one or more stories.

## Conventions
- Use plain Markdown and keep content concise.
- Link related artifacts with relative paths.
- Status options: proposed, ready, in-progress, blocked, done, parked.
- One artifact per file.

## Directory layout
- `work/epics/`
- `work/stories/`
- `work/tasks/`

## Naming
- `epic-<short-name>.md`
- `story-<short-name>.md`
- `task-<short-name>.md`

## Workflow
- Define epics, then draft stories with clear user value.
- Break stories into tasks that can be completed independently.
- Keep ANCHOR.md aligned with the evolving product definition.
