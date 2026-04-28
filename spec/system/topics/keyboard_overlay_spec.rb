require 'rails_helper'

RSpec.describe 'Topic detail keyboard overlay', type: :system, js: true do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic, :with_modules) }

  def visit_topic_with_keyboard
    visit topic_path(topic, v2: 1)
    inject_keyboard_controller!(module_count: 2, active_module_index: 0)
    expect(page).to have_css('[data-controller~="topic-keyboard"]', visible: :all)
  end

  describe '? opens / Esc closes' do
    it '? opens the overlay (aria-hidden flips to false)' do
      visit_topic_with_keyboard
      expect(overlay_hidden?).to be true
      press('?')
      expect(overlay_visible?).to be true
    end

    it 'Esc closes the overlay' do
      visit_topic_with_keyboard
      press('?')
      expect(overlay_visible?).to be true
      press(:escape)
      expect(overlay_hidden?).to be true
    end

    it 'Esc with no overlay open is a no-op (does NOT throw)' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press(:escape)
      # No exceptions; overlay still hidden.
      expect(overlay_hidden?).to be true
    end
  end

  describe 'closing affordances' do
    it 'click on the close × button closes the overlay' do
      visit_topic_with_keyboard
      press('?')
      expect(overlay_visible?).to be true
      find('[data-topic-keyboard-target="overlayClose"]').click
      expect(overlay_hidden?).to be true
    end

    it 'click on the backdrop closes the overlay' do
      visit_topic_with_keyboard
      press('?')
      # Click on the overlay surface (not on dialog interior)
      page.execute_script(<<~JS)
        var ov = document.querySelector('[data-topic-keyboard-target="overlay"]');
        var rect = ov.getBoundingClientRect();
        var ev = new MouseEvent('click', {
          bubbles: true, cancelable: true, view: window,
          clientX: rect.left + 5, clientY: rect.top + 5
        });
        ov.dispatchEvent(ev);
      JS
      expect(overlay_hidden?).to be true
    end
  end

  describe 'focus management' do
    it 'first focusable element on open is the close × button' do
      visit_topic_with_keyboard
      press('?')
      active_attr = page.evaluate_script(
        'document.activeElement && document.activeElement.getAttribute("data-topic-keyboard-target")'
      )
      expect(active_attr).to eq('overlayClose')
    end

    it 'body has overflow:hidden while overlay is open' do
      visit_topic_with_keyboard
      press('?')
      overflow = page.evaluate_script('document.body.style.overflow')
      expect(overflow).to eq('hidden')
    end

    it 'on close, body overflow is reset' do
      visit_topic_with_keyboard
      press('?')
      press(:escape)
      overflow = page.evaluate_script('document.body.style.overflow')
      expect(overflow).to eq('')
    end
  end

  describe 'aria attributes on overlay' do
    it 'overlay has aria-modal="true", role="dialog", aria-labelledby="shortcuts-title"' do
      visit_topic_with_keyboard
      expect(page).to have_css(
        '[data-topic-keyboard-target="overlay"][role="dialog"][aria-modal="true"][aria-labelledby="shortcuts-title"]',
        visible: :all
      )
    end
  end

  describe 'shortcut suppression while overlay is open' do
    it 'j is suppressed (no select-module dispatch) when overlay is open' do
      visit_topic_with_keyboard
      press('?')
      reset_event_recorder!
      press('j')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'space is suppressed when overlay is open' do
      visit_topic_with_keyboard
      press('?')
      reset_event_recorder!
      press(:space)
      expect(event_names_for('topic-module:toggle')).to be_empty
    end
  end
end
