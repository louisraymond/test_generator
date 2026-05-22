# Session Planner -- Design Spec

Status: consolidated draft, ready for team review
Date: 2026-05-22 (consolidated)

Figures: this spec has two companion diagrams (see "Diagrams" at the end). They are the
authoritative picture of the two components; the prose here is the contract around them.

## Problem

Working through a large textbook stalls for two reasons.

1. **Throughput.** The books are huge, big undefined tasks get procrastinated on, and the
   project of getting through one needs planning. The fix is to break a book into small,
   well-defined units that fit a single Focusmate sitting (about 25 minutes, sometimes two),
   tracked on a Kanban board so the next action is always one concrete card. Small, bounded
   units lower the activation energy (the "binge a series vs commit to a film" effect).
2. **Trust in the slicing.** Past attempts to get Claude to slice a book produced cuts that
   were not convincing. Headers are a lossy signal: sometimes sections should be merged,
   sometimes split, and narrative or unsignposted books have little to go on.

A separate, related problem -- **question quality** (MCQs that give their answers away or rely
on context not provided) -- is acknowledged but deliberately **parked** here (see Open
Questions). This spec is about throughput and the per-section processing workflow.

## What this is (and is not)

The system is **two components**, and keeping them separate is load-bearing:

- **A. The Planner** -- a *reasoning tool*. It decides where to cut a book into sessions and
  attaches the uniform definition of done, then emits a plan. It does **not** generate
  learning objectives or questions, call `mcq-design`, or seed anything. Reasoning, then a
  plan. (Persisting that plan as Kanban cards is just emitting the decision, not execution.)
- **B. The Processing Ritual** -- *execution*. What happens when a card comes due in a
  Focusmate session. It orchestrates existing skills (`concept-design` output, `mcq-design`,
  `/study`, `/socratic`, the test_generator app). This is not the Planner's job.

It is **not**: the cognitive-phase `learning-board` (that tracks To Study / Encoding /
Retrieving / Applied and must not be repurposed), a restructuring of test_generator, or the
heavy `/course` pipeline.

## Key insight

Slice the book **after** the concept map exists, not before. Cutting a structured dependency
graph is tractable in a way that cutting raw 600-page prose is not, and the dependency graph
imposes seams even on narrative texts with no headings. The concept map already exists from
the first pass of `concept-design`, so the Planner's input is free.

## What a concept map is (the Planner's input)

A concept map is what `concept-design` produces on its first pass. It is not prose you read;
it is a structured index you reason over. For a chapter it captures:

1. Every section / subsection **with its page range** (the signposts, extracted)
2. The **key concepts** per section (one-liners)
3. A **dependency graph** -- which concepts build on which, within and across chapters
4. A **key-figures table** -- each figure / diagram and what it shows

Why it beats "lean on signposts and split by feel": signposts tell you where sections start,
not how they relate or how heavy they are. The concept map adds **dependencies** (which cuts
are safe) and **density** (figures + concept count, so you size by cognitive load, not page
count). It is also reused downstream as the spec the LOs and questions are built from, so it
is not extra work for cutting alone.

## Architecture (where it sits)

```
concept-design (already run) --> {Book} - Concept Map.md   [exists, Obsidian]
                                          |
                          A. PLANNER (reasoning tool)
                                          |
                          draft plan --(you approve)--> cards on the Obsidian Kanban
                                                        (each: slice location data + uniform DoD)
                                          |
                          B. PROCESSING RITUAL (per card, in a Focusmate session)
                            pretest -> read -> generate questions -> attempt ->
                            reconcile LOs -> capture media/refs -> DoD gate -> Done
```

## Component A -- The Planner (reasoning tool)

### The cutting process

Eight steps (see the cutting-process diagram for the full annotated version):

1. **Read the concept map.** Section index + dependency graph + key-figures table. No PDF.
2. **Seed candidate cut points** from the section / subsection headings (author structure as
   first guess). On narrative books with few headings, fall back to clustering by dependency.
3. **Estimate load per section** -- cognitive load, not page count. Heuristic from page-span x
   density proxy (figure count, formula / quantitative concepts, dependency fan-in).
4. **Map dependencies between concepts** -- find boundaries with few cross-edges; flag any cut
   that would split a prerequisite from the concept that needs it.
5. **Reconcile: resize for load, snap to seams** -- merge sections under the load floor, split
   those over the ceiling, then move boundaries onto low-cross-edge dependency seams. This is
   the crux, and the step most likely to produce a cut the learner distrusts.
6. **Attach the standard definition of done** -- one uniform contract for every section (see
   below). There is no bespoke per-section DoD; the only per-slice variation is reassessment:
   if a section proves too big or needs more context, split it in two or flag it for further
   refinement.
7. **Emit the draft plan with a rationale per cut** -- the ordered slice list, each with page
   range, load estimate, and a one-line reason for the cut.
8. **Human gate.** You review and adjust the cuts (merge, move, override load). Nothing becomes
   a plan without your sign-off. This is the core mitigation for "I do not trust the slicing."

Two things are fixed regardless of method: cuts are budgeted by **cognitive load** (a slice is
one sitting; allow a "2 sittings" tag rather than an unreadable chunk), and the draft plan is
always **approved by the learner** before it becomes cards.

### Output: the plan

- A **draft table** (slice / pages / load / why) for approval.
- On approval, **cards on the relevant Obsidian Kanban**, each carrying the slice's location
  data (page range for the cut) and the uniform DoD checklist.
- Optionally rendered as a **workflow diagram** of the per-book plan (the `workflow-diagram`
  skill), the way the DDIA Ch 9 / Ch 10 and AI Engineering Ch 2 worked examples were.

## The Definition of Done (uniform)

The DoD is the **contract for the whole flow**, the same for every section. A section is Done
when:

1. The content is **understood** (at least once).
2. The **learning objectives are captured and clarified**.
3. You can **explain how the section fits the bigger picture**.
4. The **media for later review is described / defined / created**.
5. **Enough good questions exist and are captured in the app** (test_generator).
6. Any **quotes / references are noted and captured**.

It is uniform across sections. What differs between sections is only the *content* each
criterion produces (a calculation question where there are formulas, a diagram to make where
there is a key figure), not the criteria themselves. The only structural per-slice variation
is reassessment (split or refine), per step 6 above.

## Component B -- The Processing Ritual (per session)

What happens when a card comes due (see the processing-ritual diagram for the annotated
version). Artifacts are made just before or during the sitting, not in a big upfront batch.

1. **Card comes due** -- the slice (location data) and the uniform DoD are pulled from the
   Kanban. This is the only handoff from the Planner.
2. **Make a pretest** (Claude) -- a few generation-effect questions, to be attempted *before*
   reading.
3. **Obtain section + concatenate** -- pull the section text at the slice page range, prepend
   the pretest, making one reading artifact.
4. **Read the section** (you, ~25 min Focusmate) -- attempt the pretest first, then read.
5. **Generate questions** (Claude) -- an MCQ section plus an other-types section. The app
   supports `diagram_label`, `image_occlusion`, `cloze`, `matching`, `ordering` and more, so
   label-a-diagram and partially-filled-diagram items are first-class.
6. **Attempt the questions** (you) -- attempt without leaning on the markscheme; optionally run
   `/study` or `/socratic` on the passage. Even weak questions force recall and question
   critique (higher-order engagement).
7. **Discuss + reconfigure LOs** -- compare the slice's LOs to what is in the chapter module
   in test_generator; add any missing, edit existing in place. Discuss how the passage fits
   the bigger picture. The module structure stays chapter-grained; slices never become modules.
8. **Check question coverage** -- ensure the questions completely and well cover the slice LOs.
9. **Capture media + references** -- note or make the diagrams / graphics for review; capture
   any quotes / references.
10. **DoD gate -> card to Done** -- re-verify the six criteria; the card moves to Done only when
    all are satisfied.

**Two-phase testing.** The design uses a *pretest before reading* (generation effect: guessing
wrong primes absorption) and *review questions after* (for spaced recall). These are distinct
moments, not the same questions.

**test_generator integration.** Topic = book, Module = chapter (existing, upstream). The ritual
adds / edits LOs in the chapter module and attaches MCQs to them. It never creates or
restructures modules.

## The Obsidian board

A throughput board (distinct from the cognitive-phase `learning-board`), written to the vault.
Three columns: **To Process** (the approved plan), **Reading (WIP 1)** (the active slice), and
**Done**. Each card is a slice carrying its location data and the uniform DoD as sub-items.

## Worked validation

The cutting process has been run by hand against real concept maps to sanity-check it:

- **DDIA 2e Ch 9** (The Trouble with Distributed Systems, ~44pp) -> 9 slices, ~10 sittings.
  A near-linear dependency chain, so 6 of 8 cuts fell on free section seams.
- **DDIA 2e Ch 10** (Consistency and Consensus, ~41pp) -> 10 slices, ~12 sittings. Denser, so
  more sittings despite fewer pages -- the load-not-pages rule in action; cuts fell on the
  book's subheadings inside the two 15-page monoliths.
- **AI Engineering Ch 2** (~112pp) -> 10 slices, spanning the full range of per-section content
  (formula-heavy, figure-heavy, and plain) -- the same uniform DoD, different content per criterion.

## Boundaries -- what this is NOT

- Not the `learning-board` (cognitive phases; must not be renamed or repurposed).
- Not a restructuring of test_generator (modules stay chapter-grained).
- Not the heavy `/course` pipeline (20+ agents, 7 phases).
- Not an upfront mass-generation of artifacts. Generation is just-in-time per card.

## Open questions / deferred

- **Question-quality rubric** -- define the per-question process, criteria, and evaluation
  (e.g. an adversarial "can I answer this blind?" check). This is the parked Half-1 work; a
  later ticket, orthogonal to getting cutting + processing working.
- **Load density-proxy** -- what exactly goes into it, and how each factor is weighted.
- **Cross-chapter dependencies** -- honour them, or only within the current chapter?
- **Load vs dependency conflict** -- when load wants a cut but a dependency forbids it, which
  wins?
- **Image-attach mechanics** -- how the underlying image is supplied for `diagram_label` /
  `image_occlusion` (URL vs markdown embed vs upload), to verify in the app.
- **Packaging** -- whether the Ritual is its own skill or a documented sequence reusing
  existing skills.

## Diagrams (the spec's figures)

- `cutting-process-diagram.html` -- Component A, the Planner.
- `processing-ritual-diagram.html` -- Component B, the Ritual (with the uniform DoD as a
  first-class thread).

Both live in this skill directory (editable source) and in `~/plans/` (served on port 8765 for
iPad reading).

## Build outline (to be detailed by writing-plans)

1. `SKILL.md` for the Planner: trigger phrases, the concept-map input, the cutting logic, the
   load heuristic, the approval gate, the plan output (Kanban cards + optional diagram).
2. The board writer (Obsidian Kanban file, card format with slice location data + uniform DoD).
3. The Processing Ritual: the per-card sequence, reusing `mcq-design`, `/study`, `/socratic`,
   and the test_generator LO add/edit + MCQ attach.

## Voice

British English, direct and plain, no em dashes in prose.
