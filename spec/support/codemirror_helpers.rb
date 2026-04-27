module CodemirrorHelpers
  # Wait until the CM6 EditorView is attached to the element. The Stimulus
  # controller mounts CM6 lazily inside an async connect() — the ESM imports
  # are fetched from a CDN, so on a cold cache there's a non-trivial delay
  # between the data-controller attribute being present and `cmView` actually
  # being assigned. Tests must wait on the latter, not the former.
  def wait_for_cm_ready(selector, timeout: 8)
    Timeout.timeout(timeout) do
      loop do
        ready = page.evaluate_script(<<~JS)
          (() => {
            const el = document.querySelector(#{selector.to_json});
            return !!(el && el.cmView);
          })()
        JS
        break if ready
        sleep 0.05
      end
    end
  end

  # Read the current document text from a mounted CM6 editor.
  def cm_value(selector)
    wait_for_cm_ready(selector)
    page.evaluate_script(<<~JS)
      document.querySelector(#{selector.to_json}).cmView.state.doc.toString()
    JS
  end

  # Replace the document text via a CM6 transaction (more reliable than send_keys
  # in headless Chrome; still fires the updateListener so save plumbing exercises).
  def cm_set_value(selector, text)
    wait_for_cm_ready(selector)
    page.execute_script(<<~JS)
      const el = document.querySelector(#{selector.to_json});
      const view = el.cmView;
      view.dispatch({
        changes: { from: 0, to: view.state.doc.length, insert: #{text.to_json} }
      });
      view.contentDOM.dispatchEvent(new FocusEvent('blur'));
    JS
  end

  # Place the cursor at line/col (1-indexed) and focus.
  def cm_set_cursor(selector, line:, col: 1)
    wait_for_cm_ready(selector)
    page.execute_script(<<~JS)
      const el = document.querySelector(#{selector.to_json});
      const view = el.cmView;
      const lineInfo = view.state.doc.line(#{line});
      const pos = lineInfo.from + (#{col} - 1);
      view.dispatch({ selection: { anchor: pos } });
      view.focus();
    JS
  end

  # Wait until the controller stamps data-cm-saved-at after the most recent edit.
  # The 8s window matches the KaTeX cold-cache wait bumped in #42 — the explicit-Save
  # round-trip can exceed 3s on a cold connection (CDN warmup + server pacing).
  def wait_for_cm_save(selector, timeout: 8)
    started_at = page.evaluate_script(
      "document.querySelector(#{selector.to_json}).dataset.cmSavedAt || '0'"
    ).to_i
    Timeout.timeout(timeout) do
      loop do
        current = page.evaluate_script(
          "document.querySelector(#{selector.to_json}).dataset.cmSavedAt || '0'"
        ).to_i
        break if current > started_at
        sleep 0.05
      end
    end
  end
end

RSpec.configure do |c|
  c.include CodemirrorHelpers, type: :system
end
