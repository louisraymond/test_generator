# Sub-57 — Topic Detail: keyboard shortcuts + `?` overlay

**Plan type:** TDD implementation plan
**Depends on:** sub-2 (toolbar/sidebar), sub-3 (heat-map), sub-4 (module accordion), sub-5 (view cycler), sub-6 (search)
**Blocks:** none — this is the capstone navigation layer
**Target file:** `/Users/louisraymond/projects/test_generator/app/javascript/controllers/topic_keyboard_controller.js` (new)

---

## 1. Goal

Make `/topics/:id` fully navigable from the keyboard with a vim-flavoured shortcut map (`j`/`k`, `g g`, `1`–`9`, `o`/`c`, `space`, `e`/`n`/`a`/`q`, `v`/`h`, `/`, `?`, `Esc`) so the topic author — the page's primary user — never reaches for the mouse during authoring.

The discoverability surface is the `?` overlay: a modal dialog grouped by intent (Navigation · Modules · Outcomes · Views · Heat-map · Misc). New users find it via a one-shot toast on first visit, persisted in `localStorage` under `topic-detail:keyboard-toast-seen`. Returning users see only the static footer hint placed by sub-2.

This sub-issue **dispatches**, it does not handle. `j`/`k`/`1`–`9`/`space`/`o`/`c`/`v`/`h`/`/` turn into custom events that sub-2 / sub-3 / sub-4 / sub-5 already listen for. The controller's job is the input layer: detect keystrokes, decide eligibility (target is not editable, no modifier other than Shift), emit a semantic event. The overlay, toast, and focus management are the only DOM it owns.

---

## 2. TDD test list

All specs are `type: :system, js: true` using `selenium_chrome_headless`, in `spec/system/topics/keyboard_spec.rb`. Capybara's `rack_test` cannot send window-level keys; selenium can. Global keys are dispatched via `find('body').send_keys(...)` after `page.execute_script("document.body.focus()")` because only the focused element receives keys.

### 2.1 Per-shortcut specs (one row per shortcut, paired with input-focus guard)

```ruby
it 'j advances active module pointer'
it 'j is a no-op when an input is focused'
it 'k reverses active module pointer'
it 'k is a no-op when a textarea is focused'
it '1..4 jump to modules 1-4 (smooth scroll + active state)'   # 4 specs
it '5 is a no-op when only 4 modules exist'

it 'g g within 400ms scrolls right pane to top' do
  Capybara.using_wait_time(0.5) do
    find('body').send_keys('g'); find('body').send_keys('g')
    expect(page.evaluate_script('document.querySelector(".topic-detail__right").scrollTop')).to eq 0
  end
end
it 'a single g press is a no-op'
it 'g followed by any non-g key resets the state machine'

it '/ focuses the search input'
it 'space toggles active module (aria-expanded flips)'
it 'o expands all modules; c collapses all modules'
it 'e opens edit route for active module' # see step 6 — gap
it 'n opens new-module form and focuses name input'
it 'a adds outcome to active module first category and focuses input'

it 'q with hovered outcome routes to new_question_path with learning_objective_id'
it 'q with no hover but keyboard-focused outcome uses focus fallback'
it 'q with neither announces "Hover an outcome first" via aria-live polite'

it 'v cycles view modules → categories → outcomes → modules'
it 'h toggles heatmap mode'
it '? opens the keyboard overlay'
it 'Esc closes the overlay; Esc with no overlay blurs active element'
```

### 2.2 Input short-circuit specs

```ruby
it 'typing ? in the search input does NOT open the overlay' do
  visit topic_path(topic)
  find('[data-topic-search-target="input"]').send_keys('?')
  expect(page).to have_no_css('[data-topic-keyboard-target="overlay"][aria-hidden="false"]')
end

it 'typing j in the new-module textarea does NOT advance the module'
it 'Esc inside an input blurs that input but fires no other shortcut'
it 'shortcuts do not fire when target is [contenteditable]'
```

### 2.3 Modifier-key short-circuit specs

```ruby
it 'Cmd+J does NOT advance the module' do
  active_before = page.evaluate_script('document.querySelector("[data-active-module]").dataset.moduleId')
  find('body').send_keys([:meta, 'j'])
  active_after = page.evaluate_script('document.querySelector("[data-active-module]").dataset.moduleId')
  expect(active_after).to eq active_before
end
it 'Ctrl+J does NOT advance the module'
it 'Alt+J does NOT advance the module'
it 'Shift+/ (i.e. ?) DOES open the overlay (shift is the only allowed modifier)'
```

### 2.4 Overlay specs

```ruby
it 'click on backdrop closes the overlay'
it 'click on the × button closes the overlay'
it 'Tab cycles focus within the overlay only (focus trap)' do
  # Open overlay, Tab N times, ensure document.activeElement stays inside dialog
end
it 'first focusable element on open is the close × button'
it 'body has overflow:hidden while overlay is open'
it 'on close, focus returns to the previously-focused element'
it 'overlay has aria-modal="true", role="dialog", aria-labelledby="shortcuts-title"'
it 'while overlay is open, j / k / space etc. are suppressed (only Esc, Tab, Enter work)'
```

### 2.5 First-visit toast specs

```ruby
it 'first visit shows the toast for 5 seconds, then auto-hides'
it 'click on the toast dismisses it'
it 'pressing ? dismisses the toast (and opens the overlay)'
it 'after first dismissal, localStorage flag is set to "true"'
it 'subsequent visits do NOT show the toast'  # seed flag before visit
```

### 2.6 Reduced-motion specs

```ruby
# Headless Chrome supports prefers-reduced-motion via flags or CDP
it 'pulse halo is instantaneous when prefers-reduced-motion: reduce' do
  page.driver.browser.execute_cdp('Emulation.setEmulatedMedia',
    features: [{ name: 'prefers-reduced-motion', value: 'reduce' }])
  # press j; assert .halo-pulse element has no transition or animation-duration: 0s
end
it 'smooth scroll degrades to instant when reduced-motion is set'
```

### 2.7 axe-core a11y on the open overlay

```ruby
it 'open overlay has zero axe-core violations' do
  find('body').send_keys('?')
  expect(page).to be_axe_clean.within('[data-topic-keyboard-target="overlay"]')
end
```

(Requires `axe-core-rspec`; add to `:test` group in Gemfile and `require 'axe-rspec'` in `rails_helper.rb`.)

---

## 3. Implementation steps

### Step 1 — `topic_keyboard_controller.js`

**Explanation.** New Stimulus controller owning the global `keydown` listener, `g g` state machine, hover/focus tracking for `q`, overlay lifecycle, and first-visit toast. Eager-loaded automatically by `controllers/index.js`. Mounted on the page wrapper: `data-controller="topic-detail topic-keyboard …"`.

**Before.** No keyboard shortcut layer. `topic_detail_controller.js` lines 179–187 handle Enter/Escape inside form inputs only.

**After.** ~150 lines of plain ES.

```javascript
// app/javascript/controllers/topic_keyboard_controller.js
import { Controller } from "@hotwired/stimulus"

const G_WINDOW_MS = 400
const TOAST_KEY = "topic-detail:keyboard-toast-seen"
const TOAST_DURATION_MS = 5000
const HOVER_DEBOUNCE_MS = 50
const INPUT_TAGS = ["INPUT", "TEXTAREA", "SELECT"]

export default class extends Controller {
  static targets = ["overlay", "overlayClose", "toast", "ariaLive"]
  static values = {
    activeModuleId: Number,
    moduleCount: Number,
    lastHoveredLoId: { type: Number, default: 0 }
  }

  connect() {
    this.lastG = 0
    this.hoverTimer = null
    this.previouslyFocused = null
    this.overlayOpen = false

    this.boundKeydown = this.handleKeydown.bind(this)
    this.boundPointerOver = this.handlePointerOver.bind(this)
    this.boundPointerLeave = this.handlePointerLeave.bind(this)
    this.boundFocusIn = this.handleFocusIn.bind(this)
    this.boundOverlayKeydown = this.handleOverlayKeydown.bind(this)

    window.addEventListener("keydown", this.boundKeydown)
    this.element.addEventListener("pointerover", this.boundPointerOver)
    this.element.addEventListener("pointerleave", this.boundPointerLeave)
    this.element.addEventListener("focusin", this.boundFocusIn)

    this.maybeShowFirstVisitToast()
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
    this.element.removeEventListener("pointerover", this.boundPointerOver)
    this.element.removeEventListener("pointerleave", this.boundPointerLeave)
    this.element.removeEventListener("focusin", this.boundFocusIn)
    if (this.overlayOpen) this.closeOverlay() // tidy up body overflow if Turbo navigates away
  }

  // ──────────── Main keydown router ────────────
  handleKeydown(event) {
    // Overlay state takes precedence
    if (this.overlayOpen) return this.handleOverlayKeydown(event)

    // Short-circuit on inputs / contenteditable
    const t = event.target
    const inEditable =
      INPUT_TAGS.includes(t.tagName) || t.isContentEditable
    if (inEditable) {
      // Esc inside input → blur, then stop
      if (event.key === "Escape") t.blur()
      return
    }

    // Short-circuit on non-Shift modifiers (let the browser handle Cmd+J etc.)
    if (event.metaKey || event.ctrlKey || event.altKey) return

    switch (event.key) {
      case "j": return this.advanceModule(+1, event)
      case "k": return this.advanceModule(-1, event)
      case " ": event.preventDefault(); return this.dispatchModule("toggle")
      case "o": return this.dispatch("topic-module:expand-all")
      case "c": return this.dispatch("topic-module:collapse-all")
      case "/":
        event.preventDefault()
        return this.dispatch("topic-search:focus")
      case "?":
        event.preventDefault()
        return this.openOverlay()
      case "v": return this.dispatch("topic-view:cycle")
      case "h": return this.dispatch("topic-heatmap:toggle-mode")
      case "e": return this.openEditForActiveModule()
      case "n": return this.dispatch("topic-module:new-form-focus")
      case "a": return this.dispatch("topic-module:add-outcome-active")
      case "q": return this.openQuestionForHoveredOutcome()
      case "g": return this.handleG(event)
      case "Escape": return // nothing to close at top level
    }

    // Number keys 1..9
    if (/^[1-9]$/.test(event.key)) {
      const n = parseInt(event.key, 10)
      if (n <= this.moduleCountValue) {
        this.dispatch("topic-sidebar:select-module", { detail: { index: n - 1 } })
      }
    }
  }

  // ──────────── g g state machine ────────────
  handleG(event) {
    const now = performance.now()
    if (now - this.lastG < G_WINDOW_MS) {
      this.lastG = 0
      this.dispatch("topic-detail:scroll-top")
      event.preventDefault()
    } else {
      this.lastG = now
    }
  }

  // ──────────── Active module pointer ────────────
  advanceModule(delta, event) {
    const next = Math.min(
      Math.max(0, (this.activeModuleIdValue || 0) + delta),
      this.moduleCountValue - 1
    )
    this.dispatch("topic-sidebar:select-module", { detail: { index: next } })
    event.preventDefault()
  }

  dispatchModule(action) {
    this.dispatch(`topic-module:${action}`, {
      detail: { id: this.activeModuleIdValue }
    })
  }

  // ──────────── q : hover/focus → new question ────────────
  openQuestionForHoveredOutcome() {
    const hovered = document.querySelector(".topic-module__lo:hover")
    const focused = document.activeElement?.closest?.(".topic-module__lo")
    const target = hovered || focused
    if (!target) return this.announce("Hover an outcome first")
    const loId = target.dataset.loId
    if (!loId) return this.announce("Hover an outcome first")
    window.location.href = `/learning_objectives/${loId}/questions/new`
  }

  // ──────────── e : edit active module (see step 6) ────────────
  openEditForActiveModule() {
    // Recommended (b) — polite toast until route is wired
    this.announce("Edit not yet wired — coming soon")
  }

  // ──────────── Hover/focus tracking for q ────────────
  handlePointerOver(event) {
    const lo = event.target.closest?.(".topic-module__lo")
    if (!lo) return
    clearTimeout(this.hoverTimer)
    this.hoverTimer = setTimeout(() => {
      this.lastHoveredLoIdValue = parseInt(lo.dataset.loId, 10)
    }, HOVER_DEBOUNCE_MS)
  }

  handlePointerLeave() { clearTimeout(this.hoverTimer) }

  handleFocusIn(event) {
    // Reset g-state machine if focus enters an input
    if (INPUT_TAGS.includes(event.target.tagName) || event.target.isContentEditable) {
      this.lastG = 0
    }
    const lo = event.target.closest?.(".topic-module__lo")
    if (lo) this.lastHoveredLoIdValue = parseInt(lo.dataset.loId, 10)
  }

  // ──────────── Overlay ────────────
  openOverlay() {
    if (this.overlayOpen) return
    this.previouslyFocused = document.activeElement
    this.overlayTarget.setAttribute("aria-hidden", "false")
    document.body.style.overflow = "hidden"
    this.overlayOpen = true
    this.overlayCloseTarget.focus()
    this.dismissToast() // opening overlay implicitly acknowledges discoverability
  }

  closeOverlay() {
    this.overlayTarget.setAttribute("aria-hidden", "true")
    document.body.style.overflow = ""
    this.overlayOpen = false
    if (this.previouslyFocused && this.previouslyFocused.focus) {
      this.previouslyFocused.focus()
    }
    this.previouslyFocused = null
  }

  handleOverlayKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      return this.closeOverlay()
    }
    if (event.key === "Tab") return this.trapFocus(event)
    // Suppress every other shortcut — overlay is exclusive
    if (event.key !== "Enter" && event.key !== " ") event.preventDefault()
  }

  trapFocus(event) {
    const focusable = this.overlayTarget.querySelectorAll(
      'button, [href], input, [tabindex]:not([tabindex="-1"])'
    )
    if (focusable.length === 0) return
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault(); last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault(); first.focus()
    }
  }

  // ──────────── First-visit toast ────────────
  maybeShowFirstVisitToast() {
    if (localStorage.getItem(TOAST_KEY) === "true") return
    if (!this.hasToastTarget) return
    this.toastTarget.removeAttribute("hidden")
    this.toastTimer = setTimeout(() => this.dismissToast(), TOAST_DURATION_MS)
  }

  dismissToast() {
    if (!this.hasToastTarget) return
    if (this.toastTarget.hasAttribute("hidden")) return
    this.toastTarget.setAttribute("hidden", "")
    clearTimeout(this.toastTimer)
    localStorage.setItem(TOAST_KEY, "true")
  }

  // ──────────── aria-live announcer ────────────
  announce(msg) {
    if (!this.hasAriaLiveTarget) return
    this.ariaLiveTarget.textContent = ""
    setTimeout(() => { this.ariaLiveTarget.textContent = msg }, 50)
  }
}
```

**Locking test.**

```ruby
it 'mounts the topic-keyboard controller' do
  visit topic_path(topic)
  expect(page).to have_css('[data-controller~="topic-keyboard"]')
end
```

---

### Step 2 — Overlay markup partial

**Explanation.** Static partial rendered once at the bottom of `show.html.erb` (v2). Hidden by default via `aria-hidden="true"` (CSS uses the attribute selector — never `display: none` via JS, which would invalidate the focus-trap selectors).

**After.** Create `/Users/louisraymond/projects/test_generator/app/views/topics/_keyboard_overlay.html.erb`:

```erb
<div class="kb-overlay"
     data-topic-keyboard-target="overlay"
     role="dialog"
     aria-modal="true"
     aria-labelledby="shortcuts-title"
     aria-hidden="true"
     data-action="click->topic-keyboard#backdropClose">
  <div class="kb-overlay__dialog" data-action="click->topic-keyboard#stopPropagation">
    <button class="kb-overlay__close"
            type="button"
            data-topic-keyboard-target="overlayClose"
            data-action="click->topic-keyboard#closeOverlay"
            aria-label="Close shortcuts overlay">×</button>
    <h2 id="shortcuts-title" class="kb-overlay__title">Keyboard shortcuts</h2>
    <p class="kb-overlay__subtitle">press ? again to close</p>
    <div class="kb-overlay__grid">
      <%= render 'topics/keyboard_group', title: 'Navigation', rows: [
        ['j', 'next module'], ['k', 'previous module'],
        ['1–9', 'jump to module N'], ['g g', 'scroll to top'], ['/', 'focus search']
      ] %>
      <%= render 'topics/keyboard_group', title: 'Modules', rows: [
        ['space', 'expand active'], ['o', 'expand all'], ['c', 'collapse all'],
        ['e', 'edit active'], ['n', 'new module']
      ] %>
      <%# Outcomes group: a, q — Views & heatmap: v, h — Misc: ?, Esc %>
    </div>
  </div>
</div>

<div class="kb-toast" data-topic-keyboard-target="toast" hidden
     data-action="click->topic-keyboard#dismissToast">
  Press <kbd>?</kbd> for keyboard shortcuts
</div>

<div class="visually-hidden" aria-live="polite"
     data-topic-keyboard-target="ariaLive"></div>
```

Plus a tiny shared partial `_keyboard_group.html.erb` for each labelled grid column.

**Locking test.** `it 'renders the overlay hidden on initial page load'`:

```ruby
visit topic_path(topic)
expect(page).to have_css('[data-topic-keyboard-target="overlay"][aria-hidden="true"]', visible: :all)
```

---

### Step 3 — CSS for overlay

**Explanation.** Backdrop + dialog + grid + reduced-motion overrides, in `app/assets/stylesheets/topic.css` under `/* ── Keyboard overlay (sub-57) ── */`.

**Before.** No `.kb-overlay` rules. **After:**

```css
/* ── Keyboard overlay (sub-57) ── */
.kb-overlay {
  position: fixed; inset: 0;
  background: rgba(20,15,10,0.55);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000; transition: opacity 160ms ease;
}
.kb-overlay[aria-hidden="true"] { display: none; }
.kb-overlay__dialog {
  background: var(--paper); border: 1px solid var(--rule);
  border-radius: 8px; padding: 28px 32px;
  max-width: 720px; width: calc(100% - 48px); position: relative;
}
.kb-overlay__title { font-family: var(--serif); font-size: 24px; margin: 0 0 4px; }
.kb-overlay__subtitle { font-family: var(--mono); font-size: 11px; color: var(--ink-3); margin: 0 0 20px; }
.kb-overlay__grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px 32px; }
.kb-overlay__close {
  position: absolute; top: 12px; right: 12px;
  width: 32px; height: 32px;
  background: transparent; border: 1px solid var(--rule); border-radius: 4px;
  font-size: 18px; line-height: 1; cursor: pointer;
}
.kb-key { font-family: var(--mono); font-size: 12px; border: 1px solid var(--rule); padding: 1px 6px; border-radius: 3px; }

.kb-toast {
  position: fixed; bottom: 24px; right: 24px;
  background: var(--card); border: 1px solid var(--rule);
  padding: 10px 14px; border-radius: 6px;
  font-size: var(--fs-small); cursor: pointer; z-index: 999;
}
.kb-toast[hidden] { display: none; }

@keyframes halo-pulse {
  0%   { box-shadow: 0 0 0 0 rgba(180,83,42,0.45); }
  100% { box-shadow: 0 0 0 14px rgba(180,83,42,0); }
}
.module-card--pulse { animation: halo-pulse 300ms ease-out; }

@media (prefers-reduced-motion: reduce) {
  .kb-overlay { transition: none; }
  .module-card--pulse { animation: none; }
  html { scroll-behavior: auto; }
}
```

**Locking test.** Reduced-motion spec from §2.6.

---

### Step 4 — First-visit toast

Wired by step 1 (`maybeShowFirstVisitToast`/`dismissToast`) + step 2 markup. The flag is set on every dismissal path: timeout, click, `?` (which calls `openOverlay` → `dismissToast`). Locking test: §2.5.

---

### Step 5 — Wire dispatch events

**Explanation.** This controller is a publisher. The table below is the event contract. Other controllers (built in sub-2 to sub-5) listen.

| Event name | Payload | Listener (sub-) | Effect |
|---|---|---|---|
| `topic-sidebar:select-module` | `{ index }` | sub-2 | scroll module N into view, set active state, ask sub-4 to expand it, ask sub-3 for halo pulse |
| `topic-module:toggle` | `{ id }` | sub-4 | toggle accordion |
| `topic-module:expand-all` | — | sub-4 | expand every accordion |
| `topic-module:collapse-all` | — | sub-4 | collapse every accordion |
| `topic-module:new-form-focus` | — | sub-2 | open the WIP module card and focus its name input |
| `topic-module:add-outcome-active` | `{ moduleId }` | sub-4 | open inline LO form on the active module's first category |
| `topic-heatmap:toggle-mode` | — | sub-3 | flip coverage ↔ utilisation |
| `topic-view:cycle` | — | sub-5 | rotate modules → categories → outcomes |
| `topic-search:focus` | — | sub-2 / sub-5 | `inputTarget.focus()` |
| `topic-detail:scroll-top` | — | sub-2 | scroll right pane to top, `behavior: 'smooth'` (or instant under reduced-motion) |

All dispatches use Stimulus `this.dispatch(name, { detail, prefix: false })` so the event name is bare (no `topic-keyboard:` prefix) and listeners don't need to know the source. Locking tests: §2.1 per-shortcut specs assert the observable side-effect (URL change, aria-expanded change, focus location).

---

### Step 6 — Edit route gap

Recon §3 confirms `/topics/:id` exposes `resources :topics, only: %i[index show new create edit update]`, but there is **no** `edit_topic_module_path`. `topic_modules` are mounted only under `namespace :api` with `:create`.

**Options.** (a) Add a stub `resources :topic_modules, only: %i[edit]` + placeholder action. (b) Wire `e` to a polite aria-live announcement and file a follow-up.

**Recommendation: (b).** A stub route shipped to production confuses power users; the aria-live announcement is honest, keeps the shortcut allocated for when sub-author-edit lands, and keeps this sub-issue tightly scoped.

**Follow-up.** File `Add edit_topic_module route + action for sub-57 'e' shortcut`.

**Locking test.** `it 'e announces "Edit not yet wired" via aria-live'`.

---

## 4. Antagonist review

### Persona A — Skeptic Engineer

> **A.1.** `g g` state machine: user presses `g`, focus shifts into search via `/`, user types `g`. First `g` still primed; on blur back to body, a stray `g` could falsely complete. **ACCEPTED** — `handleFocusIn` resets `this.lastG = 0` when focus enters an editable. Lock with: `it 'g, then focus-into-input, then bare g within 400ms is a no-op'`.

> **A.2.** Window keydown leaks across Turbo navigations. **ACCEPTED** — `disconnect()` removes the listener, so Stimulus's connect/disconnect lifecycle handles cache restore. Regression test: visit A → B → back to A, assert keydown fires exactly once.

> **A.3.** Race during Turbo morphing — two controllers briefly attached. **ACCEPTED, NO CHANGE** — both instances install and remove their own listeners; race window is microsecond-scale. Locked by A.2.

> **A.4.** Browser extensions injecting DOM that escapes the focus trap. **REJECTED** — out of scope. Documented in §6 risks.

### Persona B — A11y Reviewer

> **B.1.** `q` requires "hover" — keyboard users do not hover. **ACCEPTED** — focus fallback is in the controller and §2.1 specs.

> **B.2.** Footer hint is static text; screen-reader users who never press `?` will not discover the overlay. **ACCEPTED** — add a visually-hidden button adjacent to the footer:

```erb
<button class="visually-hidden" data-action="click->topic-keyboard#openOverlay">
  Open keyboard shortcuts overlay
</button>
```

> **B.3.** Single-letter shortcuts clash with NVDA/JAWS quick-nav (H = next heading, etc.). When AT is active, our shortcuts may never fire. **ACCEPTED, DOCUMENTED** in §6. The overlay (opened via the B.2 button) is the discoverable fallback.

> **B.4.** `aria-live` for "Hover an outcome first" must be `polite` + visually hidden. **ACCEPTED** — markup uses `class="visually-hidden" aria-live="polite"`. Audit test: `expect(page).to have_css('[aria-live="polite"].visually-hidden', visible: :all)`.

### Persona C — Skeptic Engineer 2

> **C.1.** Pulse halo on `j`/`k` depends on sub-4 applying `module-card--pulse` in response to `topic-sidebar:select-module`. **ACCEPTED, RESTATED** — if sub-3/sub-4 not merged, `j`/`k` still updates active module but the visual pulse is absent. Hard dependency in tracker.

> **C.2.** `space` also triggers click on focused buttons (Edit, Add LO). Without disambiguation, `space` will both click the button AND toggle the active module. **ACCEPTED** — short-circuit `space` (only) when target is a button:

```javascript
case " ":
  if (t.tagName === "BUTTON" || t.getAttribute?.("role") === "button") return
  event.preventDefault()
  return this.dispatchModule("toggle")
```

`j`/`k` etc. still fire from a button-focused state — only `space` defers. Test: `it 'space on a focused Edit button does not also toggle the active module'`.

> **C.3.** (volunteered) `q` uses `window.location.href` and loses Turbo state. **ACCEPTED**:

```javascript
const url = `/learning_objectives/${loId}/questions/new`
if (window.Turbo) Turbo.visit(url); else window.location.href = url
```

---

## 5. Open questions

1. **Halo pulse ownership.** Sub-4 or sub-3? Either works against the dispatcher contract; defer to whichever lands first.
2. **>9 modules.** Number-row caps at 9; topics with 10+ modules rely on `j`/`k`. Acceptable for v1, flag for design review.
3. **Toast under reduced-motion.** Should it persist until explicit dismissal rather than 5s autohide? A11y review pass.
4. **`Esc` precedence with overlay + input.** Current order: overlay first. Matches spec §7.
5. **`prefix: false`** on `this.dispatch` requires Stimulus 3.2+. Verify `package.json` pin.

---

## 6. Risks

1. **Hard dependency chain.** Merging before sub-2/3/4/5 leaves shortcuts firing into the void. Gate merge on the other four; per-shortcut specs assert observable side-effects rather than listener presence.
2. **Headless Chrome reduced-motion emulation.** `Emulation.setEmulatedMedia` via CDP is fragile. Fallback: key CSS off a custom property and toggle via `execute_script`.
3. **AT shortcut clobber.** NVDA/JAWS/VoiceOver consume single-letter keys in browse mode. Documented limitation; overlay (opened via the B.2 visually-hidden button) is the fallback.
4. **Turbo re-binding.** Window listeners across cached pages are a known repo footgun. Mitigated by `disconnect()` + regression spec.
5. **AZERTY/QWERTZ `?`.** `event.key === '?'` is layout-independent (logical key). Verified.
6. **localStorage unavailable** (private mode throws). Wrap access in a try/catch shim so the toast timeout still works but the flag silently no-ops.
7. **Edit route placeholder.** aria-live announcement may surprise QA. File follow-up alongside merge.

---

## Implementation order

1. Controller skeleton + `connect`/`disconnect` + window listener — mount spec.
2. Input/modifier short-circuits — §2.2 + §2.3.
3. Per-shortcut dispatch table — §2.1.
4. `g g` state machine — timing spec.
5. Hover/focus tracking + `q` — §2.1 q-specs.
6. Overlay markup + CSS — overlay specs.
7. Focus trap + body overflow + focus restore — §2.4.
8. First-visit toast + localStorage — §2.5.
9. Reduced-motion overrides — §2.6.
10. axe-core pass — §2.7.
11. File edit-route follow-up.
