# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Topic heat-map', type: :system, js: true do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:topic) { create(:topic, name: 'Mechanics') }
  let(:source) { create(:source) }
  let!(:mod_a) { create(:topic_module, topic: topic, name: 'Module A', position: 0) }
  let!(:mod_b) { create(:topic_module, topic: topic, name: 'Module B', position: 1) }

  let!(:lo_a1) do
    create(:learning_objective, topic: topic, topic_module: mod_a, position: 0,
                                category: 'Forces', description: 'Newton')
  end
  let!(:lo_a2) do
    create(:learning_objective, topic: topic, topic_module: mod_a, position: 1,
                                category: 'Energy', description: 'Conservation')
  end
  let!(:lo_b1) do
    create(:learning_objective, topic: topic, topic_module: mod_b, position: 0,
                                category: 'Optics', description: 'Refraction')
  end

  before do
    # Coverage counts
    2.times do |i|
      q = create(:question, topic: topic, source: source,
                            content: "Qa1-#{i}", answer: 'a', points: 1,
                            answer_size: 'short', question_type: 'written')
      QuestionLearningObjective.create!(question: q, learning_objective: lo_a1)
    end
    100.times do |i|
      q = create(:question, topic: topic, source: source,
                            content: "Qa2-#{i}", answer: 'a', points: 1,
                            answer_size: 'short', question_type: 'written')
      QuestionLearningObjective.create!(question: q, learning_objective: lo_a2)
    end
    # lo_b1 has 0 questions
  end

  let(:exam_usage) do
    { lo_a1.id => 1, lo_a2.id => 5, lo_b1.id => 7 }
  end

  def visit_heatmap
    visit "/spec_support/topic_heatmap/#{topic.id}?exam_usage=#{CGI.escape(exam_usage.to_json)}"
  end

  it 'defaults to coverage mode with the title and selected tab' do
    visit_heatmap
    expect(page).to have_css('section.topic-heatmap[data-mode="coverage"]')
    within('section.topic-heatmap') do
      expect(page).to have_css('button[role="tab"][data-topic-heatmap-mode-param="coverage"][aria-selected="true"]')
      expect(page).to have_css('button[role="tab"][data-topic-heatmap-mode-param="utilization"][aria-selected="false"]')
      expect(page).to have_text('Question coverage')
    end
  end

  it 'switches to utilization mode on tab click — flips title, summary and aria-selected' do
    visit_heatmap
    find('button[role="tab"][data-topic-heatmap-mode-param="utilization"]').click

    expect(page).to have_css('section.topic-heatmap[data-mode="utilization"]')
    within('section.topic-heatmap') do
      expect(page).to have_css('button[role="tab"][data-topic-heatmap-mode-param="utilization"][aria-selected="true"]')
      expect(page).to have_css('button[role="tab"][data-topic-heatmap-mode-param="coverage"][aria-selected="false"]')
      expect(page).to have_text('Exam utilization')
      expect(page).to have_text(/13 appearances\s*·\s*0 outcomes never used/)
    end
  end

  it 'dispatches topic-heatmap:mode-changed with detail.mode' do
    visit_heatmap
    page.execute_script <<~JS
      window.__heatmapEvents = []
      document.addEventListener('topic-heatmap:mode-changed', (e) => {
        window.__heatmapEvents.push(e.detail)
      })
    JS

    find('button[role="tab"][data-topic-heatmap-mode-param="utilization"]').click
    # Wait until the section actually flips before reading the array
    expect(page).to have_css('section.topic-heatmap[data-mode="utilization"]')

    events = page.evaluate_script('window.__heatmapEvents')
    expect(events).to include({ 'mode' => 'utilization' })
  end

  it 'cell click dispatches topic-heatmap:focus-lo with { loId }' do
    visit_heatmap
    page.execute_script <<~JS
      window.__focusEvents = []
      document.addEventListener('topic-heatmap:focus-lo', (e) => {
        window.__focusEvents.push(e.detail)
      })
    JS

    first_cell = first('button.topic-heatmap__cell')
    target_lo_id = first_cell['data-cell-lo-id'].to_i
    first_cell.click

    # Slight wait for the rAF dispatch
    expect(page).to have_css('section.topic-heatmap')
    events = page.evaluate_script('window.__focusEvents')
    expect(events.last).to include('loId' => target_lo_id)
  end

  it 'clamps cells with > 99 questions to "99+" but keeps the exact integer in the title' do
    visit_heatmap
    cell = find("button.topic-heatmap__cell[data-cell-lo-id='#{lo_a2.id}']")
    expect(cell.text.strip).to eq('99+')
    expect(cell['title']).to include('100 questions')
  end

  it 'reduced-motion CSS rule is present in the cascade' do
    visit_heatmap
    # Existence-assertion strategy from Plan §5 OQ3.
    css_text = page.evaluate_script(<<~JS)
      Array.from(document.styleSheets).flatMap((s) => {
        try { return Array.from(s.cssRules).map((r) => r.cssText) } catch (_e) { return [] }
      }).join('\\n')
    JS
    expect(css_text).to match(/prefers-reduced-motion: reduce/)
    expect(css_text).to match(/topic-heatmap__cell[^\{]*\{[^}]*transition: none/m).or match(/topic-heatmap__cell\b[\s\S]*?transition: none/)
  end
end
