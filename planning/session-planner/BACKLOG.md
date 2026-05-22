# Session Planner -- Work Item Backlog

Candidate issues for the **louisraymond/test_generator** GitHub board (it handles non-coding
tasks too). Generated from the design conversation + the 5-agent design review.

Scope: **ingestion only.** Review process, spaced repetition, and later studying are
explicitly out of scope, so retention / review-loop findings are deliberately absent.

Each item is written issue-ready: title, one-line body, suggested label. Nothing here is
created on GitHub yet -- promote when ready.

## Build (the core system)

- [ ] **Build the Planner skill** -- cutting logic (the 8 steps), load heuristic, dependency-seam
      reconcile, the human approval gate, and plan output (draft table + Obsidian Kanban cards +
      optional workflow diagram). `[build]`
- [ ] **Build the board writer** -- Obsidian Kanban (To Process / Reading / Done); card = a slice
      carrying its location data (page range) and the uniform DoD. `[build]`
- [ ] **Build the Processing Ritual** -- the per-card ingestion sequence, reusing `mcq-design` and
      the test_generator LO/MCQ endpoints. `[build]`

## Fixes (surfaced by the review)

- [ ] **Rename the processing board off the `*Board*.md` namespace** (e.g. `… - Reading Pipeline.md`)
      so `learning-board`'s `**/*Board*.md` glob can't prompt-overwrite it. `[fix]`
- [ ] **Spell out the `mcq-design` handoff** -- the Ritual must pass the chapter `learning_outcomes.md`
      + `topic_id` and scope to the slice's LOs (mcq-design refuses without them and reads LOs, not
      the concept map). `[fix]`
- [ ] **Make the coverage check coverage-only** -- "every LO has >=1 question"; drop "good / well
      covered" until the question-quality rubric exists. `[fix]`

## Decisions to make

- [ ] **How heavy should a single session be?** -- the review's main finding: a 6-criterion DoD may
      not fit one 25-min sitting. Decide whether to split a slice into a Read card + a Test/Process
      card, shrink the visible per-card DoD to a small must-have core, and add a minimum-viable-session
      fallback. `[decision]`
- [ ] **Load heuristic: weight it or simplify it** -- define the density-proxy weighting, OR drop to
      page-count + a manual "this is dense" nudge (the approval gate already lets you override).
      Calibrate before building any weighting. `[decision]`
- [ ] **Cross-chapter dependencies** -- honour them when cutting, or only within the current chapter?
      `[decision]`
- [ ] **Load-vs-dependency conflict** -- when load wants a cut but a dependency forbids it, which wins?
      `[decision]`
- [ ] **Graceful degradation on thin concept maps** -- on narrative / unsignposted books the map will
      be sparse; the slicer should fall back toward page-count + headings rather than emit confident
      nonsense. `[decision]`
- [ ] **Ritual packaging** -- its own skill, or a documented sequence reusing existing skills?
      `[decision]`
- [ ] **The "understood" bar** -- "understood once" is unmeasurable; decide what (if anything) makes it
      checkable during ingestion, given studying/retention is out of scope. `[decision]`

## Research / app

- [ ] **Define the question-quality rubric** -- the parked Half-1 work: per-question process, criteria,
      and an evaluation step (e.g. an adversarial "can I answer this blind?" gate). `[research]`
- [ ] **Verify image-attach mechanics in test_generator** -- how the underlying image is supplied for
      `diagram_label` / `image_occlusion` (URL vs markdown embed vs upload). This is a genuine
      test_generator app question. `[app]`
