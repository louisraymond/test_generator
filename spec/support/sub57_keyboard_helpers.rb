# frozen_string_literal: true

# === sub-57: keyboard ===
# Test-only helpers for the topic-keyboard system specs. After integration,
# show.html.erb (sub-53) mounts the topic-keyboard controller and overlay
# partial directly (V2 is the default), so the original DOM-grafting in
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

  # Install the window-level event recorder for the topic-keyboard specs
  # and override the controller's data values so individual tests can drive
  # specific module counts / active module indexes without rebuilding the
  # whole topic graph.
  #
  # Sub-53's show.html.erb mounts the topic-keyboard controller server-side
  # by default (V2); the overlay markup ships with it. This helper:
  #   1. Locates the integrated controller mount.
  #   2. Updates its data-* values to match the test's intent.
  #   3. Re-emits a Stimulus reconnect by toggling data-controller, so the
  #      controller re-reads its values.
  #   4. Wires the window-level event recorder so specs can assert dispatches.
  def inject_keyboard_controller!(module_count: 0, active_module_index: 0)
    events_js = EVENT_NAMES.to_json

    page.execute_script(<<~JS)
      (function() {
        // 1. Recorder (idempotent).
        if (!window.__sub57Recorder) {
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
        }

        // 2. Override the integrated controller's values + reconnect.
        var mount = document.querySelector('[data-controller~="topic-keyboard"]');
        if (mount) {
          mount.setAttribute('data-topic-keyboard-module-count-value', '#{module_count}');
          mount.setAttribute('data-topic-keyboard-active-module-index-value', '#{active_module_index}');
          // Toggle the controller binding to force Stimulus to disconnect/reconnect
          // and pick up the new values.
          var ctrls = mount.getAttribute('data-controller') || '';
          mount.setAttribute('data-controller', ctrls.replace(/\\btopic-keyboard\\b/g, '').trim());
          // Use setTimeout to let Stimulus process the disconnect before re-adding.
          setTimeout(function() {
            mount.setAttribute('data-controller', (ctrls.indexOf('topic-keyboard') >= 0 ? ctrls : ctrls + ' topic-keyboard').trim());
          }, 10);
        }
      })();
    JS

    # Give Stimulus a moment to reconnect with the new values.
    sleep 0.05
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
    # The integrated controller mounted on page-load may already have removed
    # the `hidden` attribute from the toast before the test had a chance to
    # seed the flag. Re-hide the toast and clear any pending dismiss timer so
    # the spec sees the post-seed steady state.
    page.execute_script(<<~JS)
      try { localStorage.setItem('topic-detail:keyboard-toast-seen', 'true'); } catch(_) {}
      var toast = document.querySelector('[data-topic-keyboard-target="toast"]');
      if (toast) toast.setAttribute('hidden', '');
    JS
  end
end

RSpec.configure do |config|
  config.include Sub57KeyboardHelpers, type: :system
end
