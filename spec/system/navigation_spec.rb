require 'rails_helper'

RSpec.describe 'Navigation', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'Hamburger Menu' do
    it 'opens when clicking the toggle button' do
      visit root_path

      # Menu should be closed initially
      expect(page).to have_css('button[aria-expanded="false"]')
      expect(page).not_to have_css('.app-nav.is-open')

      # Click hamburger to open
      find('button', text: 'Toggle navigation').click

      # Menu should be open
      expect(page).to have_css('button[aria-expanded="true"]')
      expect(page).to have_css('.app-nav.is-open')
      expect(page).to have_css('.nav-backdrop.is-visible')
    end

    it 'closes when clicking the toggle button again' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click
      expect(page).to have_css('button[aria-expanded="true"]')

      # Close menu
      find('button', text: 'Toggle navigation').click

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
      expect(page).not_to have_css('.app-nav.is-open')
      expect(page).not_to have_css('.nav-backdrop.is-visible')
    end

    it 'closes when clicking the backdrop' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click
      expect(page).to have_css('.nav-backdrop.is-visible')

      # Click backdrop
      find('.nav-backdrop').click

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
      expect(page).not_to have_css('.app-nav.is-open')
    end

    it 'closes when pressing Escape key' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click
      expect(page).to have_css('button[aria-expanded="true"]')

      # Press Escape
      find('body').send_keys(:escape)

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
      expect(page).not_to have_css('.app-nav.is-open')
    end
  end

  describe 'Navigation Links' do
    before do
      # Create some test data
      @topic = Topic.create!(name: 'Test Topic')
      @question = Question.create!(
        topic: @topic,
        question_type: 'written',
        content: 'Test question',
        answer: 'Test answer',
        points: 1
      )
    end

    it 'navigates to Exam Generator page' do
      visit topics_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Click Exam Generator link
      within('.app-nav') do
        click_link 'Exam Generator'
      end

      # Should navigate to root path
      expect(page).to have_current_path(root_path)
      expect(page).to have_css('h1', text: 'Generate Exam')

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
    end

    it 'navigates to Topics page' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Click Topics link
      within('.app-nav') do
        click_link 'Topics'
      end

      # Should navigate to topics path
      expect(page).to have_current_path(topics_path)
      expect(page).to have_css('h1', text: 'Topics')

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
    end

    it 'navigates to Question Bank page' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Click Question Bank link
      within('.app-nav') do
        click_link 'Question Bank'
      end

      # Should navigate to questions path
      expect(page).to have_current_path(questions_path)
      expect(page).to have_css('h1', text: 'Question Library')

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
    end
  end

  describe 'Active Page Highlighting' do
    before do
      @topic = Topic.create!(name: 'Test Topic')
    end

    it 'highlights the current page in navigation' do
      visit topics_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Topics link should be active
      within('.app-nav') do
        expect(page).to have_css('a.app-nav__link.is-active', text: 'Topics')
      end
    end

    it 'highlights Exam Generator on root path' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Exam Generator link should be active
      within('.app-nav') do
        expect(page).to have_css('a.app-nav__link.is-active', text: 'Exam Generator')
      end
    end

    it 'highlights Question Bank on questions path' do
      visit questions_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Question Bank link should be active
      within('.app-nav') do
        expect(page).to have_css('a.app-nav__link.is-active', text: 'Question Bank')
      end
    end
  end

  describe 'Logo Link' do
    it 'navigates to home page when clicking logo' do
      visit topics_path

      # Click logo
      within('.app-header') do
        click_link 'Exam Generator'
      end

      # Should navigate to root path
      expect(page).to have_current_path(root_path)
    end

    it 'closes menu when clicking logo' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click
      expect(page).to have_css('button[aria-expanded="true"]')

      # Click logo
      within('.app-header') do
        click_link 'Exam Generator'
      end

      # Menu should be closed
      expect(page).to have_css('button[aria-expanded="false"]')
    end
  end

  describe 'Z-Index Stacking' do
    it 'allows clicks on navigation links when menu is open' do
      visit root_path

      # Open menu
      find('button', text: 'Toggle navigation').click

      # Navigation links should be clickable (not intercepted by backdrop)
      within('.app-nav') do
        expect(page).to have_link('Topics', visible: :visible)
        
        # This should not timeout or be intercepted
        click_link 'Topics', wait: 2
      end

      # Should successfully navigate
      expect(page).to have_current_path(topics_path)
    end
  end

  describe 'Responsive Behavior' do
    it 'displays hamburger menu on all screen sizes' do
      visit root_path

      # Hamburger should always be visible
      expect(page).to have_css('.menu-toggle', visible: :visible)
      expect(page).to have_button('Toggle navigation')
    end
  end
end
