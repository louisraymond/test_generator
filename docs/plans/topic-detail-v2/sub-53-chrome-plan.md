# sub-53 — Topic Detail: page chrome + sidebar — TDD plan

**Issue:** #53
**Parent:** Topic detail v2 redesign
**Blocks:** #54, #55, #56, #57
**Depends on:** #52 (provides the data for the 4th stat card; we expose the slot only)

---

## 1. Goal

Replace the current `/topics/:id` chrome with the paper aesthetic and a sticky 300px left sidebar. This issue is the foundation block: every later sub-issue (#54 module body collapse, #55 view switcher, #56 search, #57 shortcuts overlay) bolts onto the partials, CSS grid and Stimulus targets introduced here.

**What changes visually:**
- Body background flips to `var(--paper)`, gradients gone.
- Page becomes a CSS grid: `300px 1fr` with a single 1px rule between columns.
- New sticky sidebar with topic eyebrow, name, epigraph, module list (with mini-stats), view switcher.
- New right-pane toolbar (search input, +Outcome, +Module, ?).
- New stat strip of 4 cards (Modules · Categories · Outcomes · Questions/Exam-uses).
- Footer hint `press ? for keyboard shortcuts`.

**What does NOT change:**
- The Stimulus form flows in `topic_detail_controller.js` (add LO, add module, add category) keep working unchanged — markup IDs, data-actions and target names are preserved.
- The API endpoints `POST /api/topics/:id/learning_objectives` and `POST /api/topics/:id/topic_modules` are not touched.
- The preloading chain in `TopicsController#set_topic` stays as-is.
- The category cards on the right pane keep rendering exactly as they do today (sub-54 changes those).

The work is gated behind a `topic_detail_v2` feature flag so master is shippable while #54-#57 land.

---

## 2. TDD test list

### System specs (Capybara + selenium_chrome_headless, `js: true`)

Driver upgrade is needed because the sidebar uses `position: sticky`, smooth scroll, and IntersectionObserver — none of which rack_test executes.

1. `spec/system/topics/v2_chrome_spec.rb` — `default visit shows sidebar with topic name, epigraph and module entries`
   - `create(:topic, :with_modules, name: 'Thermal Physics', epigraph_quote: '"truth..."', epigraph_attribution: 'Kelvin')`, plus 4 modules each with 2 LOs and 3 questions.
   - Visit `topic_path(topic)` with the v2 flag on.
   - Assert sidebar `<nav aria-label="Topic outline">` is present.
   - Assert each module has its 2-digit index, name in Fraunces, and a ministats line containing `cat ·`, `LO ·`, `Q`.
2. `empty topic shows MODULES · 0 and a +NEW MODULE CTA`
   - `create(:topic)` with no modules.
   - Assert sidebar has `MODULES · 0` and a button with text `+ NEW MODULE`.
3. `clicking a sidebar module entry sets it active and scrolls main pane to #mod-{id}`
   - 4 modules. Click the 3rd entry. Assert `aria-current="location"` on its `<a>`. Assert `page.evaluate_script("document.getElementById('mod-#{m3.id}').getBoundingClientRect().top")` is within `[-2, 4]` (top of viewport ±a couple of px).
4. `IntersectionObserver: scrolling main pane updates active sidebar entry`
   - Scroll the main pane to module 4. Assert `aria-current="location"` migrates from m3's link to m4's link within a 500ms wait window.
5. `stat strip shows 4 cards with the correct numbers`
   - Assert four `.topic-detail__stat-card` elements; first three contain integer counts matching `topic.topic_modules.count`, distinct categories count, and outcomes count. Fourth has `data-stat-target="usage"` and renders the question count by default.
6. `toolbar contains search, +Outcome, +Module, ?`
   - Assert `input[placeholder='Search outcomes, categories, modules…']`.
   - Assert `button[type='button']` with text `+ Outcome`, another with `+ Module`, and a `?` circle button.
7. `footer hint visible`
   - Assert `.topic-detail__footer-hint` contains `press ? for keyboard shortcuts`.

### View specs (no JS, no DB roundtrips beyond factories)

1. `spec/views/topics/_topic_sidebar.html.erb_spec.rb` — renders module list correctly given a topic with 4 modules; renders empty state for 0 modules; renders epigraph block only when `epigraph_quote.present?`.
2. `spec/views/topics/_stat_strip.html.erb_spec.rb` — renders 4 cards; the 4th card uses `@exam_usage.values.sum` when the heatmap mode is `utilization` and `@topic.questions.count` otherwise (the ivar is provided by sub-3; we render an `if @exam_usage.present?` branch).
3. `spec/views/topics/_topic_toolbar.html.erb_spec.rb` — renders the four controls; each button has `type="button"`.

### Helper specs

1. `spec/helpers/topic_detail_helper_spec.rb`
   - `module_ministats(mod)` returns `"3 cat · 7 LO · 32 Q"` for a module with 3 categories, 7 LOs and 32 questions.
   - Edge case: 0 categories yields `"0 cat · 0 LO · 0 Q"` — never `nil`.
   - `module_index_label(idx)` returns `"01"`, `"09"`, `"10"`, `"99"` and `"100"` (no zero-pad past 2 digits).
   - `topic_stat(label:, value:, mode: nil)` returns a hash the partial can splat into HTML attributes; `mode: :usage` adds `data: { stat_target: 'usage' }`.

### A11y specs

We assert ARIA attributes manually for v1 to avoid pulling in a new gem (see §3 for the rationale).

1. `spec/system/topics/v2_chrome_a11y_spec.rb` (`js: true`)
   - `<nav aria-label="Topic outline">` wraps the module list.
   - The skip link `<a class="topic-detail__skip-link" href="#topic-detail-main">Skip to main content</a>` is the first focusable element on the page (Tab once from `body` lands on it).
   - All buttons in the toolbar are `<button type="button">` (no `<a>` masquerading as a button, no `<div onclick>`).
   - The active sidebar entry has `aria-current="location"`.
   - Module list is `<ul><li><a href="#mod-{id}">…` — no nested `<div>` wrappers swapping out the list semantics.
   - No inline `style="outline:none"` anywhere on focusable elements (regex scan of `page.html`).

---

## 3. Driver / dependency changes

**`Gemfile`:**
- `selenium-webdriver` is already pulled in transitively by `capybara`, but pin it explicitly: `gem "selenium-webdriver", "~> 4.18"` in the `:test` group. Confirm before adding (recon notes Capybara is in use; `bundle info selenium-webdriver` will tell us).
- Skip `capybara-screenshot` for v1 — `spec/support/capybara_screenshot_diff.rb` already exists; we don't need a second screenshot gem.
- Skip `axe-core-rspec` for v1. The a11y assertions we need (aria-current, button types, nav landmark, skip link) are simple selector checks. Adding axe means new gem, new CI cost, new false-positive triage. Defer until #57.

**`spec/rails_helper.rb` diff:**

```ruby
# At the top, after `require 'capybara/rspec'`:
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1440,900')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 4
```

Inside the `RSpec.configure` block:

```ruby
config.before(:each, type: :system) do
  driven_by :rack_test
end

config.before(:each, type: :system, js: true) do
  driven_by :selenium_chrome_headless
end
```

This keeps the existing rack_test-default behaviour for non-JS specs (cheap, fast) and opts new specs into headless Chrome via `js: true`. No global slowdown.

**Window size matters:** at the default 1024×768 the responsive breakpoint at 1280px isn't exercised; we set `--window-size=1440,900` so the 300px sidebar layout is hit.

---

## 4. Implementation steps

Each step lists explanation, before, after and the locking test.

### Step 1 — Add Capybara JS driver config

**Explanation:** Without this, every system spec that touches sticky positioning, smooth scroll or IntersectionObserver silently passes (because rack_test renders no CSS and runs no JS). The driver block must land first so the rest of the work is testable.

**Before** (`spec/rails_helper.rb`, end of `RSpec.configure`):
```ruby
config.fixture_paths = [Rails.root.join('spec/fixtures')]
config.use_transactional_fixtures = true
config.infer_spec_type_from_file_location!
config.include FactoryBot::Syntax::Methods
```

**After:**
```ruby
config.fixture_paths = [Rails.root.join('spec/fixtures')]
config.use_transactional_fixtures = true
config.infer_spec_type_from_file_location!
config.include FactoryBot::Syntax::Methods

config.before(:each, type: :system) { driven_by :rack_test }
config.before(:each, type: :system, js: true) { driven_by :selenium_chrome_headless }
```

Plus the `Capybara.register_driver` block at file-top scope.

**Locking test:** A throwaway spec `spec/system/system_spec_smoke_spec.rb` with `js: true` that visits `/` and asserts `page.evaluate_script('1+1') == 2`. It fails until the driver is registered.

### Step 2 — Carve `show.html.erb` into partials

**Explanation:** The current 268-line view conflates chrome (back link, header, modules grid) with content (categories, LO items, forms). Sub-54-#57 will all need to inject markup into specific zones. Splitting now is a one-time cost; not splitting means every later issue edits the same monolith and merge-conflicts itself.

**Before:** Single `app/views/topics/show.html.erb` (268 lines) wrapping everything in `.topic-detail.premium-page-wrapper` with `data-controller="topic-detail module-focus"`.

**After:** `app/views/topics/show.html.erb` becomes a thin orchestrator behind the `topic_detail_v2?` flag:

```erb
<% if Flipper.enabled?(:topic_detail_v2, current_user) %>
  <a class="topic-detail__skip-link" href="#topic-detail-main">Skip to main content</a>
  <div class="topic-detail-v2 premium-page-wrapper"
       data-controller="topic-detail module-focus topic-sidebar"
       data-topic-detail-topic-id-value="<%= @topic.id %>"
       data-topic-sidebar-topic-id-value="<%= @topic.id %>">
    <%= render 'topic_sidebar', topic: @topic %>
    <main id="topic-detail-main" class="topic-detail-v2__main" tabindex="-1">
      <%= render 'topic_toolbar', topic: @topic %>
      <%= render 'stat_strip', topic: @topic, exam_usage: @exam_usage %>
      <%= render 'topic_main', topic: @topic %>
    </main>
    <footer class="topic-detail__footer-hint">press ? for keyboard shortcuts</footer>
  </div>
<% else %>
  <%= render 'show_legacy', topic: @topic %>
<% end %>
```

The legacy path renders `_show_legacy.html.erb` (the old 268-line markup, copied verbatim) so existing form Stimulus targets keep working.

**New partials:**
- `app/views/topics/_topic_sidebar.html.erb`
- `app/views/topics/_topic_toolbar.html.erb`
- `app/views/topics/_stat_strip.html.erb`
- `app/views/topics/_topic_main.html.erb` — wraps the existing categories-list block (still rendering `category-card`, `lo-item`, etc., so `topic_detail_controller.js` keeps attaching).
- `app/views/topics/_show_legacy.html.erb` — the existing markup, untouched.

**Locking test:** Existing topic-detail form specs (the ones already in the repo) still pass under the legacy flag-off path — they exercise `topic_detail_controller`. New view specs from §2 cover the v2 partials.

### Step 3 — Sidebar partial

**Explanation:** Semantic, focusable, screen-reader friendly. Markup ships now; sub-55 wires the view-switcher pill cycling, but the DOM hooks (`data-action="click->topic-sidebar#cycleView"`, `data-topic-sidebar-target="viewPill"`) live here so sub-55 doesn't have to amend HTML.

**Markup skeleton** (`_topic_sidebar.html.erb`):

```erb
<aside class="topic-detail-v2__sidebar">
  <div class="topic-detail__sidebar-eyebrow"><%= "Topic #{topic.id}" %></div>
  <h1 class="topic-detail__sidebar-title"><%= topic.name %></h1>

  <% if topic.epigraph_quote.present? %>
    <blockquote class="topic-detail__sidebar-epigraph">
      <p><%= topic.epigraph_quote %></p>
      <% if topic.epigraph_attribution.present? %>
        <cite>— <%= topic.epigraph_attribution %></cite>
      <% end %>
    </blockquote>
  <% end %>

  <div class="topic-detail__sidebar-modules-header">
    <span>MODULES · <%= topic.topic_modules.size %></span>
    <button type="button" class="topic-detail__sidebar-new"
            data-action="click->topic-detail#startAddModule">+ NEW</button>
  </div>

  <nav aria-label="Topic outline">
    <% if topic.topic_modules.any? %>
      <ul class="topic-detail__sidebar-list">
        <% topic.topic_modules.each_with_index do |mod, i| %>
          <li>
            <a href="#mod-<%= mod.id %>"
               class="topic-detail__sidebar-entry"
               data-topic-sidebar-target="entry"
               data-module-id="<%= mod.id %>"
               data-action="click->topic-sidebar#activate">
              <span class="topic-detail__sidebar-index"><%= module_index_label(i + 1) %></span>
              <span class="topic-detail__sidebar-body">
                <span class="topic-detail__sidebar-name"><%= mod.name %></span>
                <span class="topic-detail__sidebar-ministats"><%= module_ministats(mod) %></span>
              </span>
            </a>
          </li>
        <% end %>
      </ul>
    <% else %>
      <button type="button" class="topic-detail__sidebar-empty-cta"
              data-action="click->topic-detail#startAddModule">+ NEW MODULE</button>
    <% end %>
  </nav>

  <div class="topic-detail__sidebar-switcher" data-topic-sidebar-target="switcher">
    <span class="topic-detail__sidebar-caption">VIEW · v TO CYCLE</span>
    <div class="topic-detail__sidebar-pills">
      <button type="button" class="topic-detail__sidebar-pill is-active"
              data-topic-sidebar-target="viewPill" data-view="modules">Modules</button>
      <button type="button" class="topic-detail__sidebar-pill"
              data-topic-sidebar-target="viewPill" data-view="by_category">By category</button>
      <button type="button" class="topic-detail__sidebar-pill"
              data-topic-sidebar-target="viewPill" data-view="outcomes_only">Outcomes only</button>
    </div>
  </div>
</aside>
```

**Locking test:** Sidebar view spec from §2.

### Step 4 — Toolbar partial

**Explanation:** Real `<button type="button">` for every control; the search input is a real `<input type="search">` so screen readers announce it correctly. The `/` keycap is a decorative `<kbd>` — sub-56 wires the actual shortcut.

**`_topic_toolbar.html.erb`:**
```erb
<div class="topic-detail__toolbar">
  <label class="topic-detail__search">
    <span class="visually-hidden">Search</span>
    <%= inline_svg_tag 'icons/magnifier.svg', class: 'topic-detail__search-icon' %>
    <input type="search" placeholder="Search outcomes, categories, modules…"
           data-topic-detail-target="searchInput" />
    <kbd class="topic-detail__search-keycap">/</kbd>
  </label>
  <button type="button" class="topic-detail__btn topic-detail__btn--ghost"
          data-action="click->topic-detail#startAddCategory">+ Outcome</button>
  <button type="button" class="topic-detail__btn topic-detail__btn--filled"
          data-action="click->topic-detail#startAddModule">+ Module</button>
  <button type="button" class="topic-detail__btn-help" aria-label="Keyboard shortcuts"
          data-action="click->topic-detail#openShortcuts">?</button>
</div>
```

If `inline_svg_tag` isn't present, fall back to inline SVG markup — confirm with a quick `bundle info inline_svg`.

**Locking test:** Toolbar view spec.

### Step 5 — Stat strip partial + helper

**Explanation:** The 4th card has to flip between Questions and Exam-uses (sub-3 owns the swap). We expose a `data-stat-target="usage"` slot and render the default Questions value; sub-3 mutates it without re-rendering.

**`_stat_strip.html.erb`:**
```erb
<div class="topic-detail__stat-strip">
  <%= render 'stat_card', **topic_stat(label: 'MODULES', value: topic.topic_modules.size) %>
  <%= render 'stat_card', **topic_stat(label: 'CATEGORIES', value: topic.learning_objectives.distinct.count(:category)) %>
  <%= render 'stat_card', **topic_stat(label: 'OUTCOMES', value: topic.learning_objectives.size) %>
  <% if exam_usage.present? %>
    <%= render 'stat_card', **topic_stat(label: 'EXAM USES', value: exam_usage.values.sum, mode: :usage) %>
  <% else %>
    <%= render 'stat_card', **topic_stat(label: 'QUESTIONS', value: topic.questions.size, mode: :usage) %>
  <% end %>
</div>
```

The `topic_stat(label:, value:, mode: nil)` helper returns `{ label:, value:, html_data: { stat_target: ('usage' if mode == :usage) }.compact }` so `_stat_card.html.erb` can render uniformly.

**Locking test:** Stat-strip view spec.

### Step 6 — CSS additions to `topic.css`

**Explanation:** Append, don't replace. The existing `topic-detail__*` classes power the legacy view; we add v2 classes alongside. One file means cache invalidation on a single asset.

Append to `app/assets/stylesheets/topic.css`:

```css
/* === V2 chrome === */
.topic-detail-v2 { display: grid; grid-template-columns: 300px 1fr; min-height: 100vh;
                   background: var(--paper); color: var(--ink); }
.topic-detail-v2__sidebar { position: sticky; top: 0; height: 100vh; overflow-y: auto;
                            border-right: 1px solid var(--rule); padding: 24px 20px 0;
                            display: flex; flex-direction: column; }
.topic-detail-v2__main { padding: 24px 32px; min-width: 0; }

.topic-detail__sidebar-eyebrow { font-family: var(--mono); font-size: 11px;
                                 letter-spacing: 0.16em; color: var(--accent); text-transform: uppercase; }
.topic-detail__sidebar-title { font-family: var(--serif); font-weight: 400; font-size: 28px;
                               line-height: 1.1; margin: 8px 0 16px; }
.topic-detail__sidebar-epigraph { font-family: var(--serif); font-style: italic; font-size: 14px;
                                  margin: 0 0 24px; }
.topic-detail__sidebar-epigraph cite { display: block; font-family: var(--mono); font-style: normal;
                                       font-size: 11px; color: var(--ink-3); margin-top: 6px; }
.topic-detail__sidebar-modules-header { display: flex; justify-content: space-between;
                                        font-family: var(--mono); font-size: 11px;
                                        letter-spacing: 0.16em; color: var(--ink-3); margin-bottom: 12px; }
.topic-detail__sidebar-list { list-style: none; padding: 0; margin: 0; flex: 1; }
.topic-detail__sidebar-entry { display: grid; grid-template-columns: 24px 1fr; gap: 12px;
                               padding: 10px 12px; text-decoration: none; color: var(--ink);
                               border-left: 3px solid transparent; }
.topic-detail__sidebar-entry[aria-current="location"] {
  border-left-color: var(--accent); background: var(--card); padding-left: 24px;
}
.topic-detail__sidebar-index { font-family: var(--mono); color: var(--accent); font-size: 12px; }
.topic-detail__sidebar-name { font-family: var(--serif); font-size: 16px; }
.topic-detail__sidebar-ministats { display: block; font-family: var(--mono); font-size: 10px;
                                   color: var(--ink-3); margin-top: 2px; }

.topic-detail__sidebar-switcher { position: sticky; bottom: 0; background: var(--paper);
                                  padding: 16px 0; border-top: 1px solid var(--rule); }
.topic-detail__sidebar-pills { display: flex; gap: 6px; margin-top: 8px; }
.topic-detail__sidebar-pill { font-family: var(--mono); font-size: 10px; letter-spacing: 0.12em;
                              padding: 6px 10px; border: 1px solid var(--rule); background: transparent;
                              text-transform: uppercase; }
.topic-detail__sidebar-pill.is-active { background: var(--ink); color: white; border-color: var(--ink); }

.topic-detail__toolbar { display: flex; gap: 12px; align-items: center;
                         border-bottom: 1px solid var(--rule); padding-bottom: 12px; margin-bottom: 24px; }
.topic-detail__search { flex: 1; display: flex; align-items: center; gap: 8px;
                        padding: 8px 12px; border: 1px solid var(--rule); border-radius: 6px;
                        background: var(--card); }

.topic-detail__stat-strip { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;
                            margin-bottom: 32px; }
.topic-detail__stat-card { background: var(--card); border: 1px solid var(--rule);
                           border-radius: 6px; padding: 18px 20px; }
.topic-detail__stat-card__label { font-family: var(--mono); font-size: 10px;
                                  letter-spacing: 0.16em; text-transform: uppercase; color: var(--ink-3); }
.topic-detail__stat-card__value { font-family: var(--serif); font-size: 28px; line-height: 1; }

.topic-detail__skip-link { position: absolute; left: -9999px; }
.topic-detail__skip-link:focus { left: 16px; top: 16px; background: var(--ink); color: white;
                                 padding: 8px 12px; z-index: 1000; }

.topic-detail__footer-hint { text-align: center; font-family: var(--mono); font-size: 10px;
                             color: var(--ink-4); padding: 16px 0; }

*:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }

/* Responsive */
@media (max-width: 1279px) and (min-width: 960px) {
  .topic-detail-v2 { grid-template-columns: 56px 1fr; }
  .topic-detail__sidebar-body, .topic-detail__sidebar-title,
  .topic-detail__sidebar-epigraph, .topic-detail__sidebar-modules-header span:first-child {
    display: none;
  }
  .topic-detail-v2__sidebar:hover { width: 300px; position: fixed; z-index: 50;
                                    box-shadow: 4px 0 12px rgba(0,0,0,0.08); }
  .topic-detail-v2__sidebar:hover .topic-detail__sidebar-body { display: inline; }
}
@media (max-width: 959px) {
  .topic-detail-v2 { grid-template-columns: 1fr; }
  .topic-detail-v2__sidebar { position: fixed; transform: translateX(-100%); transition: transform 200ms; }
  .topic-detail-v2__sidebar[data-open="true"] { transform: translateX(0); }
}
```

**Locking test:** System spec asserting that, at 1440×900, `document.querySelector('.topic-detail-v2__sidebar').getBoundingClientRect().width` is between 290 and 310.

### Step 7 — New `topic_sidebar_controller.js`

**Explanation:** Single-responsibility — this controller knows about scroll-spy and active state and nothing else. The existing `topic_detail_controller.js` knows about forms and CRUD. Mixing them creates a 600-line god controller.

`app/javascript/controllers/topic_sidebar_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entry", "viewPill", "switcher"]
  static values = { topicId: Number }

  connect() {
    this.observer = new IntersectionObserver(this.onIntersect.bind(this), {
      root: null, rootMargin: "-30% 0px -60% 0px", threshold: 0
    })
    document.querySelectorAll("[id^='mod-']").forEach(el => this.observer.observe(el))
  }

  disconnect() { this.observer?.disconnect() }

  activate(event) {
    event.preventDefault()
    const link = event.currentTarget
    const id = link.dataset.moduleId
    const target = document.getElementById(`mod-${id}`)
    if (!target) return
    this.setActive(link)
    target.scrollIntoView({ behavior: "smooth", block: "start" })
    target.querySelector("h2,h3")?.focus({ preventScroll: true })
  }

  onIntersect(entries) {
    const visible = entries.filter(e => e.isIntersecting)
                          .sort((a, b) => a.target.offsetTop - b.target.offsetTop)[0]
    if (!visible) return
    const id = visible.target.id.replace("mod-", "")
    const link = this.entryTargets.find(e => e.dataset.moduleId === id)
    if (link) this.setActive(link)
  }

  setActive(link) {
    this.entryTargets.forEach(e => e.removeAttribute("aria-current"))
    link.setAttribute("aria-current", "location")
  }
}
```

The Stimulus eager-loader auto-registers it.

**Locking test:** System spec 3 and 4 from §2.

### Step 8 — `TopicDetailHelper`

**Explanation:** Push string formatting out of templates so it can be unit-tested without ActionView. Keeps the partial readable.

`app/helpers/topic_detail_helper.rb`:

```ruby
module TopicDetailHelper
  def module_ministats(mod)
    cats = mod.learning_objectives.pluck(:category).compact.uniq.size
    los  = mod.learning_objectives.size
    qs   = mod.questions.size
    "#{cats} cat · #{los} LO · #{qs} Q"
  end

  def module_index_label(idx)
    idx < 100 ? format("%02d", idx) : idx.to_s
  end

  def topic_stat(label:, value:, mode: nil)
    { label: label, value: value, html_data: ({ stat_target: 'usage' } if mode == :usage) || {} }
  end
end
```

**Locking test:** Helper spec from §2.

### Step 9 — Feature flag gating

**Explanation:** Behind a flag means we ship the partials and CSS without breaking the legacy path. `Flipper` is the assumed flag library; if the repo uses something else (`Flipflop`, env-var) the call site adapts but the structure stays.

**Controller change** — `app/controllers/topics_controller.rb`:

```ruby
def show
  @topic_detail_v2 = Flipper.enabled?(:topic_detail_v2, current_user)
end
```

**View change** — already shown in §step 2 (`if Flipper.enabled?(:topic_detail_v2, current_user)`).

**Rollout:** enable for the dev user only until #54-#57 land, then graduate.

**Locking test:** A request spec that toggles the flag and asserts the new wrapper class `topic-detail-v2` is present (flag on) or absent (flag off).

---

## 5. Antagonist review

### Persona A — Skeptic Engineer

> "Why split the view into partials now? You're adding 5 files and indirection."

**ACCEPTED with caveat.** The partials aren't gold-plating; they're load-bearing for #54-#57. #54 will rewrite the body of `_topic_main.html.erb`. #55 swaps the sidebar list rendering. #56 attaches to the toolbar. If we leave the view monolithic, every later issue rewrites the same 268-line file and we get nasty merge conflicts. **Change:** keep the partial split, but add a one-line comment at the top of `show.html.erb` noting which sub-issue owns each partial.

> "IntersectionObserver compat?"

**REJECTED.** Chrome 51+, Safari 12.1+, Edge 15+, Firefox 55+ — all supported. The app already requires modern browsers (Hotwired stack uses ES modules and Stimulus 3). No polyfill needed.

> "Sticky positioning conflict with the existing `.topic-detail__back` row?"

**ACCEPTED.** The legacy back row uses `position: sticky; top: 0`. In the v2 layout we don't render `.topic-detail__back` (the sidebar replaces back-navigation via the topic eyebrow + global app nav). **Change:** confirm via inspection that the v2 path doesn't render `_topic_back.html.erb` or equivalent; if it does, remove from the v2 path only (legacy keeps it).

> "Why a new Stimulus controller vs extending `topic_detail_controller`?"

**ACCEPTED.** Single-responsibility wins here. `topic_detail_controller.js` is 406 lines of form/CRUD logic. Bolting scroll-spy, IntersectionObserver and view-switching onto it pushes it past 600 lines and tangles unrelated concerns. **Change:** keep `topic_sidebar_controller.js` separate. Future split candidate: extract the form code into `topic_forms_controller.js` once #54 lands.

### Persona B — A11y Reviewer

> "How does a screen reader know which sidebar entry is current?"

**ACCEPTED.** Already in the plan: `aria-current="location"` on the active `<a>`. Confirmed in §step 7 and §a11y spec.

> "Sticky 100vh sidebar — keyboard users tab through a viewport-tall block before reaching content."

**ACCEPTED.** Plan adds `<a class="topic-detail__skip-link" href="#topic-detail-main">Skip to main content</a>` as the first focusable element, visible on focus, hidden otherwise. The `<main id="topic-detail-main" tabindex="-1">` accepts programmatic focus.

> "Mono uppercase labels at 11px — accessibility?"

**ACCEPTED with rationale.** WCAG doesn't ban small text, but 11px uppercase mono with 0.16em tracking sits at the floor of comfortable reading. The labels are decorative eyebrows, not the only signal — every label sits beside a Fraunces value or a real heading. **Change:** none, but document the rationale in the design tokens file.

> "Where does focus go when a user clicks a sidebar link?"

**ACCEPTED.** `topic_sidebar_controller#activate` calls `target.querySelector("h2,h3")?.focus({ preventScroll: true })` so focus lands on the destination module heading. Module headings will need `tabindex="-1"` so they accept focus — add to the v2 `_topic_main.html.erb`.

### Persona C — Performance Reviewer

> "Adding 4 partials = 4 partial-render lookups."

**REJECTED.** Rails caches partial lookups in production via the `ActionView::PartialRenderer` cache. In test env caching is off but a partial render is sub-millisecond. The render cost of the page is dominated by the SQL preload chain (already optimised in `set_topic`).

> "IntersectionObserver listening on every module — at 50 modules?"

**REJECTED.** It's a single observer with multiple targets, not 50 observers. The browser's compositor handles intersection in C++; the JS callback runs once per intersection event, not per target. 50 modules is fine; 5000 would still be fine.

> "Sticky sidebar repaints on scroll — layout shift?"

**ACCEPTED.** `position: sticky` paints on the same compositor layer once the browser has hoisted it. The risk is if the sidebar's height changes mid-scroll (e.g., the view-switcher appears/disappears). **Change:** the sidebar uses `display: flex; flex-direction: column;` with the switcher set to `position: sticky; bottom: 0;` so its height is fixed at 100vh from first paint. No CLS.

---

## 6. Open questions

1. **Flipper or alternative?** Recon doesn't confirm which feature-flag library is in use. Resolve by `bundle info flipper` before step 9. If absent, gate via `ENV.fetch('TOPIC_DETAIL_V2', 'false') == 'true'` for dev and graduate later.
2. **`current_user` availability in `TopicsController#show`?** If the app uses a different auth helper (`current_account`, `Current.user`), swap the call. Confirm via `grep -r "current_user" app/controllers`.
3. **`@exam_usage` ivar source.** Sub-3 (#52) provides it. For this issue's empty branch we render `topic.questions.size` as the 4th card; sub-3 will introduce the ivar. View spec must handle both paths.
4. **`inline_svg_tag` availability.** Confirm before §step 4; if absent, inline the magnifier SVG directly.
5. **Mobile drawer keyboard activation.** The `<960px` breakpoint uses CSS-only hover for the rail, but on mobile (no hover) we need a tap toggle. The acceptance criteria says "drawer triggered by a `Modules ▾` button" — this is in scope. Plan covers the CSS but the toggle button JS needs a one-method addition to `topic_sidebar_controller.js`. Add to step 7 if confirmed in scope.

---

## 7. Risks

1. **Headless Chrome flakiness in CI.** New driver = new flake surface. Mitigation: pin `selenium-webdriver`, set explicit `--window-size`, raise `Capybara.default_max_wait_time` to 4s, and run the new specs locally three times before merging.
2. **Flag-off path drift.** If the legacy partial extraction (`_show_legacy.html.erb`) silently diverges from the original `show.html.erb` content, regression appears on existing customers. Mitigation: copy the existing `show.html.erb` byte-for-byte into `_show_legacy.html.erb` and don't edit it in this PR.
3. **Sticky bottom switcher swallowing the last module.** If the bottom switcher overlaps the last module list entry, the last entry becomes hard to click. Mitigation: the `<ul>` has `flex: 1` so it expands; the switcher sits below in the flex column rather than overlapping.
4. **Existing `topic_detail_controller` regressing.** It's 406 lines and we're touching the wrapper element. Risk: if we change the `data-controller` value or remove a target it stops attaching. Mitigation: the plan keeps `data-controller="topic-detail module-focus topic-sidebar"` (additive only) and preserves every existing target name in the v2 markup.
5. **CSS specificity wars.** Appending to `topic.css` means the v2 rules sit after the legacy rules. If a v2 selector accidentally collides with a legacy class (e.g., `.module-card`), the cascade resolves in v2's favour and breaks the flag-off path. Mitigation: every v2 rule uses either `.topic-detail-v2__*` or a class only emitted under the flag. CI grep step: assert no rule under the v2 section uses a class also referenced by `_show_legacy.html.erb`.
6. **IntersectionObserver root margin tuning.** `-30% 0px -60% 0px` is a guess; on tall modules the active state may flicker. Resolve by manual QA at three viewport heights (900, 1200, 1600) before sub-54 lands.
