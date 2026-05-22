# Planning

Planning and design artifacts for **process-improvement work** on the self-testing /
learning-pipeline tooling. This folder is **excluded from the deployed image** (see the
`/planning/` entry in `.dockerignore`), so nothing here ships to production. Keep planning here,
not in `docs/` -- `docs/` is deployed and serves the OpenAPI spec.

## The overall thing

The broader goal is to learn from technical textbooks effectively. The pipeline is roughly:

```
concept-design  -->  session-planner  -->  mcq-design / test_generator
(concept map +       (slice a book into     (questions + LOs the learner
 learning objectives) study-session units    is tested against)
                      + process each one)
```

This repo (the live self-testing app, `test_generator`) doubles as the **management hub** for
improving that pipeline: planning docs live here, and work items are tracked as GitHub issues
on this repo.

## How we manage a process-improvement effort

1. **Brainstorm** the idea into a design (don't jump to building).
2. **Spec it** in a `DESIGN.md` under a per-effort subfolder (e.g. `session-planner/`).
3. **Reason about it visually** with interactive workflow diagrams (the `workflow-diagram`
   skill). Each is a single self-contained HTML file, **render-verified** (headless-Chrome
   screenshot) before sharing, and hosted on the local plans server (port 8765) so it can be
   read on the iPad.
4. **Stress-test it** with an adversarial multi-agent review -- e.g. learning scientist, MECE
   auditor, integration/reality, practitioner/friction, red-team -- then synthesise the
   findings.
5. **Capture the work items as GitHub issues** on this repo, labelled by effort (e.g.
   `session-planner`) and type (`build` / `fix` / `decision` / `research` / `app`). Track them
   on the GitHub Projects board (it handles non-coding tasks).
6. **Log each working session** to the Obsidian daily note.

## Conventions

- British English, plain voice.
- Diagrams are read-only reasoning aids: refine by regenerating, not by hand-editing the HTML.
  The editable source lives here; served copies for the iPad live in `~/plans/` and are
  re-copied from here when changed.
- **Scope discipline:** every effort states what it is and what it is *not* (e.g.
  session-planner is ingestion only; review/spaced-repetition/studying are out of scope).
- Decisions are recorded in the effort's `DESIGN.md`; open decisions become `decision`-labelled
  issues rather than lingering in prose.

## Current efforts

- **session-planner/** -- the *ingestion* half of the pipeline: concept-map-driven slicing of a
  book into ~25-minute study-session units, plus a per-section processing ritual against a
  uniform definition of done. See `session-planner/DESIGN.md`, `BACKLOG.md`, and the two
  diagrams. Issues: label `session-planner` (first backlog: #75-#89).
