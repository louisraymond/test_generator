# Sub-issue #55 — Topic Detail: Collapsible Module Cards + Inline Nq Chip

**Plan author:** Topic-detail v2 working group
**Status:** Draft, TDD-ready
**Targets:** `/Users/louisraymond/projects/test_generator`
**Depends on:** #52 (server-side `@exam_usage` map), #54 (heat-map mode events)
**Blocks:** #56 (search/filter), #57 (keyboard layer)

---

## 1. Goal

Replace the monolithic right-pane block in `app/views/topics/show.html.erb` with a stack of collapsible **module cards**. Each card renders one `<article data-controller="topic-module">`, with a button-controlled header, a body holding category sub-sections, and one row per learning outcome carrying an inline heat-coloured `Nq` chip. The chip's value swaps live whenever the heat-map (sub-issue #54) emits `topic-heatmap:mode-changed` between the *Question count* and *Exam usage* modes.

This delivers the cards described in `sub-4-modules.md` while honouring the existing preload chain in `TopicsController#set_topic` (no new queries). Per-card state is persisted to `localStorage` under the key `topic-detail:topic-{topic.id}:expanded`. The first module is expanded by default; the rest are collapsed.

### Interaction with #54

The heat-map controller emits `topic-heatmap:mode-changed` (detail `{mode: 'questions' | 'usage'}`) and `topic-heatmap:focus-lo` (detail `{loId: <Integer>}`). This issue must:

1. **Listen for `mode-changed`** on every chip so the chip's text (e.g. `5q` versus `2x`) and background colour swap to the new bucket.
2. **Listen for `focus-lo`** to add `topic-detail__lo--pulse` to the matching outcome row for 300 ms (terracotta border keyframe).

Both are wired through `window` events to avoid coupling to the DOM tree above the controller.

### Decision: legacy `category-card` / `+ Add` flows during migration

The view will be feature-flagged via a session/cookie flag `topic_detail_v2` (see step 6). Until the flag is on by default:

- **Keep** the legacy `_legacy_show.html.erb` partial (renamed from the current monolithic block) wired to `topic-detail` controller. All existing BEM classes (`category-card`, `lo-item`, `add-lo-form`, `add-category-form`) and the Stimulus action handlers stay intact.
- **Render** the V2 markup via a new `_v2_show.html.erb` partial that mounts new partials (`_module_card.html.erb`, `_module_category.html.erb`, `_lo_row.html.erb`, `_lo_chip.html.erb`) and a new `topic-module` controller.
- The `+ Add LO`, `+ Add Category` and `+ Add Module` flows are **out of scope** for this issue (see acceptance criteria §8 — "Editing categories/outcomes inline (separate ticket)"). The V2 partial renders the dashed `+ Add category` button placeholders but they are no-op stubs in V1; they emit a flash *"Inline editing comes in #58"*. The legacy controller remains the only working surface for adding LOs/categories/modules until #58 lands.
- We do **not** delete the legacy classes, partial or controller in this issue. Deletion lives in a follow-up cleanup ticket (#60).

This protects rollback safety: a feature-flag flip restores the old UI without rebuilding any flow.

---

## 2. TDD Test List

All tests live under `/Users/louisraymond/projects/test_generator/spec/`. New paths:

- `spec/helpers/topic_module_helper_spec.rb`
- `spec/views/topics/_module_card.html.erb_spec.rb`
- `spec/views/topics/_lo_chip.html.erb_spec.rb`
- `spec/system/topic_detail_v2_modules_spec.rb`
- `spec/system/topic_detail_v2_a11y_spec.rb`
- `spec/system/topic_detail_v2_perf_spec.rb`

### 2.1 Helper / partial-render specs (no JS, fast feedback)

```ruby
# spec/helpers/topic_module_helper_spec.rb
describe TopicModuleHelper do
  describe '#module_collapsed_default?' do
    it 'returns false for the first module (idx 0)'
    it 'returns true for idx >= 1'
  end

  describe '#category_grouping' do
    it 'groups LOs by category, sorted alphabetically by category'
    it 'preserves position order within a category'
  end

  describe '#lo_chip_html' do
    it 'renders <span class="topic-detail__chip" data-questions="0" data-usage="0">'
    it 'applies bucket-0 (dashed) class when questionCount == 0'
    it 'applies bucket-1 colour for n == 1'
    it 'applies bucket-2 colour for n == 2'
    it 'applies bucket-3 colour for n == 4'
    it 'applies bucket-4 colour for n == 7'
    it 'sets aria-label "{n} questions" in questions mode'
    it 'embeds data-usage attribute pulled from the @exam_usage map'
  end
end
```

### 2.2 System specs (JS — `:js, type: :system`)

These all require `driven_by :selenium_chrome_headless`.

```ruby
# spec/system/topic_detail_v2_modules_spec.rb
describe 'Topic Detail V2 modules', js: true, type: :system do
  it 'expands the first module by default and collapses the rest'
    # assert via aria-expanded attribute on the header buttons
  it 'flips aria-expanded and reveals the body when the header button is clicked'
  it 'does NOT toggle the card when the Edit button on the header is clicked'
    # event.stopPropagation guards this
  it 'persists expand/collapse state to localStorage and restores on reload'
  it 'swaps every chip\'s colour and text when topic-heatmap:mode-changed is dispatched'
    # page.execute_script("window.dispatchEvent(new CustomEvent('topic-heatmap:mode-changed', {detail: {mode: 'usage'}}))")
  it 'expands every card when topic-module:expand-all is dispatched on window'
  it 'collapses every card when topic-module:collapse-all is dispatched on window'
  it 'pulses the matching outcome row when topic-heatmap:focus-lo is dispatched'
    # row gains topic-detail__lo--pulse for ~300ms then loses it
  it 'shows the empty placeholder when a module has no categories'
  it 'links the + question affordance to new_question_path with learning_objective_id'
  it 'renders the dashed-zero variant for outcomes with no questions'
end
```

### 2.3 Accessibility specs

```ruby
# spec/system/topic_detail_v2_a11y_spec.rb
describe 'Topic Detail V2 a11y', js: true, type: :system do
  it 'renders header as <button type="button"> with aria-expanded and aria-controls'
  it 'gives the body an id matching the header\'s aria-controls'
  it 'renders the outcome list as <ol> with li children'
  it 'sets aria-label on every chip in the form "{n} {units}"'
  it 'sets aria-label="Edit module {name}" on each Edit button'
  it 'marks chevron as aria-hidden="true"'
  it 'disables transitions when prefers-reduced-motion: reduce is forced'
    # use page.execute_script to set matchMedia mock OR run axe-core scan
  it 'passes axe-core with no AA violations on the rendered card'
end
```

### 2.4 Performance spec

```ruby
# spec/system/topic_detail_v2_perf_spec.rb
describe 'Topic Detail V2 render perf', type: :view do
  it 'renders 4 modules x 28 outcomes in under 50ms (Benchmark.realtime)' do
    topic = build_perf_fixture # 4 modules, 7 categories per module, 1 LO per cat = 28
    elapsed = Benchmark.realtime do
      render partial: 'topics/v2_show', locals: { topic: topic, exam_usage: {} }
    end
    expect(elapsed).to be < 0.050
  end
end
```

---

## 3. Implementation steps

Each step lists **Explanation**, **Before**, **After**, and the **Locking test** (the test that flips green when the step lands).

### Step 1 — New view partials

**Explanation:** Decompose the monolithic right-pane block into four partials. The new partials live alongside the existing show.html.erb and are wired through a new `_v2_show.html.erb`. The partials each take explicit locals so they can be unit-tested.

**Before:** `app/views/topics/show.html.erb` lines ~283–349 inline-render module sections, category cards, LO items, add-LO forms and add-category forms in one block.

**After:** four new files under `app/views/topics/`:

```erb
{# app/views/topics/_v2_show.html.erb #}
<section class="topic-detail__modules" data-controller="topic-detail-page">
  <% @topic.topic_modules.each_with_index do |mod, idx| %>
    <%= render 'topics/module_card', mod: mod, idx: idx, exam_usage: @exam_usage %>
  <% end %>
</section>
```

```erb
{# app/views/topics/_module_card.html.erb #}
<article id="mod-<%= mod.id %>"
         class="topic-module<%= ' topic-module--collapsed' if module_collapsed_default?(mod, idx) %>"
         data-controller="topic-module"
         data-topic-module-id-value="<%= mod.id %>"
         data-topic-module-topic-id-value="<%= mod.topic_id %>">
  <div class="topic-module__header-row">
    <button type="button"
            class="topic-module__toggle"
            aria-expanded="<%= !module_collapsed_default?(mod, idx) %>"
            aria-controls="mod-<%= mod.id %>-body"
            data-topic-module-target="toggle"
            data-action="click->topic-module#toggle">
      <span class="topic-module__chevron" aria-hidden="true">
        <%= inline_svg_tag 'chevron-right.svg' %>
      </span>
      <span class="topic-module__m-label">M<%= idx + 1 %></span>
      <span class="topic-module__title-block">
        <span class="topic-module__name"><%= mod.name %></span>
        <% if mod.description.present? %>
          <span class="topic-module__description"><%= mod.description %></span>
        <% end %>
      </span>
      <span class="topic-module__stats">
        <span class="topic-module__stat-num"><%= mod.learning_objectives.size %></span>
        <span class="topic-module__stat-label">LO</span>
        <span class="topic-module__stat-sep">·</span>
        <span class="topic-module__stat-num"><%= mod.questions.size %></span>
        <span class="topic-module__stat-label">Q</span>
      </span>
    </button>
    <%= link_to '#', class: 'topic-module__edit',
                aria: { label: "Edit module #{mod.name}" },
                data: { action: 'click->topic-module#edit' } do %>
      Edit
    <% end %>
  </div>

  <div id="mod-<%= mod.id %>-body"
       class="topic-module__body"
       data-topic-module-target="body"
       <%= 'hidden' if module_collapsed_default?(mod, idx) %>>
    <% if mod.learning_objectives.empty? %>
      <p class="topic-module__empty">No categories yet — press <kbd>a</kbd> to add one.</p>
    <% else %>
      <% category_grouping(mod).each do |category, los| %>
        <%= render 'topics/module_category',
                   mod: mod, category: category, los: los, exam_usage: @exam_usage %>
      <% end %>
    <% end %>
    <button type="button"
            class="topic-module__add-cat"
            data-action="click->topic-module#addCategory">
      + Add category
    </button>
  </div>
</article>
```

```erb
{# app/views/topics/_module_category.html.erb #}
<section class="topic-module__category" data-cat-id="<%= category.parameterize %>">
  <header class="topic-module__cat-header">
    <span class="topic-module__cat-name"><%= category %></span>
    <span class="topic-module__cat-filler" aria-hidden="true"></span>
    <span class="topic-module__cat-count"><%= pluralize(los.size, 'outcome') %></span>
  </header>
  <ol class="topic-module__lo-list">
    <% los.each_with_index do |lo, i| %>
      <%= render 'topics/lo_row', lo: lo, idx: i, exam_usage: @exam_usage %>
    <% end %>
  </ol>
  <button type="button"
          class="topic-module__add-lo"
          data-action="click->topic-module#addOutcome">
    + add outcome
  </button>
</section>
```

```erb
{# app/views/topics/_lo_row.html.erb #}
<li class="topic-module__lo topic-detail__lo"
    data-lo-id="<%= lo.id %>"
    data-lo-text="<%= lo.description %>"
    data-topic-module-target="loRow">
  <span class="topic-module__lo-idx"><%= idx + 1 %>.</span>
  <%= lo_chip_html(lo, exam_usage: exam_usage) %>
  <span class="topic-module__lo-text"><%= lo.description %></span>
  <%= link_to '+ question',
              new_question_path(learning_objective_id: lo.id),
              class: 'topic-module__lo-add' %>
</li>
```

```erb
{# app/views/topics/_lo_chip.html.erb — rendered via the helper, not directly #}
{# kept here so view spec can include it #}
<span class="topic-detail__chip <%= chip_class %>"
      data-topic-module-target="chip"
      data-questions="<%= q_count %>"
      data-usage="<%= u_count %>"
      title="<%= chip_title %>"
      aria-label="<%= chip_label %>">
  <%= chip_text %>
</span>
```

**Locking test:** the helper specs in §2.1 plus a view spec asserting that `_module_card` produces the correct skeleton (header button, body, ol, etc.) given a stub module with two LOs in two categories.

### Step 2 — Helpers

**Explanation:** Helpers keep the partials slim and unit-testable. `lo_chip_html` is the heaviest because it produces the chip with both the questions-mode and usage-mode values pre-populated as `data-*` attributes, so the Stimulus controller can swap on `mode-changed` without re-fetching.

**Before:** none (no helper module exists).

**After:**

```ruby
# app/helpers/topic_module_helper.rb
module TopicModuleHelper
  HEAT_BUCKETS = [
    { max: 0, klass: 'topic-detail__chip--zero' },
    { max: 1, klass: 'topic-detail__chip--b1' },
    { max: 3, klass: 'topic-detail__chip--b2' },
    { max: 6, klass: 'topic-detail__chip--b3' },
    { max: Float::INFINITY, klass: 'topic-detail__chip--b4' }
  ].freeze

  def module_collapsed_default?(_mod, idx)
    idx.positive?
  end

  def category_grouping(mod)
    mod.learning_objectives.group_by(&:category).sort_by { |cat, _| cat.to_s }
  end

  def lo_chip_html(lo, exam_usage:)
    q_count = lo.questions.size
    u_count = exam_usage.fetch(lo.id, 0)
    bucket  = HEAT_BUCKETS.find { |b| q_count <= b[:max] }

    render partial: 'topics/lo_chip', locals: {
      q_count: q_count,
      u_count: u_count,
      chip_class: bucket[:klass],
      chip_text:  "#{q_count}q",
      chip_title: "#{q_count} questions, #{u_count} exam uses",
      chip_label: "#{q_count} questions"
    }
  end
end
```

**Locking test:** `spec/helpers/topic_module_helper_spec.rb` (§2.1).

### Step 3 — CSS

**Explanation:** Append to `app/assets/stylesheets/topic.css`. Use existing tokens (`--card`, `--rule`, `--accent`, `--ink-3`, `--paper-2`). All new selectors prefixed with `.topic-module` or `.topic-detail__chip` to avoid collision with the legacy `.module-card` and `.category-card` styles. No deletions in this issue.

**After (appended block):**

```css
/* === V2 module cards === */
.topic-module {
  background: var(--card); border: 1px solid var(--rule); border-radius: 8px;
  box-shadow: 0 1px 0 var(--rule); scroll-margin-top: 20px; margin-bottom: 24px;
}
.topic-module--active {
  border-color: var(--accent); box-shadow: 0 0 0 3px rgba(180, 83, 42, 0.08);
}

.topic-module__header-row { display: flex; align-items: stretch; }
.topic-module__toggle {
  flex: 1; display: grid; grid-template-columns: 80px 1fr auto;
  gap: 16px; align-items: center; padding: 16px 20px;
  background: transparent; border: 0; cursor: pointer; text-align: left; font: inherit;
}
.topic-module__chevron { transition: transform 120ms ease; transform: rotate(0deg); display: inline-flex; }
.topic-module__toggle[aria-expanded='true'] .topic-module__chevron { transform: rotate(90deg); }
.topic-module__m-label { font-family: var(--mono); font-size: 10px; text-transform: uppercase; color: var(--accent); }
.topic-module__title-block { display: flex; flex-direction: column; }
.topic-module__name { font-family: var(--serif); font-size: 22px; line-height: 1.2; color: var(--ink); }
.topic-module__description { font-family: var(--sans); font-size: 14px; line-height: 1.5; color: var(--ink-3); }
.topic-module__stats { font-family: var(--mono); font-size: 11px; color: var(--ink-3); }
.topic-module__stat-num { color: var(--accent); }
.topic-module__edit {
  align-self: stretch; padding: 0 20px; border: 0; background: transparent;
  color: var(--accent); font-family: var(--mono); font-size: 11px; cursor: pointer;
}

.topic-module__body { padding: 20px 28px 24px; border-top: 1px solid var(--rule); }
.topic-module__body[hidden] { display: none; }

.topic-module__category + .topic-module__category {
  border-top: 1px solid var(--rule); padding-top: 16px; margin-top: 16px;
}
.topic-module__cat-header { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
.topic-module__cat-name  { font-family: var(--mono); font-size: 10px; text-transform: uppercase; color: var(--ink-3); }
.topic-module__cat-filler { flex: 1; border-bottom: 1px dotted var(--rule); }
.topic-module__cat-count { font-family: var(--mono); font-size: 10px; color: var(--ink-3); }

.topic-module__lo-list { list-style: none; padding: 0; margin: 0; }
.topic-module__lo {
  display: grid; grid-template-columns: 24px 36px 1fr auto;
  gap: 12px; align-items: center; padding: 6px 0;
}
.topic-module__lo:hover { background: var(--paper-2); }
.topic-module__lo-idx  { font-family: var(--mono); font-size: 11px; color: var(--ink-4); }
.topic-module__lo-text { font-family: var(--sans); font-size: 14px; line-height: 1.45; color: var(--ink-2); }
.topic-module__lo-add  { font-family: var(--mono); font-size: 11px; color: var(--accent); }

/* Chip */
.topic-detail__chip {
  display: inline-flex; align-items: center; justify-content: center;
  width: 32px; height: 22px; border-radius: 11px;
  font-family: var(--mono); font-size: 11px; font-weight: 500; color: #fff;
}
.topic-detail__chip--zero { background: transparent; border: 1px dashed var(--rule-2); color: var(--ink-4); }
.topic-detail__chip--b1 { background: #e9c8b6; color: var(--ink); }
.topic-detail__chip--b2 { background: #d59a78; }
.topic-detail__chip--b3 { background: #b4532a; }
.topic-detail__chip--b4 { background: #7a3317; }

/* Pulse */
@keyframes topic-detail-lo-pulse {
  0%   { box-shadow: 0 0 0 0 rgba(180, 83, 42, 0.5); }
  100% { box-shadow: 0 0 0 8px rgba(180, 83, 42, 0); }
}
.topic-detail__lo--pulse { animation: topic-detail-lo-pulse 300ms ease-out; border-radius: 4px; }

@media (prefers-reduced-motion: reduce) {
  .topic-module__chevron,
  .topic-detail__lo--pulse { transition: none !important; animation: none !important; }
}
```

**Locking test:** the system spec asserting "Edit button does NOT toggle the card" implicitly asserts the layout is grid-based; the a11y spec asserts the reduced-motion branch (via `page.execute_script` to set `matchMedia` mock).

### Step 4 — Stimulus controller

**Explanation:** One controller per card. Per-card listeners on `window` for the cross-card events (`mode-changed`, `focus-lo`, `expand-all`, `collapse-all`). The controller persists its single id into the shared localStorage array on toggle. Re-rendering chips on `mode-changed` is batched into a single `requestAnimationFrame`.

**Before:** none. The legacy `topic_detail_controller.js` is not modified.

**After:**

```javascript
// app/javascript/controllers/topic_module_controller.js
import { Controller } from "@hotwired/stimulus"

const STORAGE_PREFIX = 'topic-detail:topic-'
const STORAGE_SUFFIX = ':expanded'

export default class extends Controller {
  static targets = ['toggle', 'body', 'chip', 'loRow']
  static values  = { id: Number, topicId: Number }

  connect() {
    this._mode = 'questions'
    this._restoreState()
    this._boundMode  = (e) => this._onModeChanged(e)
    this._boundFocus = (e) => this._onFocusLo(e)
    this._boundEx    = () => this._setExpanded(true)
    this._boundCol   = () => this._setExpanded(false)
    window.addEventListener('topic-heatmap:mode-changed', this._boundMode)
    window.addEventListener('topic-heatmap:focus-lo',     this._boundFocus)
    window.addEventListener('topic-module:expand-all',    this._boundEx)
    window.addEventListener('topic-module:collapse-all',  this._boundCol)
  }

  disconnect() {
    window.removeEventListener('topic-heatmap:mode-changed', this._boundMode)
    window.removeEventListener('topic-heatmap:focus-lo',     this._boundFocus)
    window.removeEventListener('topic-module:expand-all',    this._boundEx)
    window.removeEventListener('topic-module:collapse-all',  this._boundCol)
  }

  toggle(event) {
    if (event && event.target.closest('.topic-module__edit')) return
    const expanded = this.toggleTarget.getAttribute('aria-expanded') === 'true'
    this._setExpanded(!expanded)
  }

  edit(event) {
    event.stopPropagation()
    event.preventDefault()
    // V1: no-op stub. Follow-up #58 implements inline edit.
    const flash = new CustomEvent('topic-detail:flash',
      { detail: { msg: 'Editing modules ships in #58.' } })
    window.dispatchEvent(flash)
  }

  _setExpanded(open) {
    this.toggleTarget.setAttribute('aria-expanded', String(open))
    if (open) this.bodyTarget.removeAttribute('hidden')
    else      this.bodyTarget.setAttribute('hidden', '')
    this._persist(open)
  }

  _persist(open) {
    try {
      const key = `${STORAGE_PREFIX}${this.topicIdValue}${STORAGE_SUFFIX}`
      const raw = window.localStorage.getItem(key)
      const arr = raw ? JSON.parse(raw) : []
      const set = new Set(arr)
      if (open) set.add(this.idValue); else set.delete(this.idValue)
      window.localStorage.setItem(key, JSON.stringify([...set]))
    } catch (_e) { /* Safari private mode — accept silently */ }
  }

  _restoreState() {
    try {
      const key = `${STORAGE_PREFIX}${this.topicIdValue}${STORAGE_SUFFIX}`
      const raw = window.localStorage.getItem(key)
      if (!raw) return
      const arr = JSON.parse(raw)
      const wasOpen = arr.includes(this.idValue)
      this._setExpanded(wasOpen)
    } catch (_e) { /* ignore */ }
  }

  _onModeChanged(event) {
    this._mode = event.detail.mode
    if (this._raf) return
    this._raf = window.requestAnimationFrame(() => {
      this._raf = null
      this.chipTargets.forEach((chip) => this._repaintChip(chip))
    })
  }

  _repaintChip(chip) {
    const q = Number(chip.dataset.questions)
    const u = Number(chip.dataset.usage)
    const v = this._mode === 'usage' ? u : q
    chip.textContent = this._mode === 'usage' ? `${v}x` : `${v}q`
    chip.setAttribute('aria-label',
      `${v} ${this._mode === 'usage' ? 'exam uses' : 'questions'}`)
    chip.classList.remove(
      'topic-detail__chip--zero', 'topic-detail__chip--b1',
      'topic-detail__chip--b2', 'topic-detail__chip--b3', 'topic-detail__chip--b4')
    chip.classList.add(this._bucketClass(v))
  }

  _bucketClass(n) {
    if (n === 0) return 'topic-detail__chip--zero'
    if (n === 1) return 'topic-detail__chip--b1'
    if (n <= 3)  return 'topic-detail__chip--b2'
    if (n <= 6)  return 'topic-detail__chip--b3'
    return 'topic-detail__chip--b4'
  }

  _onFocusLo(event) {
    const id = String(event.detail.loId)
    const row = this.loRowTargets.find((r) => r.dataset.loId === id)
    if (!row) return
    row.classList.add('topic-detail__lo--pulse')
    window.setTimeout(() => row.classList.remove('topic-detail__lo--pulse'), 300)
  }
}
```

**Locking test:** every system spec in §2.2.

### Step 5 — Edit-route gap fix

**Explanation:** the recon shows `resources :topic_modules, only: %i[create]` under the API namespace and **no** web-side `edit_topic_module_path`. Two options:

(a) **Add web-side route**: `resources :topic_modules, only: %i[edit update]` nested under `resources :topics` in `config/routes.rb`. Requires a `TopicModulesController#edit` action and a view. That is meaningful new surface area and changes the contract of #55.

(b) **Stub Edit as a no-op for V1**: the button calls `topic-module#edit` which does `event.preventDefault()` and dispatches a `topic-detail:flash` event (see step 4). A follow-up issue #58 introduces the real edit flow.

**Recommendation: (b).** The acceptance criteria explicitly say "Editing categories/outcomes inline (separate ticket)" and the parent ticket scope is the visual chrome and chip behaviour, not edit. Picking (a) bloats the PR and pulls in form-handling work that is genuinely separate.

**Tracking:** create follow-up issue #58 *"Inline module edit (name, description, position)"* before merging this plan.

**Locking test:** a system spec asserting "clicking Edit fires the topic-detail:flash event with the correct message" (small smoke test added to §2.2).

### Step 6 — Feature flag wiring

**Explanation:** Add a `topic_detail_v2?` helper that reads `cookies[:topic_detail_v2]` (or `Rails.configuration.feature_flags[:topic_detail_v2]`). Branch the show view on it.

**Before:**

```erb
{# app/views/topics/show.html.erb (existing root) #}
<div class="topic-detail premium-page-wrapper" ...>
  ... 268 lines of inline rendering ...
</div>
```

**After:**

```erb
{# app/views/topics/show.html.erb #}
<% if topic_detail_v2? %>
  <%= render 'topics/v2_show' %>
<% else %>
  <%= render 'topics/legacy_show' %>
<% end %>
```

Move the existing 268 lines verbatim into `_legacy_show.html.erb`. No code change, just a relocation. The new partial graph from step 1 hangs off `_v2_show.html.erb`.

```ruby
# app/helpers/topic_detail_helper.rb (extend existing)
def topic_detail_v2?
  return true if Rails.env.test? && ENV['TOPIC_DETAIL_V2'] != '0'
  cookies[:topic_detail_v2] == '1'
end
```

System specs run with `ENV['TOPIC_DETAIL_V2'] != '0'` so they default to V2; legacy specs (which we keep alive) explicitly set it to `'0'`.

**Locking test:** a controller-level request spec asserting that `GET /topics/:id` with no cookie renders the legacy partial; with the cookie it renders the V2 partial.

---

## 4. Antagonist review

### Persona A — Skeptic Engineer

**A1. Per-card Stimulus controllers vs one page-level controller.**
- *Defence:* Per-card scoping makes target binding trivial — each controller owns exactly its chips and rows. A single page-level controller would need `closest('.topic-module')` walks on every event and a much busier target list, and would re-render unaffected cards. Per-card also matches the Stimulus idiom of "one controller per HTML island".
- *Verdict:* **REJECT pushback** — keep per-card controllers.

**A2. localStorage key collides across tabs and shared browsers.**
- *Pushback:* `topic-detail:topic-{id}:expanded` is per-topic but not per-tab or per-user. Two tabs on the same topic stomp each other's writes; two users sharing a browser see each other's collapse state.
- *Defence:* This is collapse state, not data. Stomping on writes between tabs is a near-zero severity UX bug — last-tab-to-toggle wins, both reload to a consistent state. Per-user partitioning is impossible from JavaScript because there is no current-user identifier in the DOM that the legacy controller doesn't already leak. We accept the cross-tab and shared-browser drift; the cost of `BroadcastChannel`-based sync exceeds the benefit.
- *Verdict:* **ACCEPT** the pushback as a known limitation; document it in `docs/ADRs/` as a footnote. Do not mitigate.

**A3. 28 chips × 1 listener each = 28 window listeners.**
- *Pushback:* Memory and dispatch cost.
- *Defence:* The listeners are not on chips — they are on the *card controller*, of which there are at most ~6 per page. Each card controller iterates its own `chipTargets` inside `_onModeChanged`. So the listener count is `O(modules)`, not `O(chips)`. Even if it were 28, modern browsers dispatch a custom event to 28 listeners in well under a millisecond.
- *Verdict:* **REJECT** (clarification rather than change) — there are at most ~6 listeners.

**A4. `topic-module:expand-all` event design — window or document?**
- *Pushback:* `window` events are global; `document` is the conventional DOM-level bus.
- *Defence:* Stimulus' own dispatcher conventions use `document` for `turbo:*` events, but Hotwire-side custom events typically pick `window` because it is the only object guaranteed addressable from any script tag. For our case `document` would also work; the deciding factor is that #54 already uses `window.dispatchEvent` for `topic-heatmap:mode-changed`. Mixing buses is confusing.
- *Verdict:* **ACCEPT a clarification** — pin `window` as the canonical bus for all V2 page-level events; document this in `docs/plans/topic-detail-v2/conventions.md`.

### Persona B — A11y reviewer

**B1. Button-inside-button.**
- *Pushback:* The header button currently wraps the Edit button in the same DOM region. `<button>` inside `<button>` is invalid HTML and inaccessible.
- *Defence:* The plan in step 1 already separates them: `.topic-module__header-row` is a flex container with two children — the `<button class="topic-module__toggle">` and the `<a class="topic-module__edit">` (or a sibling `<button>`). The Edit affordance is a **sibling**, not a child, of the toggle button. The visual 4-column grid is achieved by making the toggle itself a CSS grid (3 cols) and the edit a flex-aligned sibling that visually looks like the 4th column.
- *Verdict:* **ACCEPT** the pushback as a clarification — explicitly call out in step 1 that toggle and edit are siblings, never nested. Markup above is updated.

**B2. `<ol>` with nested `<button>` inside `<li>` — clean?**
- *Pushback:* Each `<li>` contains a chip (`<span>`, no role) and a `+ question` `<a>`. Both are fine. No buttons-inside-buttons, no `role` collisions.
- *Defence:* The chip carries an `aria-label` and is a `<span>`. The `+ question` is an `<a>` (a real link to `new_question_path`). No issue.
- *Verdict:* **REJECT pushback** (it was a check, not a flag).

**B3. Chevron `aria-hidden` and `aria-expanded` location.**
- *Pushback:* `aria-expanded` must be on the toggle button, not on the chevron or its parent. Chevron must be `aria-hidden="true"`.
- *Defence:* Already true in step 1 markup: `aria-expanded` is on `<button class="topic-module__toggle">`; chevron `<span>` is `aria-hidden="true"`.
- *Verdict:* **REJECT pushback** (it was a check).

**B4. Pulse class isn't announced.**
- *Pushback:* Visual-only pulses are invisible to screen-reader users.
- *Defence:* Per #54's design, `topic-heatmap:focus-lo` is also expected to scroll-into-view and move keyboard focus to the row. We add focus management here: when `_onFocusLo` runs we call `row.focus({ preventScroll: false })` *if* the row is focusable. To make rows focusable we add `tabindex="-1"` to each `<li>`. Screen readers then read the row text on focus.
- *Verdict:* **ACCEPT** — add `tabindex="-1"` on `.topic-module__lo` and `row.focus()` in `_onFocusLo`. Updated.

### Persona C — Performance reviewer

**C1. 56 DOM writes on mode change.**
- *Pushback:* Mutating text + class for 28 chips is 56 writes.
- *Defence:* The controller already batches all chip repaints into one `requestAnimationFrame` (see `_onModeChanged` in step 4). The browser performs a single style/layout pass for the lot.
- *Verdict:* **ACCEPT clarification** — already in the design.

**C2. localStorage write on every toggle.**
- *Pushback:* Safari private mode throws.
- *Defence:* `_persist` and `_restoreState` already wrap in `try/catch`. No further mitigation needed.
- *Verdict:* **REJECT pushback** (already handled).

---

## 5. Open questions

1. **Is the heat-map mode `'questions' | 'usage'`** or some other token? Confirm with #54 owner before merging.
2. **Empty-module placeholder copy** — the spec says *"No categories yet — press a to add one."*. The keyboard layer (#57) defines `a` as the binding; until #57 lands, the `a` keystroke does nothing. Should the placeholder hide the kbd hint when V2-but-pre-#57?
3. **Edit stub behaviour** — should the no-op show a toast (current plan) or do nothing? Toast is more honest; product to confirm.
4. **`+ Add category` button styling** — dashed-border pill vs ghost text? Currently rendered as a plain button; needs a visual pass once Lookbook hosts the snapshot.

## 6. Risks

1. **Feature-flag drift.** Two parallel partials are easy to let drift. Mitigation: tag `_legacy_show.html.erb` with a `# DEPRECATED — remove after #60` banner and add a CI check that fails if the file is edited beyond whitespace.
2. **Chip class name collision.** `topic-detail__chip--b3` etc. are new. Search the repo for `__chip--` before merging to make sure none clash. (Recon shows no existing chip classes.)
3. **Event-name ambiguity.** `topic-module:expand-all` lives on `window`. If #57's keyboard controller binds to `document` instead, the listener never fires. Lock the bus convention now (per A4) and add a system test.
4. **localStorage corruption.** Malformed JSON under our key crashes `_restoreState`. Mitigation: try/catch already wraps; on parse error, delete the key and proceed with defaults.
5. **Performance regression for very large topics.** A topic with 12 modules × 50 outcomes is 600 chips. The 50 ms budget is for 4 × 28. Add a separate benchmark spec for the 12 × 50 case before launch and gate on, say, 200 ms.
6. **Selenium flakiness on the pulse spec.** The 300 ms class-removal timer is racy. Mitigation: in the spec, advance with `using_wait_time(1)` and assert *initial* class presence within 100 ms, then assert *removal* after 400 ms. Don't try to assert exact timing.
7. **N+1 sneaks back in.** `mod.questions.size` and `lo.questions.size` rely on the existing `.includes(...)` chain. If a future refactor breaks the preload, the perf spec will catch the latency spike but a `bullet`-style explicit assertion would be safer; consider adding `query_counter` matcher in a follow-up.

---

**End of plan.** Ready for green-light review and TDD kick-off.
