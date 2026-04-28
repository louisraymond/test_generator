# frozen_string_literal: true

# === sub-57: keyboard ===
# Test-only helpers for the topic-keyboard system specs. After integration,
# show.html.erb (sub-53) mounts the topic-keyboard controller and overlay
# partial directly when ?v2=1 is set, so the original DOM-grafting in
# `inject_keyboard_controller!` is no longer required for the mount itself.
# The helper now only installs the window-level event recorder so specs can
# assert dispatched events; it intentionally does NOT re-inject the overlay
# (the integrated page already has one — duplicating it would break the
# spec's CSS selectors).
module Sub57KeyboardHelpers
  EVENT_NAMES = %w[
    topic-sidebar:select-module
    topic-module:toggle
    topic-module:expand-all
    topic-module:collapse-all
    topic-module:new-form-focus
    topic-module:add-outcome-active
    topic-heatmap:toggle-mode
    topic-view:cycle
    topic-search:focus
    topic-detail:scroll-top
  ].freeze

  # Render the overlay partial as raw HTML (server-side) so the JS injection
  # uses the exact same markup that ships in production.
  def keyboard_overlay_html
    ApplicationController.render(partial: 'topics/keyboard_overlay')
  end

  # Install the window-level event recorder for the topic-keyboard specs.
  # The mount + overlay are now rendered server-side by sub-53's show.html.erb
  # when ?v2=1 is set, so the helper only wires the recorder. The
  # `module_count`/`active_module_index` arguments are kept for spec
  # backwards-compatibility but are ignored — the integrated controller pulls
  # those values from the DOM data attributes.
  def inject_keyboard_controller!(module_count: 0, active_module_index: 0) # rubocop:disable Lint/UnusedMethodArgument
    events_js = EVENT_NAMES.to_json

    page.execute_script(<<~JS)
      (function() {
        if (window.__sub57Recorder) return; // idempotent

        window.__sub57Recorder = { events: [] };
        var names = #{events_js};
        names.forEach(function(name) {
          window.addEventListener(name, function(e) {
            window.__sub57Recorder.events.push({
              name: name,
              detail: e.detail || null,
              timestamp: Date.now()
            });
          });
        });
      })();
    JS
  end

  def recorded_events
    page.evaluate_script('window.__sub57Recorder ? window.__sub57Recorder.events : []')
  end

  def event_names_for(name)
    recorded_events.select { |e| e['name'] == name }
  end

  def reset_event_recorder!
    page.execute_script('if (window.__sub57Recorder) window.__sub57Recorder.events = [];')
  end

  def press(key)
    find('body').send_keys(key)
  end

  def overlay_visible?
    page.has_css?('[data-topic-keyboard-target="overlay"][aria-hidden="false"]', visible: :all, wait: 0.3)
  end

  def overlay_hidden?
    page.has_css?('[data-topic-keyboard-target="overlay"][aria-hidden="true"]', visible: :all, wait: 0.3)
  end

  def clear_toast_seen_flag!
    page.execute_script("try { localStorage.removeItem('topic-detail:keyboard-toast-seen'); } catch(_) {}")
  end

  def seed_toast_seen_flag!
    page.execute_script("try { localStorage.setItem('topic-detail:keyboard-toast-seen', 'true'); } catch(_) {}")
  end
end

RSpec.configure do |config|
  config.include Sub57KeyboardHelpers, type: :system
end
