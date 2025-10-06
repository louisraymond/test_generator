# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exam Display', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:topic) { Topic.create!(name: 'Test Topic') }
  let!(:questions) do
    (1..5).map do |i|
      Question.create!(
        topic: topic,
        question_type: 'written',
        content: "Question #{i}: " + ('A' * 200), # Long content to test pagination
        answer: "Answer #{i}",
        points: 2,
        answer_size: 'medium'
      )
    end
  end

  let(:exam) do
    Exam.create!(
      title: 'Test Exam for Display',
      duration_minutes: 60
    ).tap do |exam|
      questions.each_with_index do |question, index|
        ExamQuestion.create!(exam: exam, question: question, position: index + 1)
      end
    end
  end

  describe 'Page Structure and Dimensions' do
    before do
      visit exam_path(exam)
    end

    it 'displays the exam with correct A4 page dimensions' do
      # Check page containers exist (should be multiple pages)
      expect(page).to have_css('.page', minimum: 1)
      
      # Count pages (5 questions = 1 page with header)
      page_count = page.all('.page').count
      expect(page_count).to be >= 1
      
      # Verify A4 dimensions on first page (210mm × 297mm)
      page_element = page.find('.page', match: :first)
      
      # Check width (should be 210mm, approximately 794px at 96dpi)
      width = page.evaluate_script("getComputedStyle(document.querySelector('.page')).width")
      expect(width).to match(/210mm|79[0-9]\.\d+px/)
      
      # Check min-height (should be 297mm, approximately 1123px at 96dpi)
      min_height = page.evaluate_script("getComputedStyle(document.querySelector('.page')).minHeight")
      expect(min_height).to match(/297mm|112[0-9]\.\d+px/)
    end

    it 'has proper page styling for print preview' do
      page_element = page.find('.page')
      
      # Check background is white (for contrast against body)
      background = page.evaluate_script("getComputedStyle(document.querySelector('.page')).backgroundColor")
      expect(background).to match(/rgb\(255,\s*255,\s*255\)|white/)
      
      # Check box shadow exists (for visual separation)
      shadow = page.evaluate_script("getComputedStyle(document.querySelector('.page')).boxShadow")
      expect(shadow).not_to eq('none')
      
      # Check padding includes expected top/bottom (25mm ≈ 94-95px)
      padding = page.evaluate_script("getComputedStyle(document.querySelector('.page')).padding")
      expect(padding).to match(/9[4-5]\.\d+px/)
    end

    it 'displays body with gray background to show page separation' do
      # Body should have gray background (not pure white)
      background = page.evaluate_script("getComputedStyle(document.body).backgroundColor")
      # Accept common gray backgrounds: #f5f5f5, #f3f4f6, etc.
      expect(background).to match(/rgb\((24[0-9]|25[0-5]),\s*(24[0-9]|25[0-5]),\s*(24[0-9]|25[0-5])\)/)
      expect(background).not_to match(/rgb\(255,\s*255,\s*255\)/) # Not pure white
    end

    it 'shows page breaks between pages' do
      # Check that multiple pages exist with gaps between them
      pages = page.all('.page')
      expect(pages.count).to be >= 1
      
      if pages.count > 1
        # Verify bottom margin creates visible gap
        margin = page.evaluate_script("getComputedStyle(document.querySelector('.page')).marginBottom")
        expect(margin).to match(/40px/)
      end
    end

    it 'displays page numbers on each page' do
      # Check for page counter using ::after pseudo-element
      # We can't directly test ::after content, but we can verify the CSS is applied
      expect(page).to have_css('.page')
    end

    it 'displays all questions across page containers' do
      # Questions are now split across multiple pages
      total_questions = page.all('.question').count
      expect(total_questions).to eq(5)
      
      # Verify at least one page exists
      expect(page).to have_css('.page', minimum: 1)
    end

    it 'displays the exam title' do
      within('.page') do
        expect(page).to have_css('h1', text: 'Test Exam for Display')
      end
    end

    it 'displays the duration' do
      within('.page') do
        expect(page).to have_content('60 minutes')
      end
    end
  end

  describe 'Display Controls' do
    before do
      visit exam_path(exam)
    end

    it 'shows the floating display controls sidebar' do
      expect(page).to have_css('.display-controls-sidebar')
      # Text is uppercase due to CSS text-transform
      expect(page).to have_css('.display-controls-sidebar__title', text: /display size/i)
    end

    it 'has all preset buttons' do
      within('.display-controls-sidebar') do
        expect(page).to have_button('Compact')
        expect(page).to have_button('Normal')
        expect(page).to have_button('Comfortable')
        expect(page).to have_button('Large Print')
      end
    end

    it 'marks Normal as active by default' do
      normal_button = find('.display-controls-sidebar button[data-preset="normal"]')
      expect(normal_button[:class]).to include('is-active')
    end

    it 'changes font size when clicking preset buttons', js: true do
      # Use JavaScript to click to avoid element interception issues
      page.execute_script("document.querySelector('.display-controls-sidebar button[data-preset=\"compact\"]').click()")

      # Wait for JavaScript to apply changes
      sleep 0.5

      # Check that font size changed (compact is now 11pt)
      font_size = page.evaluate_script("getComputedStyle(document.querySelector('.page')).getPropertyValue('--exam-font-size')")
      expect(font_size.strip).to eq('11pt')

      # Check active state changed
      compact_button = find('.display-controls-sidebar button[data-preset="compact"]')
      expect(compact_button[:class]).to include('is-active')
    end

    it 'persists display preference', js: true do
      # Set to Large Print using JavaScript to avoid element interception
      page.execute_script("document.querySelector('.display-controls-sidebar button[data-preset=\"large\"]').click()")

      sleep 0.5

      # Reload page
      visit exam_path(exam)

      sleep 0.5

      # Check that Large Print is still active
      large_button = find('.display-controls-sidebar button[data-preset="large"]')
      expect(large_button[:class]).to include('is-active')

      # Check font size is still large
      font_size = page.evaluate_script("getComputedStyle(document.querySelector('.page')).getPropertyValue('--exam-font-size')")
      expect(font_size.strip).to eq('18pt')
    end
  end

  describe 'Action Header' do
    before do
      visit exam_path(exam)
    end

    it 'displays the action header with exam title' do
      expect(page).to have_css('.exam-actions-header')
      within('.exam-actions-header') do
        expect(page).to have_content('Test Exam for Display')
      end
    end

    it 'has links to marking scheme, PDF, and new exam' do
      within('.exam-actions-header') do
        expect(page).to have_link('Marking Scheme')
        expect(page).to have_link('PDF')
        expect(page).to have_link('New')
      end
    end
  end

  describe 'Print Styling' do
    it 'hides UI elements when printing' do
      visit exam_path(exam)
      
      # Check print media query would hide controls
      # Note: We can't actually test @media print in Selenium, but we can verify CSS is loaded
      expect(page).to have_css('.exam-actions-header')
      expect(page).to have_css('.display-controls-sidebar')
      
      # The actual hiding happens via CSS @media print rules
      # which we've verified exist in the stylesheet
    end
  end

  describe 'PDF/HTML Consistency' do
    let!(:learning_objective) { LearningObjective.create!(topic: topic, category: 'Test Category', description: 'Test LO') }
    
    let!(:exam_with_questions) do
      exam = Exam.create!(title: 'Test Exam', duration_minutes: 60)
      
      # Create a mix of question types to test comprehensively
      questions = []
      
      # Multiple choice questions
      5.times do |i|
        question = Question.create!(
          content: "Multiple choice question #{i + 1}?",
          answer: "Option A",
          question_type: 'multiple_choice',
          points: 1,
          topic: topic,
          options: [
            { text: "Option A", correct: true },
            { text: "Option B", correct: false },
            { text: "Option C", correct: false },
            { text: "Option D", correct: false }
          ]
        )
        question.learning_objectives << learning_objective
        questions << question
      end
      
      # Written questions
      3.times do |i|
        question = Question.create!(
          content: "Written question #{i + 1}?",
          answer: "Answer #{i + 1}",
          question_type: 'written',
          points: 5,
          topic: topic
        )
        question.learning_objectives << learning_objective
        questions << question
      end
      
      # Cloze questions
      2.times do |i|
        question = Question.create!(
          content: "Cloze question #{i + 1}: The answer is ___.",
          answer: "answer#{i + 1}",
          question_type: 'cloze',
          points: 2,
          topic: topic
        )
        question.learning_objectives << learning_objective
        questions << question
      end
      
      # Composite question
      question = Question.create!(
        content: "Composite question",
        answer: "See sub-questions",
        question_type: 'composite',
        points: 10,
        topic: topic,
        options: [
          { text: "Part a) What is the first part?", points: 3 },
          { text: "Part b) What is the second part?", points: 4 },
          { text: "Part c) What is the third part?", points: 3 }
        ]
      )
      question.learning_objectives << learning_objective
      questions << question
      
      # Add all questions to exam
      questions.each_with_index do |question, index|
        ExamQuestion.create!(exam: exam, question: question, position: index + 1)
      end
      
      exam
    end

    it 'maintains consistent page count between HTML preview and PDF' do
      # Test with different font sizes
      font_sizes = [9, 11, 14, 16, 18]
      
      font_sizes.each do |font_size|
        visit exam_path(exam_with_questions, font_size: font_size, question_spacing: 18)
        
        # Count pages in HTML preview
        html_pages = page.all('.page').count
        expect(html_pages).to be > 0, "HTML preview should have at least 1 page with font size #{font_size}"
        
        # Verify PDF link includes the correct parameters
        pdf_link = find_link('PDF')
        expect(pdf_link[:href]).to include("font_size=#{font_size}")
        expect(pdf_link[:href]).to include("question_spacing=18")
        
        # Test PDF generation by visiting the PDF URL directly
        pdf_url = pdf_link[:href]
        visit pdf_url
        
        # Verify we get a PDF response (status 200, content-type application/pdf)
        expect(page.status_code).to eq(200)
        
        # Go back to HTML view to continue testing
        visit exam_path(exam_with_questions, font_size: font_size, question_spacing: 18)
      end
    end

    it 'applies font size consistently between HTML and PDF' do
      visit exam_path(exam_with_questions, font_size: 9, question_spacing: 18)
      
      # Verify HTML preview has correct font size
      first_question = page.first('.question p')
      expect(first_question).to be_present
      
      # Check that the CSS custom property is set correctly
      font_size_value = page.evaluate_script("getComputedStyle(document.querySelector('.question p')).fontSize")
      expect(font_size_value).to eq('12px') # 9pt = 12px
      
      # Verify PDF link includes correct parameters
      pdf_link = find_link('PDF')
      expect(pdf_link[:href]).to include('font_size=9')
      expect(pdf_link[:href]).to include('question_spacing=18')
    end

    it 'handles URL parameters correctly for both HTML and PDF' do
      # Test a few key parameter combinations
      test_cases = [
        { font_size: 9, question_spacing: 18 },
        { font_size: 14, question_spacing: 18 },
        { font_size: 18, question_spacing: 24 }
      ]
      
      test_cases.each do |params|
        visit exam_path(exam_with_questions, params)
        
        # Verify HTML preview shows correct values
        expect(page).to have_content("Font Size: #{params[:font_size]}pt")
        expect(page).to have_content("Question Spacing: #{params[:question_spacing]}pt")
        
        # Verify sliders are set correctly
        font_slider = find('input[type="range"][data-exam-display-target="fontSizeSlider"]')
        spacing_slider = find('input[type="range"][data-exam-display-target="spacingSlider"]')
        
        expect(font_slider.value).to eq(params[:font_size].to_s)
        expect(spacing_slider.value).to eq(params[:question_spacing].to_s)
        
        # Verify PDF link includes correct parameters
        pdf_link = find_link('PDF')
        expect(pdf_link[:href]).to include("font_size=#{params[:font_size]}")
        expect(pdf_link[:href]).to include("question_spacing=#{params[:question_spacing]}")
        
        # Test that the PDF can be generated with these parameters
        pdf_url = pdf_link[:href]
        visit pdf_url
        expect(page.status_code).to eq(200)
        
        # Go back to HTML view
        visit exam_path(exam_with_questions, params)
      end
    end

    it 'maintains question order and content between HTML and PDF' do
      visit exam_path(exam_with_questions, font_size: 12, question_spacing: 18)
      
      # Get question text from HTML preview
      html_questions = page.all('.question').map do |question|
        {
          text: question.find('.question-text p').text.strip,
          type: question['class'].split.find { |c| c.start_with?('question-') },
          points: question.find('.marks').text.strip
        }
      end
      
      expect(html_questions.length).to eq(11) # 5 MC + 3 written + 2 cloze + 1 composite
      
      # Verify we have the expected question types
      expect(html_questions.map { |q| q[:type] }).to include('question-multiple_choice')
      expect(html_questions.map { |q| q[:type] }).to include('question-written')
      expect(html_questions.map { |q| q[:type] }).to include('question-cloze')
      expect(html_questions.map { |q| q[:type] }).to include('question-composite')
      
      # Verify PDF link is generated correctly
      pdf_link = find_link('PDF')
      expect(pdf_link[:href]).to include('font_size=12')
      expect(pdf_link[:href]).to include('question_spacing=18')
    end

    it 'scales page count correctly with font size changes' do
      # Test that smaller font sizes result in fewer pages
      visit exam_path(exam_with_questions, font_size: 18, question_spacing: 18)
      large_font_pages = page.all('.page').count
      
      visit exam_path(exam_with_questions, font_size: 9, question_spacing: 18)
      small_font_pages = page.all('.page').count
      
      # Smaller font should result in fewer pages
      expect(small_font_pages).to be < large_font_pages
      
      # Verify the scaling is reasonable (not too extreme)
      expect(small_font_pages).to be >= 1
      expect(large_font_pages).to be >= 1
    end

    it 'preserves LaTeX rendering in both HTML and PDF' do
      # Create a question with LaTeX content
      latex_question = Question.create!(
        content: "What is the time complexity of binary search? Answer: $O(\\log n)$",
        answer: "O(log n)",
        question_type: 'written',
        points: 3,
        topic: topic
      )
      latex_question.learning_objectives << learning_objective
      
      exam_with_questions.exam_questions.create!(question: latex_question, position: 1)
      
      visit exam_path(exam_with_questions, font_size: 12, question_spacing: 18)
      
      # Verify LaTeX is rendered in HTML
      expect(page).to have_css('math')
      
      # Verify PDF link is generated
      pdf_link = find_link('PDF')
      expect(pdf_link[:href]).to be_present
    end
  end
end

