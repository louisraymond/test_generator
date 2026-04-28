# Sub-56 — Topic Detail: search + view switcher (TDD plan)

**Issue:** #56
**Depends on:** #53 (toolbar markup), #55 (module markup with `data-lo-text`, `data-cat-name`, `data-mod-name`), #54 (heat-map mode)
**Blocks:** —
**Branch suggestion:** `topic-detail-v2/sub-56-search-views`

---

## 1. Goal

Search filters outcomes inline; the view switcher re-organises the same data three ways. No server round-trips — the user types, a Stimulus controller toggles classes on already-rendered DOM. View switching is also client-side: pressing **v** cycles `modules → categories → outcomes → modules`, persisted to `localStorage`.

Two invariants across view changes: heat-map mode is preserved (sub-54 owns chip colour state); the search query is preserved and re-applied to whatever DOM the new view rendered.

All three view trees are rendered server-side and toggled via `[hidden]`. Pre-render-and-toggle reasoning lives in Persona A.

---

## 2. TDD test list

All system specs require JS. Add `js: true` to each example and configure `selenium_chrome_headless` in `spec/rails_helper.rb` (recon confirms it isn't set today).

### 2.1 Capybara configuration prerequisite

```ruby
# spec/rails_helper.rb (additions)
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1400,1000')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
  config.before(:each, type: :system) do |example|
    driven_by :rack_test unless example.metadata[:js]
  end
end
```

### 2.2 System specs (`spec/system/topic_detail/search_and_views_spec.rb`)

Each bullet is one locking test. Fixture: a topic with 4 modules, 10 categories, 28 outcomes; "Schrödinger" appears in exactly two outcome descriptions and one category name.

- **Live filter, outcome match.** Type `Schrödinger` into the search input → outcome rows that do not match receive `topic-detail__lo--filtered` and disappear. Categories with zero matches receive `topic-detail__cat--filtered`. Modules with at least one match auto-expand and the header shows `· N matches`.
- **Module-name match.** Type a module's name. Every outcome under that module counts as a match; the module header shows `· {n} matches` where `n == module.learning_objectives.count`.
- **Category-name match.** Type a category name (e.g. `Schrödinger Equation`). Every outcome under that category, in every module, is visible.
- **Case-insensitive substring.** Typing `schrödinger` matches the same set as `Schrödinger`.
- **Whitespace normalisation.** Typing `  schrö dinger  ` is treated as `schrö dinger` (leading/trailing trimmed, runs collapsed). A single space between tokens is preserved.
- **Empty query restores prior state.** Manually collapse Module A, type `Schrödinger`, clear the input. Module A is collapsed again (sub-55's `topic-detail:topic-{id}:expanded` localStorage state is the source of truth).
- **`aria-live` announcement.** After filtering, `[data-topic-search-target="liveRegion"]` contains `"4 outcomes match"`.
- **Esc clears.** Focus the input, type `xyz`, press Esc → input value empty, all filter classes removed, live region announces `"search cleared"`.
- **View cycling via `v`.** Default is `modules`. Press `v` (sub-6 dispatch) → `categories` view visible, others `[hidden]`. Press `v` again → `outcomes`. Press `v` again → back to `modules`.
- **`categories` view content.** Outcomes are grouped by category name across all modules, alphabetically. Each row shows an `M{idx}` mono tag identifying its source module.
- **`outcomes` view content.** Flat list of 28 rows in topic order. The sort `<select>` has options `Topic order`, `Nq desc`, `Nq asc`, `Alphabetical`. Selecting `Nq desc` re-orders rows highest-first.
- **View persists.** Set `outcomes`, reload — the outcomes view is active. Confirmed by reading `localStorage.getItem('topic-detail:topic-{id}:view')` via `page.evaluate_script`.
- **Heat-map mode preserved across view change.** Activate heat-map (sub-54), switch view → chip colours unchanged.
- **Search query preserved across view change.** Type `Schrödinger`, press `v` to enter `categories` view — the same query is re-applied to the new DOM and only matching rows are visible.
- **Empty state.** Type `xyzzy` — `_search_empty.html.erb` renders above the active view with `Clear search` button. Clicking it clears the input and live region announces `"search cleared"`.
- **Heat-map cell highlight.** Type a query that matches outcome `id=42`. The heat-map cell with `data-lo-id="42"` receives the `topic-detail__heat-cell--query-hit` class.

### 2.3 Performance spec (`spec/system/topic_detail/search_perf_spec.rb`)

< 4ms is too tight to gate in CI. Treat as a manual benchmark + soft assertion (< 25ms) for order-of-magnitude regressions.

```ruby
it 'filters 28 outcomes in well under a frame', js: true do
  topic = create_topic_12_fixture
  visit topic_path(topic)
  fill_in 'search-outcomes', with: 'a' # forces a full pass

  duration = page.evaluate_script(<<~JS)
    (() => {
      const m = performance.getEntriesByName('topic-search:filter').pop();
      return m ? m.duration : null;
    })()
  JS

  expect(duration).not_to be_nil
  expect(duration).to be < 25
  puts "[bench] topic-search:filter = #{duration.round(2)}ms"
end
```

The controller wraps each filter pass in `performance.mark`/`performance.measure` named `topic-search:filter`. CI logs the ms count; `docs/plans/topic-detail-v2/PERF.md` records the local-laptop reading (< 4ms target).

### 2.4 Accessibility specs (`spec/system/topic_detail/a11y_spec.rb`)

- The search input has a visually-hidden `<label for="search-outcomes">Search outcomes</label>`.
- `[role="tablist"]` exists with three `[role="tab"]` children; `aria-selected="true"` tracks the active view (markup arrives via sub-53; this spec verifies it survives view changes).
- After pressing `v`, focus lands on the first `<h2>`/`<h3>` of the new view (use `page.evaluate_script('document.activeElement.tagName')`).
- `aria-live` region is `polite`, not `assertive`.

---

## 3. Implementation steps

Each step lists Explanation, Before, After, and the locking test that drives it.

### Step 1 — CSS additions

**Explanation.** Filter-hiding classes, per-module match-count badge, heat-map query-hit outline, empty-state banner. Pure CSS, no behaviour.

**Before** — nothing in `/Users/louisraymond/projects/test_generator/app/assets/stylesheets/topic.css` for these.

**After** — append:

```css
/* sub-56: search filter classes */
.topic-detail__lo--filtered { display: none; }
.topic-detail__cat--filtered { display: none; }

.topic-detail__module-card__match-count {
  font-family: var(--mono);
  font-size: var(--fs-pill);
  color: var(--accent);
  margin-left: 0.5rem;
}

.topic-detail__module-card__match-count[data-state="zero"]::before {
  content: "○ ";
  color: var(--accent);
}

/* sub-56 + sub-54 interaction: query hit on heat-map cells */
.topic-detail__heat-cell--query-hit {
  outline: 1px solid var(--accent);
  outline-offset: 1px;
}

/* sub-56: empty state banner */
.topic-detail__search-empty {
  padding: 1rem 1.25rem;
  border: 1px solid var(--rule);
  background: var(--card);
  font-family: var(--serif);
  margin-bottom: 1rem;
}

/* sub-56: visually-hidden label */
.topic-detail__visually-hidden {
  position: absolute;
  width: 1px; height: 1px;
  padding: 0; margin: -1px;
  overflow: hidden; clip: rect(0,0,0,0);
  white-space: nowrap; border: 0;
}
```

**Locking test.** *Live filter, outcome match.* Without `display:none` the spec fails on the `not_to be_visible` assertion against filtered rows.

---

### Step 2 — `topic_search_controller.js`

**Explanation.** Owns query state and DOM filter pass. Mounts on the page wrapper alongside `topic-detail`, `module-focus`, `topic-view`. Reads `[data-lo-text]`, `[data-cat-name]`, `[data-mod-name]` from sub-55. Stores the normalised query in a Stimulus value so the view controller can re-trigger the pass after re-render.

**Before.** No file at `/Users/louisraymond/projects/test_generator/app/javascript/controllers/topic_search_controller.js`.

**After** — full file:

```javascript
import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_MS = 80
const FILTERED_LO = "topic-detail__lo--filtered"
const FILTERED_CAT = "topic-detail__cat--filtered"
const HEAT_HIT = "topic-detail__heat-cell--query-hit"

export default class extends Controller {
  static targets = ["input", "liveRegion", "emptyState", "matchCount"]
  static values = { query: { type: String, default: "" } }

  connect() {
    this.timer = null
    this.queryValueChanged = this.queryValueChanged.bind(this)
    if (this.queryValue.length > 0) this.applyFilter()
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  filter() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => this.commit(this.inputTarget.value), DEBOUNCE_MS)
  }

  clear() {
    this.inputTarget.value = ""
    this.commit("")
    this.announce("search cleared")
  }

  // Called by the view controller after a view switch.
  reapply() {
    this.applyFilter()
  }

  commit(raw) {
    const normalised = raw.trim().replace(/\s+/g, " ")
    this.queryValue = normalised
    this.applyFilter()
  }

  applyFilter() {
    performance.mark("topic-search:filter:start")

    const q = this.queryValue.toLowerCase()
    const root = this.element

    // Clear previous outline state on heat-map cells.
    root.querySelectorAll(`.${HEAT_HIT}`).forEach((el) => el.classList.remove(HEAT_HIT))

    if (q.length === 0) {
      this.restoreAllVisible()
      this.announce("")
      this.toggleEmptyState(false)
      this.dispatch("filtered", { detail: { count: null } })
      performance.mark("topic-search:filter:end")
      performance.measure("topic-search:filter", "topic-search:filter:start", "topic-search:filter:end")
      return
    }

    // Per-module counter.
    const modules = root.querySelectorAll("[data-mod-name]")
    let totalMatches = 0

    modules.forEach((modEl) => {
      const modMatch = modEl.dataset.modName?.toLowerCase().includes(q)
      const cats = modEl.querySelectorAll("[data-cat-name]")
      let modCount = 0

      cats.forEach((catEl) => {
        const catMatch = modMatch || catEl.dataset.catName?.toLowerCase().includes(q)
        const los = catEl.querySelectorAll("[data-lo-text]")
        let catCount = 0

        los.forEach((loEl) => {
          const loMatch = catMatch || loEl.dataset.loText?.toLowerCase().includes(q)
          loEl.classList.toggle(FILTERED_LO, !loMatch)
          if (loMatch) {
            catCount += 1
            const heatCell = root.querySelector(`[data-heat-lo-id="${loEl.dataset.loId}"]`)
            if (heatCell) heatCell.classList.add(HEAT_HIT)
          }
        })

        catEl.classList.toggle(FILTERED_CAT, catCount === 0)
        modCount += catCount
      })

      this.paintMatchCount(modEl, modCount)
      totalMatches += modCount
    })

    this.toggleEmptyState(totalMatches === 0)
    this.announce(`${totalMatches} outcomes match`)
    this.dispatch("filtered", { detail: { count: totalMatches } })

    performance.mark("topic-search:filter:end")
    performance.measure("topic-search:filter", "topic-search:filter:start", "topic-search:filter:end")
  }

  paintMatchCount(modEl, count) {
    const badge = modEl.querySelector(".topic-detail__module-card__match-count")
    if (!badge) return
    badge.dataset.state = count === 0 ? "zero" : "hit"
    badge.textContent = count === 0 ? "0 matches" : `· ${count} matches`
    if (count === 0) {
      this.collapseModule(modEl)
    } else {
      this.expandModule(modEl)
    }
  }

  collapseModule(modEl) {
    const body = modEl.querySelector(".topic-detail__module-card__body")
    if (body) body.hidden = true
  }

  expandModule(modEl) {
    const body = modEl.querySelector(".topic-detail__module-card__body")
    if (body) body.hidden = false
  }

  restoreAllVisible() {
    const root = this.element
    root.querySelectorAll(`.${FILTERED_LO}`).forEach((el) => el.classList.remove(FILTERED_LO))
    root.querySelectorAll(`.${FILTERED_CAT}`).forEach((el) => el.classList.remove(FILTERED_CAT))
    root.querySelectorAll(".topic-detail__module-card__match-count").forEach((el) => {
      el.textContent = ""
      delete el.dataset.state
    })
    // Hand expand/collapse state back to topic-detail (sub-55 reads localStorage).
    this.dispatch("restore-expansion")
  }

  toggleEmptyState(show) {
    if (!this.hasEmptyStateTarget) return
    this.emptyStateTarget.hidden = !show
    if (show) {
      const slot = this.emptyStateTarget.querySelector("[data-search-empty-query]")
      if (slot) slot.textContent = this.queryValue
    }
  }

  announce(message) {
    if (!this.hasLiveRegionTarget) return
    this.liveRegionTarget.textContent = message
  }
}
```

**Locking tests.** *Live filter, outcome match*; *Module-name match*; *Category-name match*; *Case-insensitive substring*; *Whitespace normalisation*; *aria-live announcement*; *Heat-map cell highlight*.

---

### Step 3 — `topic_view_controller.js`

**Explanation.** Owns active view and outcome sort. Toggles `[hidden]` on three pre-rendered panes, persists (debounced) to localStorage, and triggers `topic-search#reapply` after a view change.

**Before.** No file at `/Users/louisraymond/projects/test_generator/app/javascript/controllers/topic_view_controller.js`.

**After** — full file:

```javascript
import { Controller } from "@hotwired/stimulus"

const VIEWS = ["modules", "categories", "outcomes"]
const SORTS = ["topic_order", "nq_desc", "nq_asc", "alpha"]
const WRITE_DEBOUNCE_MS = 200

export default class extends Controller {
  static targets = ["pane", "tab", "sortSelect"]
  static values = {
    topicId: Number,
    view: { type: String, default: "modules" },
    sort: { type: String, default: "topic_order" }
  }

  connect() {
    this.writeTimer = null
    this.hydrateFromStorage()
    this.render()
  }

  disconnect() {
    if (this.writeTimer) clearTimeout(this.writeTimer)
  }

  hydrateFromStorage() {
    const v = localStorage.getItem(this.viewKey)
    const s = localStorage.getItem(this.sortKey)
    if (VIEWS.includes(v)) this.viewValue = v
    if (SORTS.includes(s)) this.sortValue = s
  }

  get viewKey()  { return `topic-detail:topic-${this.topicIdValue}:view` }
  get sortKey()  { return `topic-detail:topic-${this.topicIdValue}:sort` }

  cycleView() {
    const next = VIEWS[(VIEWS.indexOf(this.viewValue) + 1) % VIEWS.length]
    this.viewValue = next
  }

  selectView(event) {
    const v = event.currentTarget?.dataset?.view
    if (VIEWS.includes(v)) this.viewValue = v
  }

  selectSort(event) {
    const s = event.currentTarget?.value
    if (SORTS.includes(s)) {
      this.sortValue = s
      this.applySort()
    }
  }

  viewValueChanged() {
    this.render()
    this.persist()
    this.focusFirstHeading()
    this.dispatch("changed", { detail: { view: this.viewValue } })
    // Re-apply any live search query against the freshly visible DOM.
    this.dispatchToSearch()
  }

  sortValueChanged() {
    this.applySort()
    this.persist()
  }

  render() {
    this.paneTargets.forEach((pane) => {
      pane.hidden = pane.dataset.view !== this.viewValue
    })
    if (this.hasTabTarget) {
      this.tabTargets.forEach((tab) => {
        const selected = tab.dataset.view === this.viewValue
        tab.setAttribute("aria-selected", selected ? "true" : "false")
      })
    }
  }

  applySort() {
    const pane = this.paneTargets.find((p) => p.dataset.view === "outcomes")
    if (!pane) return
    const list = pane.querySelector("[data-outcomes-flat]")
    if (!list) return

    const rows = Array.from(list.querySelectorAll("[data-outcome-row]"))
    const cmp = this.comparatorFor(this.sortValue)
    rows.sort(cmp).forEach((row) => list.appendChild(row))
    if (this.hasSortSelectTarget) this.sortSelectTarget.value = this.sortValue
  }

  comparatorFor(sort) {
    switch (sort) {
      case "nq_desc": return (a, b) => Number(b.dataset.nq) - Number(a.dataset.nq)
      case "nq_asc":  return (a, b) => Number(a.dataset.nq) - Number(b.dataset.nq)
      case "alpha":   return (a, b) => a.dataset.loText.localeCompare(b.dataset.loText)
      default:        return (a, b) => Number(a.dataset.topicOrder) - Number(b.dataset.topicOrder)
    }
  }

  persist() {
    if (this.writeTimer) clearTimeout(this.writeTimer)
    this.writeTimer = setTimeout(() => {
      localStorage.setItem(this.viewKey, this.viewValue)
      localStorage.setItem(this.sortKey, this.sortValue)
    }, WRITE_DEBOUNCE_MS)
  }

  focusFirstHeading() {
    const pane = this.paneTargets.find((p) => p.dataset.view === this.viewValue)
    if (!pane) return
    const heading = pane.querySelector("h2, h3")
    if (heading) {
      heading.setAttribute("tabindex", "-1")
      heading.focus({ preventScroll: false })
    }
  }

  dispatchToSearch() {
    const search = this.application.getControllerForElementAndIdentifier(this.element, "topic-search")
    if (search && typeof search.reapply === "function") search.reapply()
  }
}
```

**Locking tests.** *View cycling via `v`*; *categories view content*; *outcomes view content*; *View persists*; *Heat-map mode preserved across view change*; *Search query preserved across view change*; a11y *focus moves to first heading*.

---

### Step 4 — View partials

**Explanation.** All three trees rendered server-side, toggled by `[hidden]`. The default `_view_modules.html.erb` is sub-55's structure; the two new partials live beside it.

**Files to create:**

- `/Users/louisraymond/projects/test_generator/app/views/topics/_view_categories.html.erb`
- `/Users/louisraymond/projects/test_generator/app/views/topics/_view_outcomes_flat.html.erb`
- `/Users/louisraymond/projects/test_generator/app/views/topics/_search_empty.html.erb`

**`_view_categories.html.erb`:**

```erb
<section class="topic-detail__view topic-detail__view--categories"
         data-topic-view-target="pane"
         data-view="categories"
         hidden>
  <% topic_outcomes_grouped_by_category(topic).each do |category_name, los_with_module_idx| %>
    <article class="topic-detail__category-section" data-cat-name="<%= category_name %>">
      <h3><%= category_name %>
        <span class="topic-detail__cat-count"><%= pluralize(los_with_module_idx.size, 'outcome') %></span>
      </h3>
      <ul class="topic-detail__category-section__list">
        <% los_with_module_idx.each do |row| %>
          <li class="topic-detail__lo-row"
              data-lo-id="<%= row[:lo].id %>"
              data-lo-text="<%= row[:lo].description %>">
            <span class="topic-detail__m-tag mono">M<%= row[:module_idx].to_s.rjust(2, '0') %></span>
            <span class="topic-detail__nq-chip" data-nq="<%= row[:lo].questions.size %>">
              <%= row[:lo].questions.size %>
            </span>
            <span class="topic-detail__lo-text"><%= row[:lo].description %></span>
            <%= link_to '+ question', new_question_path(learning_objective_id: row[:lo].id),
                        class: 'topic-detail__add-question' %>
          </li>
        <% end %>
      </ul>
    </article>
  <% end %>
</section>
```

**`_view_outcomes_flat.html.erb`:**

```erb
<section class="topic-detail__view topic-detail__view--outcomes"
         data-topic-view-target="pane"
         data-view="outcomes"
         hidden>
  <div class="topic-detail__sort-row">
    <label for="outcomes-sort" class="topic-detail__visually-hidden">Sort outcomes</label>
    <select id="outcomes-sort"
            data-topic-view-target="sortSelect"
            data-action="change->topic-view#selectSort">
      <option value="topic_order">Topic order</option>
      <option value="nq_desc">Nq descending</option>
      <option value="nq_asc">Nq ascending</option>
      <option value="alpha">Alphabetical</option>
    </select>
  </div>

  <ol class="topic-detail__outcomes-flat" data-outcomes-flat>
    <% topic_outcomes_flat(topic, sort: :topic_order).each do |row| %>
      <li class="topic-detail__lo-row"
          data-outcome-row
          data-lo-id="<%= row[:lo].id %>"
          data-lo-text="<%= row[:lo].description %>"
          data-nq="<%= row[:lo].questions.size %>"
          data-topic-order="<%= row[:topic_order] %>">
        <span class="topic-detail__m-tag mono">M<%= row[:module_idx].to_s.rjust(2, '0') %></span>
        <span class="topic-detail__nq-chip"><%= row[:lo].questions.size %></span>
        <span class="topic-detail__lo-text"><%= row[:lo].description %></span>
        <span class="topic-detail__cat-tag mono"><%= row[:lo].category %></span>
        <%= link_to '+ question', new_question_path(learning_objective_id: row[:lo].id),
                    class: 'topic-detail__add-question' %>
      </li>
    <% end %>
  </ol>
</section>
```

**`_search_empty.html.erb`:**

```erb
<div class="topic-detail__search-empty"
     data-topic-search-target="emptyState"
     hidden>
  No outcomes match "<span data-search-empty-query></span>".
  <button type="button"
          class="topic-detail__search-empty__clear"
          data-action="click->topic-search#clear">
    Clear search
  </button>
</div>
```

**Locking tests.** *categories view content*; *outcomes view content*; *Empty state*.

---

### Step 5 — Helpers

**Explanation.** Two pure helpers shape data for the alternative views. The category grouper sorts alphabetically; the flat helper applies the requested sort and tags each row with its source-module index (1-based, matching the `M01` display).

**Before.** `/Users/louisraymond/projects/test_generator/app/helpers/topics_helper.rb` exists but does not define these.

**After** — append:

```ruby
module TopicsHelper
  # Returns [[category_name, [{lo:, module_idx:}, ...]], ...] sorted by category name.
  def topic_outcomes_grouped_by_category(topic)
    module_idx_by_id = topic.topic_modules.each_with_index.to_h { |m, i| [m.id, i + 1] }

    topic.learning_objectives
         .group_by(&:category)
         .sort_by { |cat, _los| cat.to_s.downcase }
         .map do |cat, los|
           rows = los.sort_by { |lo| [lo.category_order.to_i, lo.position.to_i, lo.id] }
                     .map { |lo| { lo: lo, module_idx: module_idx_by_id[lo.topic_module_id] || 0 } }
           [cat, rows]
         end
  end

  # Returns [{lo:, module_idx:, topic_order:}] sorted by `sort:` (:topic_order, :nq_desc, :nq_asc, :alpha).
  def topic_outcomes_flat(topic, sort: :topic_order)
    module_idx_by_id = topic.topic_modules.each_with_index.to_h { |m, i| [m.id, i + 1] }

    base = topic.learning_objectives.each_with_index.map do |lo, i|
      { lo: lo, module_idx: module_idx_by_id[lo.topic_module_id] || 0, topic_order: i }
    end

    case sort
    when :nq_desc then base.sort_by { |r| -r[:lo].questions.size }
    when :nq_asc  then base.sort_by { |r| r[:lo].questions.size }
    when :alpha   then base.sort_by { |r| r[:lo].description.to_s.downcase }
    else               base
    end
  end
end
```

`Topic#learning_objectives`'s default scope orders by `category_order, position, id` (recon §1), so `each_with_index` yields a stable topic-order index.

**Locking tests.** *categories view content*; *outcomes view content*.

---

### Step 6 — Toolbar wiring

**Explanation.** Sub-53 ships the toolbar markup; sub-56 adds the Stimulus actions, the visually-hidden label, and the live region. The page wrapper gains `topic-search` and `topic-view` bindings.

**Before** (toolbar partial from sub-53, schematic):

```erb
<div class="topic-detail__toolbar">
  <input type="search" id="search-outcomes" placeholder="Search outcomes" />
  <div role="tablist" class="topic-detail__view-pills">
    <button role="tab" data-view="modules">Modules</button>
    <button role="tab" data-view="categories">Categories</button>
    <button role="tab" data-view="outcomes">Outcomes</button>
  </div>
</div>
```

**After:**

```erb
<div class="topic-detail__toolbar">
  <label for="search-outcomes" class="topic-detail__visually-hidden">Search outcomes</label>
  <input type="search"
         id="search-outcomes"
         placeholder="Search outcomes"
         data-topic-search-target="input"
         data-action="input->topic-search#filter keydown.esc->topic-search#clear" />

  <div role="tablist" class="topic-detail__view-pills">
    <button role="tab"
            aria-selected="true"
            data-topic-view-target="tab"
            data-view="modules"
            data-action="click->topic-view#selectView">Modules</button>
    <button role="tab"
            aria-selected="false"
            data-topic-view-target="tab"
            data-view="categories"
            data-action="click->topic-view#selectView">Categories</button>
    <button role="tab"
            aria-selected="false"
            data-topic-view-target="tab"
            data-view="outcomes"
            data-action="click->topic-view#selectView">Outcomes</button>
  </div>

  <div class="topic-detail__visually-hidden"
       role="status"
       aria-live="polite"
       data-topic-search-target="liveRegion"></div>
</div>
```

The wrapper at the top of `show.html.erb` becomes:

```erb
<div class="topic-detail premium-page-wrapper"
     data-controller="topic-detail module-focus topic-search topic-view"
     data-topic-detail-topic-id-value="<%= @topic.id %>"
     data-topic-view-topic-id-value="<%= @topic.id %>">
  <%= render 'topics/toolbar', topic: @topic %>
  <%= render 'topics/search_empty' %>
  <%= render 'topics/view_modules',       topic: @topic %>
  <%= render 'topics/view_categories',    topic: @topic %>
  <%= render 'topics/view_outcomes_flat', topic: @topic %>
</div>
```

**Locking tests.** *Esc clears*; a11y *visually-hidden label*; a11y *aria-live polite*.

---

### Step 7 — Empty state

Created in Step 4. Locking test: *Empty state*. The `Clear search` button uses `data-action="click->topic-search#clear"`; append `this.inputTarget.focus()` to the end of `clear()` so focus returns to the input after the click.

---

## 4. Antagonist review

### Persona A — Skeptic Engineer

**A1 — pre-render vs Turbo Frame.** "Three views = three trees. With 28 outcomes that's ~84 outcome nodes. Tolerable now, but architect for 200." **ACCEPTED.** Pre-render and toggle via `[hidden]` for now (cheap, no network, search-state continuity is free). Document the threshold: above ~150 outcomes per topic, migrate alternative views to `<turbo-frame>` lazy loaders. Risk in §6.

**A2 — where does the query live across view changes?** "The previous DOM-class state is irrelevant once the new pane mounts." **ACCEPTED.** Controller stores the normalised query in `queryValue` and exposes `reapply()`. `topic_view_controller#viewValueChanged` dispatches into `dispatchToSearch()`, which calls `reapply()`; the DOM walker re-runs against the now-visible pane.

**A3 — why not server-side search?** "A `GET /topics/:id?q=...` Turbo Frame would be trivially correct." **REJECTED.** 28 outcomes is ~0.5–1.5ms client-side; network latency is 30–80ms even local. Per-keystroke server search adds visible lag, and we lose the heat-map outline interaction (sub-54 state is client-only). Re-evaluate above 200 outcomes.

### Persona B — A11y Reviewer

**B1 — politeness.** "`polite`, not `assertive`." **ACCEPTED.** Wrapper uses `aria-live="polite" role="status"`.

**B2 — tab focus management.** "Tab from the input must land somewhere sensible per view." **ACCEPTED.** `focusFirstHeading` runs after every view change. The `outcomes` pane places its `h2`/`h3` above the sort `<select>`, so one further Tab lands in the dropdown.

**B3 — native `<select>`, not a custom popup.** **ACCEPTED.** `<select id="outcomes-sort">` with `change->topic-view#selectSort`.

**B4 — "0 matches" must not depend on colour alone.** **ACCEPTED.** The `[data-state="zero"]::before { content: "○ "; }` glyph plus the literal text `0 matches` carry the meaning verbally and visually.

### Persona C — Performance Reviewer

**C1 — < 4ms gating.** "Wall-clock thresholds in CI are flaky." **ACCEPTED.** CI asserts `< 25ms` (order-of-magnitude guard). The < 4ms reading is recorded manually in `docs/plans/topic-detail-v2/PERF.md`. `performance.measure` wraps every filter pass.

**C2 — declare the pre-render threshold publicly.** **ACCEPTED.** §6 records `> 150 outcomes per topic → migrate to Turbo Frames`.

**C3 — debounce localStorage writes.** **ACCEPTED.** `WRITE_DEBOUNCE_MS = 200`. Forward-looking insurance; today the write fires only on view-cycle and sort-change.

---

## 5. Open questions

1. **Heat-map cell selector.** Plan assumes `[data-heat-lo-id="<lo.id>"]`. Sub-54 must guarantee it; otherwise update `applyFilter`.
2. **Match-count badge slot.** Sub-55's module card header needs an empty `<span class="topic-detail__module-card__match-count"></span>`. Lock with the sub-55 author up front.
3. **Sort persistence scope.** Sort is `outcomes`-only but persisted unconditionally — acceptable or gate?
4. **`v` shortcut origin.** Sub-6 should call `topic-view#cycleView` via Stimulus action, not direct controller lookup. Confirm.
5. **Diacritic-insensitive search.** Acceptance says substring only; we follow strictly. Flag for future enhancement (`String.prototype.normalize('NFD').replace(/\p{Diacritic}/gu, '')`).

---

## 6. Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| 1 | Pre-rendering all three views inflates DOM beyond ~150 outcomes, hurting layout/scroll perf | Medium (long-term) | Medium | Document the 150-outcome threshold; migrate alternative views to Turbo Frames when crossed |
| 2 | sub-55's `[data-lo-text]` / `[data-cat-name]` / `[data-mod-name]` markup drifts from this plan's selectors | Medium | High | Lock the contract in sub-55's PR description; add an integration spec that asserts the attributes exist on the rendered page |
| 3 | sub-54's heat-map cell selector differs from `[data-heat-lo-id]` | Medium | Low | Single point of change in `applyFilter`; covered by *Heat-map cell highlight* test |
| 4 | Selenium-headless flakiness on the live-region timing assertion (debounce + announce race) | Medium | Medium | Use `have_text` with Capybara's default wait, not `evaluate_script` polling; assert announcement *after* a UI confirmation (filter classes applied) |
| 5 | Focus management on view switch steals focus from a user mid-typing | Low | Medium | Only call `focusFirstHeading` when the change originated from a tab click or `v` shortcut, not from a programmatic re-render — gate via the dispatch detail |
| 6 | localStorage quota or disabled storage breaks `hydrateFromStorage` | Low | Low | Wrap reads in `try/catch`; default to in-memory state if localStorage throws |
| 7 | Performance benchmark drifts above 4ms under JS GC pressure on slower hardware | Low | Low | Soft-gate at 25ms in CI; record real numbers in PERF.md; revisit if real-user measurements show p95 > 8ms |
| 8 | `aria-live="polite"` swallows announcements when the user is typing fast | Low | Low | The 80ms debounce already coalesces keystrokes; one announcement per settled query is the desired behaviour |

---

**End of plan.** Implement steps 1 → 7 in order; each commit should land its locking test green.
