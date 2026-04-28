# frozen_string_literal: true

# === sub-57: keyboard ===
# Test-only helpers. In an isolated worktree, show.html.erb does not yet wire
# the topic-keyboard controller (its mount point belongs to sub-2 / sub-53).
# These helpers visit the existing topic page and graft the controller, the
# overlay markup, and a window-level event recorder onto the DOM via JS.
# When sub-53 merges and includes the partial in show.html.erb, the
# `inject_keyboard_controller!` helper becomes a no-op shim.
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

  # Inject the controller mount + overlay markup + an event recorder.
  # Must be called AFTER `visit topic_path(...)`.
  def inject_keyboard_controller!(module_count: 0, active_module_index: 0)
    overlay_html = keyboard_overlay_html.to_json
    events_js = EVENT_NAMES.to_json

    page.execute_script(<<~JS)
      (function() {
        if (window.__sub57Recorder) return; // idempotent

        // 1. Install the event recorder on window so we can inspect dispatches.
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

        // 2. Append a mount-point + overlay partial to body, then attach Stimulus.
        var mount = document.createElement('div');
        mount.id = 'sub57-mount';
        mount.setAttribute('data-controller', 'topic-keyboard');
        mount.setAttribute('data-topic-keyboard-module-count-value', '#{module_count}');
        mount.setAttribute('data-topic-keyboard-active-module-index-value', '#{active_module_index}');
        mount.innerHTML = #{overlay_html};
        document.body.appendChild(mount);
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
