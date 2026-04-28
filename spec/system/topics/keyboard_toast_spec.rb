require 'rails_helper'

RSpec.describe 'Topic detail keyboard first-visit toast', type: :system, js: true do
  before { driven_by(:selenium_chrome_headless) }

  let!(:topic) { create(:topic, :with_modules) }

  def visit_and_inject(clear_flag: true)
    visit topic_path(topic, v2: 1)
    clear_toast_seen_flag! if clear_flag
    inject_keyboard_controller!(module_count: 2, active_module_index: 0)
    expect(page).to have_css('[data-controller~="topic-keyboard"]', visible: :all)
  end

  it 'first visit shows the toast' do
    visit_and_inject
    expect(page).to have_css(
      '[data-topic-keyboard-target="toast"]:not([hidden])',
      visible: :all,
      wait: 1
    )
  end

  it 'click on the toast dismisses it and sets the localStorage flag' do
    visit_and_inject
    expect(page).to have_css('[data-topic-keyboard-target="toast"]:not([hidden])', visible: :all, wait: 1)

    find('[data-topic-keyboard-target="toast"]', visible: :all).click
    expect(page).to have_css('[data-topic-keyboard-target="toast"][hidden]', visible: :all)
    seen = page.evaluate_script("localStorage.getItem('topic-detail:keyboard-toast-seen')")
    expect(seen).to eq('true')
  end

  it 'pressing ? dismisses the toast (and opens the overlay)' do
    visit_and_inject
    expect(page).to have_css('[data-topic-keyboard-target="toast"]:not([hidden])', visible: :all, wait: 1)
    press('?')
    expect(page).to have_css('[data-topic-keyboard-target="toast"][hidden]', visible: :all)
    expect(overlay_visible?).to be true
    seen = page.evaluate_script("localStorage.getItem('topic-detail:keyboard-toast-seen')")
    expect(seen).to eq('true')
  end

  it 'subsequent visits (flag pre-seeded) do NOT show the toast' do
    visit topic_path(topic, v2: 1)
    seed_toast_seen_flag!
    inject_keyboard_controller!(module_count: 2, active_module_index: 0)
    expect(page).to have_css('[data-controller~="topic-keyboard"]', visible: :all)
    # Toast must remain hidden.
    expect(page).to have_css('[data-topic-keyboard-target="toast"][hidden]', visible: :all)
  end
end
