# Sub-54 — Topic Detail: heat-map + Coverage / Utilization toggle

**Issue:** #54
**Depends on:** #52 (`@exam_usage` hash on `TopicsController#show`), #53 (page chrome, CSS-grid layout, 4th-stat-card slot)
**Blocks:** —
**Plan path:** `/Users/louisraymond/projects/test_generator/docs/plans/topic-detail-v2/sub-54-heatmap-plan.md`

---

## 1. Goal

Deliver the heat-map block — the headline new feature of the redesigned `/topics/:id` page. It sits in the CSS-grid slot opened by #53, between the stat strip and the module list, and renders one row per `TopicModule` with a small coloured cell per `LearningObjective`. A segmented toggle flips the same surface between two modes:

- **Coverage** — cell value is `lo.questions.size` ("how many questions have I authored for this outcome?").
- **Utilization** — cell value is `@exam_usage.fetch(lo.id, 0)` ("how many distinct exams have used this outcome?").

Both numbers belong on the same surface because they answer the two sides of the same question — *am I covered, and am I using what I have?* The toggle is a `tablist`, mode is a Stimulus value, and a custom event (`topic-heatmap:mode-changed`) lets siblings (the 4th stat card from #53, the Nq chips from sub-4) react without coupling.

Out of scope: the `h` keyboard shortcut (sub-6), the Nq chip (sub-4), and persisting mode per user (parent-issue open question).

---

## 2. TDD test list

Each bullet maps one-to-one to a `it` block. Order is the order tests should be written.

### 2.1 Presenter / value-object specs (`spec/presenters/topic_heatmap_presenter_spec.rb`, plain `type: :model`-style POROs)

- `#rows` returns `Array<Hash>` of length `topic.topic_modules.size`, in `position` order.
- Each row hash has keys `:module`, `:cells`, `:totals`.
- `row[:cells]` is one entry per LO in `lo.position` order, each `{ lo:, count:, mode_count:, display: }`.
- In coverage mode `:count` and `:mode_count` are equal to `lo.questions.size`.
- In utilization mode `:mode_count` is `exam_usage.fetch(lo.id, 0)`; missing keys default to 0.
- `:display` clamps anything `> 99` to the string `"99+"` and preserves the exact int in `:count`.
- `row[:totals]` is `{ lo_count:, question_count:, uses_count: }` summed across the row.
- **Edge cases:**
  - Topic with 0 outcomes → `rows` returns `[]` (caller uses this to skip rendering).
  - Module with 0 outcomes → row exists with `cells: []` and `totals[:lo_count] == 0`; renderer uses this to draw the em-dash.
  - LO with `questions.size == 100` → `display == "99+"`, `count == 100`.
  - LO with `questions.size == 0` and `exam_usage` absent → `mode_count == 0` in both modes, no exception.

### 2.2 Helper specs (`spec/helpers/topic_detail_helper_spec.rb`)

- `heat_color(0)` returns the CSS class `"topic-heatmap__cell--heat-0"`.
- `heat_color(1)` and `heat_color(2)` return `"…--heat-1"`.
- `heat_color(3)` and `heat_color(4)` return `"…--heat-2"`.
- `heat_color(5)` and `heat_color(6)` return `"…--heat-3"`.
- `heat_color(7)`, `heat_color(99)`, `heat_color(150)` return `"…--heat-4"`.
- `heat_color(-1)` clamps to bucket 0 (defensive).
- `heat_text(2, mode: :coverage)` returns the string `"2"`. `heat_text(150, mode: :coverage)` returns `"99+"`.
- `heat_text(0, mode: :utilization)` returns `"0"` (we always render, never blank — colour conveys the zero state).

### 2.3 View specs (`spec/views/topics/_topic_heatmap.html.erb_spec.rb`, `type: :view`, rack_test friendly)

- Renders one `.topic-heatmap__row` per module.
- Each cell has both `aria-label` and `title`, and they match.
- Title format in coverage mode: `"{category} — {description} · {n} questions"`.
- Title format in utilization mode: `"{category} — {description} · {n} exam uses"`.
- The section heading reads "Question coverage" by default.
- Summary string in coverage mode matches `/\A\d+ questions across \d+ outcomes\z/`.
- Summary string in utilization mode matches `/\A\d+ appearances · \d+ outcomes never used\z/`.
- Legend caption reads `"Questions:"` in coverage mode, `"Exam uses:"` in utilization mode.
- Topic with 0 outcomes → partial renders nothing visible; `rendered` does **not** contain `data-controller="topic-heatmap"`.
- Module with 0 outcomes → row label is rendered, grid contains a single `.topic-heatmap__row-empty` with text `"—"`, totals column is blank.
- Cell with `count == 100` shows text `"99+"` but `aria-label` contains `"100 questions"` (exact).

### 2.4 System specs, JS-driven (`spec/system/topic_heatmap_spec.rb`, `js: true`)

These specs need `selenium_chrome_headless` because they exercise mode swap, scroll, and event dispatch — Capybara default `rack_test` will not run the controller. The spec file declares `before { driven_by(:selenium_chrome_headless) }` (or relies on a project-wide `js: true` registration if one is added).

- Default mode is coverage: title reads "Question coverage", `Coverage` tab has `aria-selected="true"`, cells carry the coverage colour classes.
- Clicking the `Utilization` tab updates the title to "Exam utilization", swaps the summary string format, flips `aria-selected` between the tabs, and re-paints the cells (assert by checking `data-mode="utilization"` on the section root and a sample cell's computed background).
- A spec-installed listener on `document` for `topic-heatmap:mode-changed` receives `{ mode: 'utilization' }` in `event.detail` after the swap.
- Cell click dispatches `topic-heatmap:focus-lo` with `{ loId: <int> }`. Asserted via a listener installed in the spec — sub-4 will own the actual scroll-and-pulse handler, so this spec stays narrow.
- Cell with `n > 99` displays the text `"99+"` and the `title` attribute contains the exact integer.
- `prefers-reduced-motion: reduce` (set via `page.driver.browser.execute_cdp('Emulation.setEmulatedMedia', features: [...])` or, if simpler, by toggling a `data-reduced-motion="true"` class the controller respects in tests) → the toggle has no `transition` style applied. If CDP is too brittle, fall back to asserting the CSS rule exists in the cascade rather than its runtime effect.
- Pressing `h` toggling the mode is **deferred to sub-6's spec** — note this in the file, do not add a binding here.

### 2.5 Accessibility specs (folded into the view + system specs)

- The toggle wrapper carries `role="tablist"` and an `aria-label="Heat-map mode"`.
- Each tab carries `role="tab"`, `aria-selected="true|false"`, and `tabindex="0"` on the active tab / `"-1"` on the inactive (so arrow-key navigation stays within the tablist; mouse users are unaffected).
- Each cell carries an `aria-label` of the form `"{category} — {description}, {count} {units}"`.
- Legend swatches carry `aria-hidden="true"` (decorative); the labels under them are the screen-reader source of truth.
- No axe-core gem is in the Gemfile per recon §7. Add manual aria assertions in the view spec; if the team later pulls in `axe-core-rspec` we wire a single smoke check then. Document the gap explicitly.

---

## 3. Implementation steps

Each step lists **Explanation**, **Before**, **After (file path)**, and a **Locking test** (the spec that pins the change).

### Step 1 — Add heat-colour tokens

**Explanation.** Five colour pairs are referenced across cells, swatches, and the totals column. They belong in `tokens.css` so the rest of the cascade can refer to them by name; we only inline the literal hexes once. The values are the ones the design hands us in §4 of the sub-issue.

**Before** (`/Users/louisraymond/projects/test_generator/app/assets/stylesheets/tokens.css`, the existing `:root` block per recon §5):

```css
:root {
  --ink: #15110c;
  --ink-2: #3a342c;
  --ink-3: #6b6358;
  --ink-4: #9a9287;

  --paper: #f7f4ee;
  --paper-2: #efeae0;
  --paper-3: #e5dfd3;
  --card: #fbf9f4;

  --rule: #d8d0c0;
  --rule-2: #c6bda9;

  --accent: #b4532a;
  --accent-ink: #7a3317;
  /* … */
}
```

**After** (`/Users/louisraymond/projects/test_generator/app/assets/stylesheets/tokens.css`, append inside the same `:root`):

```css
  /* Heat-map buckets — sub-54 */
  --heat-0-bg: var(--paper-3);
  --heat-0-fg: var(--ink-4);
  --heat-1-bg: #e8c4a8;
  --heat-1-fg: var(--ink-2);
  --heat-2-bg: #d4905f;
  --heat-2-fg: var(--paper);
  --heat-3-bg: #b4532a; /* same as --accent */
  --heat-3-fg: var(--paper);
  --heat-4-bg: #7a3317; /* same as --accent-ink */
  --heat-4-fg: var(--paper);
```

**Locking test.** None directly — these are consumed by Step 5's CSS, whose effect is asserted by the system spec in 2.4 (cell background changes after toggle). Adding a presence-of-token spec is over-fitting.

### Step 2 — Presenter object

**Explanation.** A POPRO (plain old presenter Ruby object) builds the per-row data once, in one place, in either mode. It is *not* a Rails generator artefact — just a class under `app/presenters/`. Recon §8 confirms there is no presenter convention yet; we are establishing one (justified in §4 — Persona B). The presenter takes the topic and the `exam_usage` hash from #52 as constructor args, so it needs no DB access of its own and is trivially unit-testable. It deliberately produces *both* counts per cell (`coverage_count`, `utilization_count`), so the view can render the active one and the controller can later swap text without a re-render — see Persona B in §4 for why we expose both.

**Before.** No file exists.

**After** (`/Users/louisraymond/projects/test_generator/app/presenters/topic_heatmap_presenter.rb`):

```ruby
# frozen_string_literal: true

# Builds the data payload for the topic-heatmap block (sub-54).
#
# One instance per request. Pure: no DB queries beyond the already-preloaded
# associations on `topic` (see TopicsController#set_topic) and the
# `exam_usage` hash from #52 (`{ lo_id => uses_count }`).
class TopicHeatmapPresenter
  CLAMP = 99

  Cell = Struct.new(:lo, :coverage_count, :utilization_count, keyword_init: true) do
    def display(mode)
      n = mode == :utilization ? utilization_count : coverage_count
      n > CLAMP ? "#{CLAMP}+" : n.to_s
    end

    def bucket(mode)
      n = mode == :utilization ? utilization_count : coverage_count
      case n
      when ..0 then 0
      when 1..2 then 1
      when 3..4 then 2
      when 5..6 then 3
      else 4
      end
    end
  end

  Row = Struct.new(:topic_module, :cells, :totals, keyword_init: true) do
    def empty?
      cells.empty?
    end
  end

  def initialize(topic, exam_usage: {})
    @topic = topic
    @exam_usage = exam_usage || {}
  end

  def rows
    return [] if @topic.learning_objectives.empty?

    @topic.topic_modules.map { |mod| build_row(mod) }
  end

  def summary(mode)
    los = @topic.learning_objectives
    case mode
    when :utilization
      appearances = los.sum { |lo| @exam_usage.fetch(lo.id, 0) }
      zeros = los.count { |lo| @exam_usage.fetch(lo.id, 0).zero? }
      { appearances: appearances, zero_count: zeros }
    else
      { question_count: los.sum { |lo| lo.questions.size }, outcome_count: los.size }
    end
  end

  private

  def build_row(mod)
    cells = mod.learning_objectives.sort_by { |lo| [lo.position.to_i, lo.id] }.map do |lo|
      Cell.new(
        lo: lo,
        coverage_count: lo.questions.size,
        utilization_count: @exam_usage.fetch(lo.id, 0)
      )
    end
    Row.new(
      topic_module: mod,
      cells: cells,
      totals: {
        lo_count: cells.size,
        question_count: cells.sum(&:coverage_count),
        uses_count: cells.sum(&:utilization_count)
      }
    )
  end
end
```

**Locking test.** `spec/presenters/topic_heatmap_presenter_spec.rb` — every bullet in §2.1.

### Step 3 — Helper

**Explanation.** Two pure functions: `heat_color(n)` returns a BEM modifier class so toggling colour is a class swap (cheap), not an inline-style re-write. `heat_text(n, mode:)` is the canonical clamp formatter so the view, the controller (when it swaps text on toggle — see Persona B), and the spec all agree on `"99+"`.

**Before.** No `topic_detail_helper.rb` exists today; recon §4 confirms the view is inline.

**After** (`/Users/louisraymond/projects/test_generator/app/helpers/topic_detail_helper.rb`):

```ruby
# frozen_string_literal: true

module TopicDetailHelper
  HEAT_BUCKETS = {
    0 => 'topic-heatmap__cell--heat-0',
    1 => 'topic-heatmap__cell--heat-1',
    2 => 'topic-heatmap__cell--heat-2',
    3 => 'topic-heatmap__cell--heat-3',
    4 => 'topic-heatmap__cell--heat-4'
  }.freeze

  def heat_bucket(count)
    case count.to_i
    when ..0 then 0
    when 1..2 then 1
    when 3..4 then 2
    when 5..6 then 3
    else 4
    end
  end

  def heat_color(count)
    HEAT_BUCKETS.fetch(heat_bucket(count))
  end

  def heat_text(count, mode: :coverage)
    n = count.to_i
    return '99+' if n > TopicHeatmapPresenter::CLAMP

    n.to_s
  end

  def heat_units(mode)
    mode.to_sym == :utilization ? 'exam uses' : 'questions'
  end
end
```

**Locking test.** `spec/helpers/topic_detail_helper_spec.rb` — every bullet in §2.2.

### Step 4 — View partial

**Explanation.** A single partial `_topic_heatmap.html.erb` owns the section markup. It expects two locals: `presenter` (a `TopicHeatmapPresenter`) and the active `mode` (defaults to `:coverage`). The partial renders both `data-coverage-count` and `data-utilization-count` on every cell so the controller can swap text in JS without a server round-trip — see Persona B for why this is correct (and not the "CSS-only swap" the issue's wording first implies).

**Before.** No file exists.

**After** (`/Users/louisraymond/projects/test_generator/app/views/topics/_topic_heatmap.html.erb`):

```erb
<%# locals: presenter:, mode: :coverage %>
<% rows = presenter.rows %>
<% if rows.any? %>
  <% summary_cov = presenter.summary(:coverage) %>
  <% summary_util = presenter.summary(:utilization) %>
  <section
    class="topic-heatmap"
    data-controller="topic-heatmap"
    data-topic-heatmap-mode-value="<%= mode %>"
    data-mode="<%= mode %>"
    aria-labelledby="topic-heatmap-title">
    <header class="topic-heatmap__head">
      <h2 id="topic-heatmap-title"
          class="topic-heatmap__title"
          data-topic-heatmap-target="title">
        <span data-mode-text="coverage">Question coverage</span>
        <span data-mode-text="utilization" hidden>Exam utilization</span>
      </h2>

      <div class="topic-heatmap__toggle"
           role="tablist"
           aria-label="Heat-map mode">
        <button type="button"
                role="tab"
                class="topic-heatmap__tab"
                aria-selected="<%= mode == :coverage %>"
                tabindex="<%= mode == :coverage ? 0 : -1 %>"
                title="# questions written for this outcome"
                data-topic-heatmap-target="tab"
                data-action="click->topic-heatmap#selectMode"
                data-topic-heatmap-mode-param="coverage">
          Coverage
        </button>
        <button type="button"
                role="tab"
                class="topic-heatmap__tab"
                aria-selected="<%= mode == :utilization %>"
                tabindex="<%= mode == :utilization ? 0 : -1 %>"
                title="# distinct exams that have used this outcome"
                data-topic-heatmap-target="tab"
                data-action="click->topic-heatmap#selectMode"
                data-topic-heatmap-mode-param="utilization">
          Utilization
        </button>
      </div>

      <p class="topic-heatmap__summary"
         data-topic-heatmap-target="summary">
        <span data-mode-text="coverage">
          <%= summary_cov[:question_count] %> questions across
          <%= summary_cov[:outcome_count] %> outcomes
        </span>
        <span data-mode-text="utilization" hidden>
          <%= summary_util[:appearances] %> appearances ·
          <%= summary_util[:zero_count] %> outcomes never used
        </span>
      </p>
    </header>

    <div class="topic-heatmap__rows">
      <% rows.each_with_index do |row, idx| %>
        <% mod = row.topic_module %>
        <div class="topic-heatmap__row">
          <a class="topic-heatmap__row-label" href="#mod-<%= mod.id %>">
            <span class="topic-heatmap__row-eyebrow">M<%= format('%02d', idx + 1) %></span>
            <span class="topic-heatmap__row-name"><%= mod.name %></span>
          </a>

          <% if row.empty? %>
            <div class="topic-heatmap__row-empty" aria-label="No outcomes in this module">—</div>
            <div class="topic-heatmap__row-totals" aria-hidden="true"></div>
          <% else %>
            <div class="topic-heatmap__row-grid">
              <% row.cells.each do |cell| %>
                <%
                  lo = cell.lo
                  cov_n = cell.coverage_count
                  util_n = cell.utilization_count
                  active_n = mode == :utilization ? util_n : cov_n
                  bucket = cell.bucket(mode.to_sym)
                  units = heat_units(mode)
                  label = "#{lo.category} — #{lo.description}, #{active_n} #{units}"
                %>
                <button type="button"
                        class="topic-heatmap__cell <%= heat_color(active_n) %>"
                        data-topic-heatmap-target="cell"
                        data-action="click->topic-heatmap#focusOutcome"
                        data-cell-lo-id="<%= lo.id %>"
                        data-coverage-count="<%= cov_n %>"
                        data-utilization-count="<%= util_n %>"
                        data-coverage-bucket="<%= cell.bucket(:coverage) %>"
                        data-utilization-bucket="<%= cell.bucket(:utilization) %>"
                        title="<%= label %>"
                        aria-label="<%= label %>">
                  <%= heat_text(active_n, mode: mode) %>
                </button>
              <% end %>
            </div>

            <div class="topic-heatmap__row-totals">
              <span data-mode-text="coverage">
                <%= row.totals[:lo_count] %> LO /
                <span class="topic-heatmap__totals-accent"><%= row.totals[:question_count] %> Q</span>
              </span>
              <span data-mode-text="utilization" hidden>
                <%= row.totals[:lo_count] %> LO /
                <span class="topic-heatmap__totals-accent"><%= row.totals[:uses_count] %> uses</span>
              </span>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>

    <footer class="topic-heatmap__legend" aria-label="Cell colour legend">
      <span class="topic-heatmap__legend-caption"
            data-topic-heatmap-target="legendCaption">
        <span data-mode-text="coverage">Questions:</span>
        <span data-mode-text="utilization" hidden>Exam uses:</span>
      </span>
      <% [['none', 0], ['1–2', 1], ['3–4', 2], ['5–6', 3], ['7+', 4]].each do |label, bucket| %>
        <span class="topic-heatmap__legend-item">
          <span class="topic-heatmap__legend-swatch topic-heatmap__cell--heat-<%= bucket %>"
                aria-hidden="true"></span>
          <span class="topic-heatmap__legend-label"><%= label %></span>
        </span>
      <% end %>
    </footer>
  </section>
<% else %>
  <%# heat-map omitted — topic has 0 outcomes %>
<% end %>
```

**Locking tests.** `spec/views/topics/_topic_heatmap.html.erb_spec.rb` — every bullet in §2.3.

### Step 5 — CSS

**Explanation.** All styles live under one `.topic-heatmap` block in `topic.css`. Cells are class-swapped between buckets — no inline styles. Mode is a `data-mode` attribute on the section root; the only thing it actually drives in CSS is the `data-mode-text` span visibility (one selector pair, see Persona B). Reduced-motion zeroes transitions.

**After** (append to `/Users/louisraymond/projects/test_generator/app/assets/stylesheets/topic.css`):

```css
/* === Heat-map block (sub-54) ====================================== */

.topic-heatmap {
  background: var(--card);
  border: 1px solid var(--rule);
  border-radius: 6px;
  padding: 20px 24px;
}

.topic-heatmap__head {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.topic-heatmap__title {
  font-family: var(--serif);
  font-size: 22px;
  margin: 0;
}

.topic-heatmap__toggle {
  display: inline-flex;
  border-radius: 4px;
  overflow: hidden;
}

.topic-heatmap__tab {
  font-family: var(--mono);
  font-size: 11px;
  padding: 6px 12px;
  background: transparent;
  border: 1px solid var(--rule);
  color: var(--ink-2);
  cursor: pointer;
  transition: background 120ms ease, color 120ms ease;
}

.topic-heatmap__tab[aria-selected="true"] {
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
}

.topic-heatmap__summary {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--ink-3);
  margin: 0;
  text-align: right;
}

.topic-heatmap__row {
  display: grid;
  grid-template-columns: 200px 1fr 80px;
  align-items: center;
  gap: 16px;
  padding: 8px 0;
  border-top: 1px solid var(--rule);
}

.topic-heatmap__row:first-child { border-top: 0; }

.topic-heatmap__row-label {
  display: flex;
  flex-direction: column;
  text-decoration: none;
  color: inherit;
}

.topic-heatmap__row-eyebrow {
  font-family: var(--mono);
  font-size: 10px;
  text-transform: uppercase;
  color: var(--accent);
}

.topic-heatmap__row-name {
  font-family: var(--serif);
  font-size: 14px;
  color: var(--ink);
}

.topic-heatmap__row-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.topic-heatmap__row-empty {
  font-family: var(--mono);
  color: var(--ink-4);
}

.topic-heatmap__row-totals {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--ink-3);
  text-align: right;
}

.topic-heatmap__totals-accent { color: var(--accent); }

.topic-heatmap__cell {
  width: 26px;
  height: 26px;
  min-width: 26px;
  border-radius: 2px;
  border: 1px solid transparent;
  font-family: var(--mono);
  font-size: 11px;
  font-weight: 500;
  font-variant-numeric: tabular-nums;
  text-align: center;
  line-height: 24px;
  padding: 0;
  cursor: pointer;
  transition: outline-color 120ms ease, background 120ms ease, color 120ms ease;
  /* Tap-target padding via outline rather than box (see Persona A) */
}

.topic-heatmap__cell:hover,
.topic-heatmap__cell:focus-visible {
  outline: 1px solid var(--ink-2);
  outline-offset: 1px;
}

.topic-heatmap__cell--heat-0 { background: var(--heat-0-bg); color: var(--heat-0-fg); }
.topic-heatmap__cell--heat-1 { background: var(--heat-1-bg); color: var(--heat-1-fg); }
.topic-heatmap__cell--heat-2 { background: var(--heat-2-bg); color: var(--heat-2-fg); }
.topic-heatmap__cell--heat-3 { background: var(--heat-3-bg); color: var(--heat-3-fg); }
.topic-heatmap__cell--heat-4 { background: var(--heat-4-bg); color: var(--heat-4-fg); }

.topic-heatmap__legend {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 12px;
  font-family: var(--mono);
  font-size: 10px;
  color: var(--ink-3);
}

.topic-heatmap__legend-swatch {
  display: inline-block;
  width: 16px; height: 16px;
  border-radius: 2px;
  vertical-align: middle;
  margin-right: 4px;
}

/* Mode-driven text swap — the only data-mode CSS rule we need. */
.topic-heatmap[data-mode="coverage"] [data-mode-text="utilization"],
.topic-heatmap[data-mode="utilization"] [data-mode-text="coverage"] {
  display: none;
}

@media (prefers-reduced-motion: reduce) {
  .topic-heatmap__tab,
  .topic-heatmap__cell {
    transition: none;
  }
}
```

**Locking tests.** The system spec in §2.4 (background swap, hover ring), and the reduced-motion bullet.

### Step 6 — Stimulus controller

**Explanation.** The controller is the *only* JS surface for this block. It owns mode state, swaps the `data-mode` attribute (driving the CSS span swap from Step 5), re-applies bucket classes on cells (since the bucket can differ between modes — `heat-2` for coverage might be `heat-0` for utilization on the same LO), updates cell text, and dispatches two custom events. Click delegation is on the controller root via Stimulus' `data-action` on each cell — that is one listener per cell at the framework level but Stimulus actually uses event delegation under the hood on the controller root, so the per-cell `data-action` cost is essentially free. (Persona C revisits this.)

**Before.** No file exists.

**After** (`/Users/louisraymond/projects/test_generator/app/javascript/controllers/topic_heatmap_controller.js`):

```javascript
import { Controller } from "@hotwired/stimulus"

const HEAT_CLASSES = [
  'topic-heatmap__cell--heat-0',
  'topic-heatmap__cell--heat-1',
  'topic-heatmap__cell--heat-2',
  'topic-heatmap__cell--heat-3',
  'topic-heatmap__cell--heat-4'
]

const CLAMP = 99

export default class extends Controller {
  static values = { mode: { type: String, default: 'coverage' } }
  static targets = ['title', 'summary', 'cell', 'legendCaption', 'tab']

  connect() {
    this._applyMode(this.modeValue, { silent: true })
  }

  selectMode(event) {
    const next = event.params.mode
    if (next === this.modeValue) return
    this.modeValue = next
  }

  modeValueChanged(value, previous) {
    if (previous === undefined) return // initial connect handles this
    this._applyMode(value, { silent: false })
  }

  focusOutcome(event) {
    const cell = event.target.closest('[data-cell-lo-id]')
    if (!cell) return
    const loId = Number(cell.dataset.cellLoId)
    this.dispatch('focus-lo', { detail: { loId }, bubbles: true })
  }

  _applyMode(mode, { silent }) {
    // Single batched pass — all DOM writes inside one rAF to avoid layout thrash.
    requestAnimationFrame(() => {
      this.element.dataset.mode = mode

      this.tabTargets.forEach((tab) => {
        const isActive = tab.dataset.topicHeatmapModeParam === mode
        tab.setAttribute('aria-selected', isActive ? 'true' : 'false')
        tab.tabIndex = isActive ? 0 : -1
      })

      this.cellTargets.forEach((cell) => {
        const cov = Number(cell.dataset.coverageCount)
        const util = Number(cell.dataset.utilizationCount)
        const n = mode === 'utilization' ? util : cov
        const bucket = mode === 'utilization'
          ? Number(cell.dataset.utilizationBucket)
          : Number(cell.dataset.coverageBucket)

        cell.classList.remove(...HEAT_CLASSES)
        cell.classList.add(HEAT_CLASSES[bucket])
        cell.textContent = n > CLAMP ? `${CLAMP}+` : String(n)
      })

      if (!silent) {
        this.dispatch('mode-changed', { detail: { mode }, bubbles: true })
      }
    })
  }
}
```

Notes on the controller:

- `dispatch('mode-changed', …)` produces the event name `topic-heatmap:mode-changed` (Stimulus namespaces `dispatch` by controller identifier).
- `bubbles: true` is needed so the listener on `document` (in the spec) and on the `topic-detail` root (for the 4th-stat-card swap, Step 8) receive it.
- Recon §6 confirms `eagerLoadControllersFrom("controllers", application)` in `index.js` — no manual registration is needed; saving the file is sufficient.

**Locking tests.** All system specs in §2.4.

### Step 7 — Wiring into `show.html.erb`

**Explanation.** Insert the partial render between the stat-strip output (#53) and the modules grid. The controller already preloads everything we need; we only need to expose the presenter as an ivar (or build it inline — inline is fine because the presenter constructor is cheap and stateless).

**Before** (`/Users/louisraymond/projects/test_generator/app/views/topics/show.html.erb`, the section per recon §4 between the header and the `Modules` heading — sub-53 will have introduced a stat-strip block here):

```erb
<%# … sub-53 stat-strip render … %>

<% if @topic.topic_modules.any? %>
  <h2>Modules</h2>
  <%# … modules grid … %>
<% end %>
```

**After:**

```erb
<%# … sub-53 stat-strip render … %>

<%= render 'topic_heatmap',
           presenter: TopicHeatmapPresenter.new(@topic, exam_usage: @exam_usage),
           mode: :coverage %>

<% if @topic.topic_modules.any? %>
  <h2>Modules</h2>
  <%# … modules grid … %>
<% end %>
```

`@exam_usage` is provided by #52. If for any reason it is `nil`, the presenter defaults to `{}` and utilization-mode counts become uniformly zero — graceful, but a regression should still be surfaced. We do **not** add a fallback in the controller; #52 is a stated dependency of this issue.

**Locking test.** A request spec under `spec/requests/topics/show_spec.rb` asserting `data-controller="topic-heatmap"` is present in the response body when the topic has outcomes, and absent when it does not.

### Step 8 — Wire the 4th stat card

**Explanation.** Sub-53 exposes the 4th stat card with a known target — call it `data-topic-detail-target="modeStatLabel"` and `…modeStatValue"` — and a default label of `"QUESTIONS"` plus the coverage value. When the heat-map dispatches `topic-heatmap:mode-changed`, the existing `topic-detail` controller listens and flips the label between `"QUESTIONS"` and `"EXAM USES"` and the value between the two pre-rendered numbers (also exposed as data attributes on the card by sub-53).

**Why extend `topic_detail_controller` rather than spin up a new controller.** Recon §6 shows `topic_detail_controller.js` is already attached to the page root and already owns cross-cutting wiring for the topic page. Adding one event listener is cheaper than introducing a fourth controller for the sake of one swap, and it keeps the contract — "the topic page coordinates between the heat-map and the stat strip" — in one place. If sub-2/sub-53 added its own `topic_sidebar_controller`, we'd put the listener there instead. Either is defensible; pick whichever sub-53 actually shipped, and document the choice in the PR.

**Before** (the relevant part of `topic_detail_controller.js` per recon §6):

```javascript
static targets = [
  "categoryCard", "categoryBody", "chevron", "addLoForm", "loInput",
  "addCategoryForm", "categoryNameInput", "firstLoInput", "addCategoryButton",
  "addModuleBtn", "wipModuleCard", "wipModuleName", "wipModuleDescription"
]
static values = { topicId: Number }

connect() {
  /* expand all categories on page load */
}
```

**After** (additions only):

```javascript
static targets = [
  /* … existing targets … */
  "modeStatLabel", "modeStatValue"
]

connect() {
  /* … existing body … */
  this._onHeatmapMode = this._onHeatmapMode.bind(this)
  this.element.addEventListener('topic-heatmap:mode-changed', this._onHeatmapMode)
}

disconnect() {
  this.element.removeEventListener('topic-heatmap:mode-changed', this._onHeatmapMode)
}

_onHeatmapMode(event) {
  if (!this.hasModeStatLabelTarget) return
  const mode = event.detail.mode
  if (mode === 'utilization') {
    this.modeStatLabelTarget.textContent = 'EXAM USES'
    this.modeStatValueTarget.textContent = this.modeStatValueTarget.dataset.utilization
  } else {
    this.modeStatLabelTarget.textContent = 'QUESTIONS'
    this.modeStatValueTarget.textContent = this.modeStatValueTarget.dataset.coverage
  }
}
```

**Locking test.** A bullet in the system spec: after switching to Utilization, the 4th stat card label reads `"EXAM USES"` and its value matches the utilization total.

---

## 4. Antagonist review

### Persona A — Visual Designer

**A1 — WCAG AA contrast across the five buckets.** Approximate ratios on the design colours:

- `--ink-4 #9a9287` on `--paper-3 #e5dfd3` ≈ **2.3 : 1** — **fails AA** (needs ≥ 4.5 for normal text).
- `--ink-2 #3a342c` on `#e8c4a8` ≈ **8.7 : 1** — passes.
- `--paper #f7f4ee` on `#d4905f` ≈ **3.1 : 1** — **fails AA** for normal text (cell text is 11px, not "large").
- `--paper` on `#b4532a` ≈ **5.0 : 1** — passes.
- `--paper` on `#7a3317` ≈ **9.3 : 1** — passes.

**ACCEPTED, with two changes to Step 1:**

- `--heat-0-fg`: `--ink-3 #6b6358` instead of `--ink-4`. New ratio ≈ 4.6 : 1.
- `--heat-2-fg`: `--ink #15110c` instead of `--paper`. New ratio ≈ 7.2 : 1.

Document the deviation in the PR body — the alternative (darkening the swatches) would shift visual balance more than retoning the text.

**A2 — Tap target on a 26 × 26 cell.** WCAG 2.5.5 and Apple HIG recommend ≥ 44 × 44. The design fixes the visible cell at 26 × 26 even on narrow screens. **ACCEPTED with mitigation:** keep the visible box, extend the hit area via a transparent pseudo-element. Add to Step 5:

```css
.topic-heatmap__cell { position: relative; }
.topic-heatmap__cell::after {
  content: '';
  position: absolute;
  inset: -8px; /* ~42×42 hit area, invisible */
}
```

Residual risk noted in §6 — full 2.5.5 compliance would need visible enlargement.

### Persona B — Skeptic Engineer

**B1 — Why a presenter, not a helper or jbuilder?** Helpers are global module functions — fine for `heat_color(n)`, awful for a stateful object holding a topic, an exam-usage hash, and producing 10+ rows. Jbuilder renders JSON; we render HTML. Recon §8 notes no presenter convention yet — this is the seam to introduce one, because the controller stays trivial and the view stays readable. **ACCEPTED — keep the presenter** under `app/presenters/`; let sub-55 / sub-56 / a future question-detail page reuse it.

**B2 — "Single CSS-variable swap" — does it actually work?** *No.* The original brief implies a `data-mode` attribute on the root drives all cell visuals via CSS variables. That works for **colour only**. It does **not** work for:

- Text content — `content: attr()` is restricted to `::before/::after`, has inconsistent screen-reader handling, and cannot encode the "99+" clamp.
- Bucket class — a cell's bucket can differ between modes (e.g. `count=2` is bucket 1 for coverage; if `uses=7` it's bucket 4 for utilization on the same cell).

**ACCEPTED, design corrected:** every cell carries both `data-coverage-count` / `data-utilization-count` and both `data-coverage-bucket` / `data-utilization-bucket`. The Stimulus controller swaps `topic-heatmap__cell--heat-N` and `textContent` inside one `requestAnimationFrame` (Step 6). The `data-mode` attribute on the root drives *only* the heading/summary/legend text swap, via one attribute-selector rule pair (Step 5).

**B3 — Who handles `topic-heatmap:focus-lo`?** Sub-4 does. **Contract:**

- Event name: `topic-heatmap:focus-lo`.
- `event.detail = { loId: Number }`.
- `bubbles: true` (Stimulus default for `composed`).
- Sub-4 selects `[data-lo-id="${loId}"]`, calls `scrollIntoView({ behavior: 'smooth', block: 'center' })`, and toggles `topic-detail__lo--pulse` for 300ms.

Documented in a leading comment in the partial so sub-4 has a stable reference.

### Persona C — Performance Reviewer

**C1 — 140 listeners?** **REJECTED framing.** Stimulus `data-action` uses one delegated listener at the controller root; per-cell `data-action` does not attach per-cell listeners. **ACCEPTED instinct:** the controller uses `event.target.closest('[data-cell-lo-id]')` so any future inner-element (e.g. `<svg>`) still resolves correctly.

**C2 — Forced reflow on toggle.** **ACCEPTED, pre-empted.** Step 6 batches every DOM write inside one `requestAnimationFrame` with no reads in the same frame. One `data-mode` attribute mutation on the root, class + text swaps on cells — write-only.

**C3 — Layout shift between `"7"` and `"99+"`.** **ACCEPTED.** Step 5's CSS pins `min-width: 26px`, `text-align: center`, and `font-variant-numeric: tabular-nums`. 1-, 2-, and 3-character renderings all fit the same fixed box. No further change.

---

## 5. Open questions

1. **Mode persistence per user.** Parent issue open. Default is coverage on every load. If we later persist, `localStorage` keyed by topic id wired into `connect()` is the cheap path — no schema change.
2. **Presenter reuse on question-detail.** Likely yes. The presenter is pure and constructor-injected, so reuse is mechanical. **Design for it now:** keep it free of topic-page assumptions; keep per-mode formatting in the helper / view, not the presenter.
3. **Reduced-motion testing strategy.** CDP emulation is brittle across selenium versions. Decide later whether to assert the CSS rule's *existence* (cheap, brittle to refactor) or its *runtime effect* (accurate, requires CDP). Default to existence-assertion.

---

## 6. Risks (top 3)

1. **#52 / #53 not yet merged.** Plan assumes `@exam_usage` and the stat-strip slot. *Mitigation:* default `@exam_usage ||= {}` so the page does not 500 if #52 slips; gate Step 8 behind `hasModeStatLabelTarget` so it no-ops if #53's targets are absent. Rebase on top of both before merge.
2. **Selenium JS specs flake on CI.** Mode-swap, focus-lo, and reduced-motion specs require `js: true`; recon §7 shows no Capybara configuration block. *Mitigation:* land a small precursor `spec/support/capybara.rb` (`register_driver :selenium_chrome_headless`) if needed, kept minimal so reviewer scope stays on the heat-map.
3. **Contrast regression.** Persona A's fixes pin specific text/background pairs; a future colour tweak could silently re-break AA. *Mitigation:* comment Step 1's tokens block referencing this plan, and consider a post-merge `axe-core` smoke check on the seeded thermal-quantum-physics topic.

---

**British English throughout.** Real file paths verified against recon §1–§10. Code blocks are copy-pasteable into the indicated paths.
