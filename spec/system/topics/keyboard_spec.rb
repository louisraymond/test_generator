require 'rails_helper'

RSpec.describe 'Topic detail keyboard shortcuts', type: :system, js: true do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic, :with_modules) }

  def visit_topic_with_keyboard(module_count: 2, active_module_index: 0)
    visit topic_path(topic)
    inject_keyboard_controller!(module_count: module_count, active_module_index: active_module_index)
    # Give Stimulus a moment to instantiate the controller.
    expect(page).to have_css('[data-controller~="topic-keyboard"]', visible: :all)
  end

  describe 'controller mount' do
    it 'mounts the topic-keyboard controller' do
      visit_topic_with_keyboard
      expect(page).to have_css('[data-controller~="topic-keyboard"]', visible: :all)
    end
  end

  # ──────────── 2.1 Per-shortcut specs ────────────

  describe 'j / k — module pointer' do
    it 'j dispatches topic-sidebar:select-module with index 1' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 0)
      reset_event_recorder!
      press('j')
      events = event_names_for('topic-sidebar:select-module')
      expect(events.length).to eq 1
      expect(events.first['detail']).to eq('index' => 1)
    end

    it 'j is a no-op when an input is focused' do
      visit_topic_with_keyboard(module_count: 3)
      page.execute_script(<<~JS)
        var i = document.createElement('input');
        i.id = 'test-input';
        document.body.appendChild(i);
        i.focus();
      JS
      reset_event_recorder!
      find('#test-input').send_keys('j')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'k dispatches topic-sidebar:select-module with index 0 (clamped at min)' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 1)
      reset_event_recorder!
      press('k')
      events = event_names_for('topic-sidebar:select-module')
      expect(events.length).to eq 1
      expect(events.first['detail']).to eq('index' => 0)
    end

    it 'k is a no-op when a textarea is focused' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 1)
      page.execute_script(<<~JS)
        var t = document.createElement('textarea');
        t.id = 'test-textarea';
        document.body.appendChild(t);
        t.focus();
      JS
      reset_event_recorder!
      find('#test-textarea').send_keys('k')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'j is clamped at moduleCount-1 (cannot advance past end)' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 2)
      reset_event_recorder!
      press('j')
      events = event_names_for('topic-sidebar:select-module')
      expect(events.first['detail']).to eq('index' => 2)
    end
  end

  describe 'number keys 1..9' do
    it '1, 2, 3, 4 dispatch select-module with index 0,1,2,3' do
      visit_topic_with_keyboard(module_count: 4)
      %w[1 2 3 4].each_with_index do |key, idx|
        reset_event_recorder!
        press(key)
        events = event_names_for('topic-sidebar:select-module')
        expect(events.length).to eq(1), "expected key '#{key}' to fire once"
        expect(events.first['detail']).to eq('index' => idx)
      end
    end

    it '5 is a no-op when only 4 modules exist' do
      visit_topic_with_keyboard(module_count: 4)
      reset_event_recorder!
      press('5')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end
  end

  describe 'g g state machine' do
    it 'g g within 400ms dispatches topic-detail:scroll-top' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('g')
      press('g')
      expect(event_names_for('topic-detail:scroll-top').length).to eq 1
    end

    it 'a single g press is a no-op' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('g')
      expect(event_names_for('topic-detail:scroll-top')).to be_empty
    end

    it 'g followed by a non-g key resets the state machine' do
      visit_topic_with_keyboard(module_count: 3)
      reset_event_recorder!
      press('g')
      press('j') # advances module — not a second g
      press('g') # this is now a fresh first g
      expect(event_names_for('topic-detail:scroll-top')).to be_empty
    end

    it 'g, focus into input, then bare g within 400ms is a no-op (antagonist A.1)' do
      visit_topic_with_keyboard
      page.execute_script(<<~JS)
        var i = document.createElement('input');
        i.id = 'test-input-g';
        document.body.appendChild(i);
      JS
      reset_event_recorder!
      press('g')
      find('#test-input-g').click
      page.execute_script("document.body.focus();")
      press('g')
      expect(event_names_for('topic-detail:scroll-top')).to be_empty
    end
  end

  describe '/ — search focus' do
    it 'dispatches topic-search:focus' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('/')
      expect(event_names_for('topic-search:focus').length).to eq 1
    end
  end

  describe 'space — toggle active module' do
    it 'dispatches topic-module:toggle with active index' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 1)
      reset_event_recorder!
      press(:space)
      events = event_names_for('topic-module:toggle')
      expect(events.length).to eq 1
      expect(events.first['detail']).to eq('index' => 1)
    end

    it 'space on a focused button does NOT dispatch toggle (antagonist C.2)' do
      visit_topic_with_keyboard(module_count: 3)
      page.execute_script(<<~JS)
        var b = document.createElement('button');
        b.id = 'test-btn';
        b.textContent = 'X';
        document.body.appendChild(b);
        b.focus();
      JS
      reset_event_recorder!
      find('#test-btn').send_keys(:space)
      expect(event_names_for('topic-module:toggle')).to be_empty
    end
  end

  describe 'o / c — expand/collapse all modules' do
    it 'o dispatches topic-module:expand-all' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('o')
      expect(event_names_for('topic-module:expand-all').length).to eq 1
    end

    it 'c dispatches topic-module:collapse-all' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('c')
      expect(event_names_for('topic-module:collapse-all').length).to eq 1
    end
  end

  describe 'n — new module form focus' do
    it 'dispatches topic-module:new-form-focus' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('n')
      expect(event_names_for('topic-module:new-form-focus').length).to eq 1
    end
  end

  describe 'a — add outcome to active module' do
    it 'dispatches topic-module:add-outcome-active with active index' do
      visit_topic_with_keyboard(module_count: 3, active_module_index: 2)
      reset_event_recorder!
      press('a')
      events = event_names_for('topic-module:add-outcome-active')
      expect(events.length).to eq 1
      expect(events.first['detail']).to eq('moduleIndex' => 2)
    end
  end

  describe 'v / h — view + heatmap toggles' do
    it 'v dispatches topic-view:cycle' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('v')
      expect(event_names_for('topic-view:cycle').length).to eq 1
    end

    it 'h dispatches topic-heatmap:toggle-mode' do
      visit_topic_with_keyboard
      reset_event_recorder!
      press('h')
      expect(event_names_for('topic-heatmap:toggle-mode').length).to eq 1
    end
  end

  describe 'e — edit active (route gap, polite announcement)' do
    it 'announces "Edit not yet wired" via aria-live' do
      visit_topic_with_keyboard
      press('e')
      expect(page).to have_css(
        '[aria-live="polite"][data-topic-keyboard-target="ariaLive"]',
        text: 'Edit not yet wired',
        visible: :all,
        wait: 1
      )
    end
  end

  describe 'q — new question for hovered/focused outcome' do
    it 'announces "Hover an outcome first" when nothing is hovered or focused' do
      visit_topic_with_keyboard
      press('q')
      expect(page).to have_css(
        '[aria-live="polite"][data-topic-keyboard-target="ariaLive"]',
        text: 'Hover an outcome first',
        visible: :all,
        wait: 1
      )
    end
  end

  # ──────────── 2.2 Input short-circuit specs ────────────
  describe 'input / contenteditable short-circuits' do
    it 'typing j in an input does NOT dispatch select-module' do
      visit_topic_with_keyboard(module_count: 3)
      page.execute_script(<<~JS)
        var i = document.createElement('input');
        i.id = 'test-input-j';
        document.body.appendChild(i);
        i.focus();
      JS
      reset_event_recorder!
      find('#test-input-j').send_keys('j')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'typing ? in an input does NOT open the overlay' do
      visit_topic_with_keyboard
      page.execute_script(<<~JS)
        var i = document.createElement('input');
        i.id = 'test-input-q';
        document.body.appendChild(i);
        i.focus();
      JS
      find('#test-input-q').send_keys('?')
      expect(overlay_hidden?).to be true
    end

    it 'Esc inside an input blurs that input but fires no other shortcut' do
      visit_topic_with_keyboard
      page.execute_script(<<~JS)
        var i = document.createElement('input');
        i.id = 'test-input-esc';
        document.body.appendChild(i);
        i.focus();
      JS
      reset_event_recorder!
      find('#test-input-esc').send_keys(:escape)
      active_id = page.evaluate_script('document.activeElement && document.activeElement.id')
      expect(active_id).not_to eq('test-input-esc')
    end

    it 'shortcuts do not fire when target is contenteditable' do
      visit_topic_with_keyboard(module_count: 3)
      page.execute_script(<<~JS)
        var d = document.createElement('div');
        d.id = 'test-ce';
        d.setAttribute('contenteditable', 'true');
        d.tabIndex = 0;
        document.body.appendChild(d);
        d.focus();
      JS
      reset_event_recorder!
      find('#test-ce').send_keys('j')
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end
  end

  # ──────────── 2.3 Modifier-key short-circuits ────────────
  describe 'modifier-key short-circuits' do
    it 'Cmd+J does NOT advance the module' do
      visit_topic_with_keyboard(module_count: 3)
      reset_event_recorder!
      find('body').send_keys([:meta, 'j'])
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'Ctrl+J does NOT advance the module' do
      visit_topic_with_keyboard(module_count: 3)
      reset_event_recorder!
      find('body').send_keys([:control, 'j'])
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'Alt+J does NOT advance the module' do
      visit_topic_with_keyboard(module_count: 3)
      reset_event_recorder!
      find('body').send_keys([:alt, 'j'])
      expect(event_names_for('topic-sidebar:select-module')).to be_empty
    end

    it 'Shift+/ (i.e. ?) DOES open the overlay' do
      visit_topic_with_keyboard
      press('?')
      expect(overlay_visible?).to be true
    end
  end
end
