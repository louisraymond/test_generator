require 'rails_helper'

RSpec.describe 'code_analysis form', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:topic) { create(:topic, name: 'Ruby on Rails (spec topic)') }

  def fill_in_shared_fields
    select topic.name, from: 'Topic'
    select 'Code analysis', from: 'Question type'
    fill_in 'Question prompt', with: 'What does this function return?'
    fill_in 'Model answer', with: 'The nth Fibonacci number.'
    fill_in 'Points', with: '2'
  end

  describe 'creating a lines-variant question' do
    it 'persists with the right options JSON' do
      visit new_question_path
      fill_in_shared_fields

      fill_in 'ca-language', with: 'python'
      fill_in 'ca-code', with: "def fib(n):\n    return n if n < 2 else fib(n-1) + fib(n-2)"
      choose 'Ruled lines (prose answer)'

      click_button 'Create Question'
      expect(page).to have_content('Question created successfully')

      q = Question.last
      expect(q.question_type).to eq('code_analysis')
      expect(q.options['language']).to eq('python')
      expect(q.options['code']).to include('fib')
      expect(q.options['answer_format']).to eq('lines')
      expect(q.options).not_to have_key('choices')
    end
  end

  describe 'creating a multiple_choice-variant question' do
    it 'shows the choices builder only when MC is selected, and persists with choices' do
      visit new_question_path
      fill_in_shared_fields

      fill_in 'ca-language', with: 'ruby'
      fill_in 'ca-code', with: "def names(users)\n  users.map(&:name).uniq\nend"

      # Before MC is chosen, the Choices section must be hidden.
      expect(page).to have_css('.ca-choices-section[hidden]', visible: :all)

      choose 'Multiple choice'
      expect(page).not_to have_css('.ca-choices-section[hidden]', visible: :all)

      # Two rows by default; add a third.
      within('.ca-choices-section') do
        expect(page).to have_css('.mc-option-row', count: 2)
        click_button 'Add choice'
        expect(page).to have_css('.mc-option-row', count: 3)
      end

      # Fill the three rows. First-match on textarea by label.
      rows = all('.ca-choices-section .mc-option-row')
      rows[0].fill_in('Choice A', with: 'Sorted names')
      rows[1].fill_in('Choice B', with: 'Unique names from the collection')
      rows[1].find('input[type="checkbox"]').check
      rows[2].fill_in('Choice C', with: 'Raises NoMethodError')

      click_button 'Create Question'
      expect(page).to have_content('Question created successfully')

      q = Question.last
      expect(q.options['answer_format']).to eq('multiple_choice')
      expect(q.options['choices'].length).to eq(3)
      expect(q.options['choices'].count { |c| c['correct'] }).to eq(1)
      expect(q.options['choices'].find { |c| c['correct'] }['text']).to include('Unique')
    end
  end

  describe 'editing an existing code_analysis question' do
    let!(:existing) do
      create(:question,
             topic: topic,
             question_type: 'code_analysis',
             options: {
               'language' => 'python',
               'code' => 'print("old")',
               'answer_format' => 'lines'
             })
    end

    it 'pre-populates the form fields' do
      visit edit_question_path(existing)
      expect(page).to have_field('ca-language', with: 'python')
      expect(page).to have_field('ca-code', with: 'print("old")')
      expect(page).to have_checked_field('Ruled lines (prose answer)', visible: :all)
    end
  end
end
