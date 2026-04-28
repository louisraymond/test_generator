require 'rails_helper'

# This spec mounts the V2 partials in a tiny Rack endpoint so the JS
# behaviour of `topic_module_controller` can be exercised in isolation,
# without touching the real `topics#show` view (sub-53 owns it).
RSpec.describe 'Topic V2 module card', :sub55_js, type: :system do
  let(:topic) { create(:topic, name: 'Sub55 Topic') }
  let!(:mod_a) do
    m = create(:topic_module, topic: topic, name: 'Alpha Module', position: 0)
    create(:learning_objective, topic: topic, topic_module: m, category: 'Basics', position: 0, description: 'Outcome A1')
    create(:learning_objective, topic: topic, topic_module: m, category: 'Basics', position: 1, description: 'Outcome A2')
    m
  end
  let!(:mod_b) do
    m = create(:topic_module, topic: topic, name: 'Beta Module', position: 1)
    create(:learning_objective, topic: topic, topic_module: m, category: 'Basics', position: 0, description: 'Outcome B1')
    m
  end

  # Build a minimal HTML page that hosts the partials and the Stimulus
  # controller. Mount it via Capybara.app for the duration of the example.
  def mount_v2_page(modules)
    css_path  = Rails.root.join('app/assets/stylesheets/topic.css').to_s
    css_body  = File.exist?(css_path) ? File.read(css_path) : ''

    cards_html = modules.each_with_index.map do |mod, idx|
      ApplicationController.renderer.render(
        partial: 'topics/module_card',
        locals:  { mod: mod, idx: idx, exam_usage: { mod.learning_objectives.first&.id => 4 }.compact }
      )
    end.join("\n")

    js_path = Rails.root.join('app/javascript/controllers/topic_module_controller.js').to_s
    js_body = File.read(js_path)
    # Strip the bare-specifier import so the browser can load this as a plain script.
    # We will provide `Controller` via a prelude.
    stripped = js_body.sub(
      /^\s*import\s+\{\s*Controller\s*\}\s+from\s+["']@hotwired\/stimulus["']\s*$/m, ''
    )
    # Convert ES `export default class extends Controller` -> a named class, then
    # expose it on `window` so the importmap-loaded Stimulus app can register it.
    stripped = stripped.sub(/export\s+default\s+class\s+extends\s+Controller/,
                            'window.TopicModuleCtl = class extends Controller')

    bootstrap = <<~JS
      import { Application, Controller } from "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js"
      window.Controller = Controller
    JS

    register_js = <<~JS
      ;(function () {
        function start() {
          if (!window.Controller || !window.TopicModuleCtl) {
            return setTimeout(start, 10)
          }
          import("https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js")
            .then(({ Application }) => {
              const app = Application.start()
              app.register('topic-module', window.TopicModuleCtl)
              window.__stimulusReady = true
            })
        }
        start()
      })()
    JS

    full_html = <<~HTML
      <!doctype html>
      <html><head>
        <meta charset="utf-8"/>
        <title>sub-55 harness</title>
        <style>#{css_body}</style>
        <script type="module">#{bootstrap}</script>
      </head><body>
        <main>#{cards_html}</main>
        <script>
          // Wait for Stimulus' Controller to be hung off window, then evaluate
          // the controller source so the class registers against it.
          (function () {
            function tryEval () {
              if (!window.Controller) return setTimeout(tryEval, 10)
              const Controller = window.Controller
              #{stripped}
            }
            tryEval()
          })()
        </script>
        <script>#{register_js}</script>
      </body></html>
    HTML

    @harness_app = ->(_env) { [200, { 'Content-Type' => 'text/html' }, [full_html]] }
    Capybara.app = @harness_app
  end

  before do
    @prev_app = Capybara.app
    mount_v2_page([mod_a, mod_b])
  end

  after do
    Capybara.app = @prev_app
  end

  def visit_harness
    visit '/'
    # Wait for Stimulus to register.
    Timeout.timeout(5) do
      sleep 0.05 until page.evaluate_script('!!window.__stimulusReady')
    end
  end

  it 'expands the first module by default and collapses the rest' do
    visit_harness
    first_btn  = find("article#mod-#{mod_a.id} button.topic-module__toggle")
    second_btn = find("article#mod-#{mod_b.id} button.topic-module__toggle")
    expect(first_btn['aria-expanded']).to eq('true')
    expect(second_btn['aria-expanded']).to eq('false')
    expect(page).to have_css("article#mod-#{mod_b.id} .topic-module__body[hidden]", visible: :all)
  end

  it 'flips aria-expanded and reveals the body when the header button is clicked' do
    visit_harness
    second_btn = find("article#mod-#{mod_b.id} button.topic-module__toggle")
    second_btn.click
    expect(page).to have_css("article#mod-#{mod_b.id} button.topic-module__toggle[aria-expanded='true']")
    expect(page).not_to have_css("article#mod-#{mod_b.id} .topic-module__body[hidden]", visible: :all)
  end

  it 'does NOT toggle the card when the Edit button is clicked (button-not-nested means click does not bubble)' do
    visit_harness
    first_btn = find("article#mod-#{mod_a.id} button.topic-module__toggle")
    expect(first_btn['aria-expanded']).to eq('true')

    find("article#mod-#{mod_a.id} button.topic-module__edit").click

    # Toggle remains expanded, edit dispatched the not-implemented event instead.
    expect(first_btn['aria-expanded']).to eq('true')
  end

  it 'persists expand/collapse state to localStorage and restores on reload' do
    visit_harness
    find("article#mod-#{mod_b.id} button.topic-module__toggle").click

    stored = page.evaluate_script("window.localStorage.getItem('topic-detail:topic-#{topic.id}:expanded')")
    expect(stored).to be_a(String)
    expect(JSON.parse(stored)).to include(mod_b.id)

    visit_harness
    expect(page).to have_css("article#mod-#{mod_b.id} button.topic-module__toggle[aria-expanded='true']")
  end

  it "swaps every chip's text and class when topic-heatmap:mode-changed is dispatched" do
    visit_harness
    # Initial: questions mode — first LO of mod_a has 0 questions => "0q"
    chip_sel = "article#mod-#{mod_a.id} .topic-detail__chip"
    chip = first(chip_sel)
    expect(chip.text).to eq('0q')

    page.execute_script(
      "window.dispatchEvent(new CustomEvent('topic-heatmap:mode-changed', {detail: {mode: 'usage'}}))"
    )

    # exam_usage in the harness pinned the first LO of mod_a to 4 uses.
    expect(page).to have_css("#{chip_sel}.topic-detail__chip--b3", text: '4x')
  end

  it 'expands every card when topic-module:expand-all is dispatched on window' do
    visit_harness
    page.execute_script("window.dispatchEvent(new CustomEvent('topic-module:expand-all'))")
    expect(page).to have_css("article#mod-#{mod_a.id} button.topic-module__toggle[aria-expanded='true']")
    expect(page).to have_css("article#mod-#{mod_b.id} button.topic-module__toggle[aria-expanded='true']")
  end

  it 'collapses every card when topic-module:collapse-all is dispatched on window' do
    visit_harness
    page.execute_script("window.dispatchEvent(new CustomEvent('topic-module:collapse-all'))")
    expect(page).to have_css("article#mod-#{mod_a.id} button.topic-module__toggle[aria-expanded='false']")
    expect(page).to have_css("article#mod-#{mod_b.id} button.topic-module__toggle[aria-expanded='false']")
  end

  it 'pulses the matching outcome row when topic-heatmap:focus-lo is dispatched' do
    visit_harness
    target_lo = mod_a.learning_objectives.first
    # Capture pulse-class presence inside the page so we don't race the 300ms timer.
    page.execute_script(<<~JS)
      window.__pulseSeen = false
      const li = document.querySelector("li[data-lo-id='#{target_lo.id}']")
      const obs = new MutationObserver(() => {
        if (li.classList.contains('topic-detail__lo--pulse')) window.__pulseSeen = true
      })
      obs.observe(li, { attributes: true, attributeFilter: ['class'] })
      window.dispatchEvent(new CustomEvent('topic-heatmap:focus-lo', {detail: {loId: #{target_lo.id}}}))
    JS
    using_wait_time(3) do
      expect(page.evaluate_script('window.__pulseSeen')).to be true
    end
    # Pulse class is removed after ~300ms.
    using_wait_time(3) do
      expect(page).not_to have_css("li[data-lo-id='#{target_lo.id}'].topic-detail__lo--pulse")
    end
  end
end
