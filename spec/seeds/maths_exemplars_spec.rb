# frozen_string_literal: true

require 'rails_helper'
require 'support/maths_seed_loader'

RSpec.describe 'Maths exemplars' do
  before(:all) { MathsSeedLoader.load_exemplars! }

  let(:questions) { MathsSeedLoader.exemplar_questions }

  describe 'structural integrity' do
    it 'seeds at least one exemplar' do
      expect(questions.count).to be > 0
    end

    describe 'LaTeX delimiter balance' do
      it 'balances $ delimiters in content and answer' do
        questions.find_each do |q|
          [q.content, q.answer].each do |text|
            without_display = text.to_s.gsub(/\$\$[\s\S]*?\$\$/, '')
            expect(without_display.count('$')).to be_even,
              "Q##{q.id} (#{q.question_type}) odd $ count in: #{text[0..100].inspect}"
          end
        end
      end

      it 'balances curly braces in LaTeX content and answer' do
        questions.find_each do |q|
          text = "#{q.content}\n#{q.answer}"
          expect(text.count('{')).to eq(text.count('}')),
            "Q##{q.id}: {#{text.count('{')}} vs }#{text.count('}')}"
        end
      end
    end

    describe 'composite parts' do
      it 'gives every part positive points' do
        questions.where(question_type: 'composite').find_each do |q|
          parts = q.options['parts']
          expect(parts).to be_an(Array).and(be_present), "Composite Q##{q.id} has no parts"
          parts.each_with_index do |p, idx|
            expect(p['points'].to_i).to be > 0, "Composite Q##{q.id} part #{idx} non-positive points"
          end
        end
      end

      it 'matches parent points against the sum of part points' do
        questions.where(question_type: 'composite').find_each do |q|
          parts_sum = q.options['parts'].sum { |p| p['points'].to_i }
          expect(parts_sum).to eq(q.points),
            "Composite Q##{q.id}: parts sum #{parts_sum} vs parent #{q.points}"
        end
      end
    end

    describe 'topic and source attribution' do
      it 'assigns every exemplar to a topic' do
        expect(questions.where(topic_id: nil)).to be_empty
      end

      it 'assigns every exemplar a source with a non-blank reference' do
        questions.find_each do |q|
          expect(q.source).to be_present, "Q##{q.id} missing source"
          expect(q.source_reference).to match(/\S/), "Q##{q.id} blank source_reference"
        end
      end
    end
  end

  describe 'rendering pipeline', type: :helper do
    include MarkdownHelper

    it 'renders every exemplar through render_markdown without raising or leaking errors' do
      questions.find_each do |q|
        html = render_markdown(q.content) + render_markdown(q.answer)
        expect(html).not_to include('ParseError')
        expect(html).not_to include('katex-error')
      end
    end

    it 'preserves $ delimiters so KaTeX can find them client-side' do
      questions.find_each do |q|
        next unless q.content.include?('$')

        html = render_markdown(q.content)
        expect(html).to include('$'), "Q##{q.id} lost $ delimiters"
        expect(html).not_to include('&#36;'), "Q##{q.id} $ got HTML-escaped"
      end
    end

    it 'does not wrap composite-part math contents in <em> (render_markdown_inline is math-safe)' do
      questions.where(question_type: 'composite').find_each do |q|
        q.options['parts'].each_with_index do |part, idx|
          content = part['content'].to_s
          next unless content.include?('$')

          html = render_markdown_inline(content)
          expect(html).not_to match(/\$[^\$]*<em>/),
            "Composite Q##{q.id} part #{idx} grew <em> inside math"
        end
      end
    end

    describe 'cloze rendering (honest path via ApplicationHelper#render_cloze)', type: :helper do
      include ApplicationHelper

      it 'renders cloze content with blank spans without corrupting inline math' do
        questions.where(question_type: 'cloze').find_each do |q|
          html = render_cloze(q.content)
          expect(html).to include('cloze-blank'), "Q##{q.id} cloze has no blanks rendered"
          expect(html).not_to include('&#36;'), "Q##{q.id} $ escaped in cloze render"
          next unless q.content.include?('$')

          expect(html).to include('$'), "Q##{q.id} cloze lost $ delimiters"
        end
      end
    end
  end

  describe 'figure assets' do
    image_regex = /!\[[^\]]*\]\(([^)]+)\)/
    assets_root = Rails.root.join('app/assets/images')

    it 'resolves every markdown image path to a file under app/assets/images' do
      missing = []
      questions.find_each do |q|
        "#{q.content}\n#{q.answer}".scan(image_regex).flatten.each do |path|
          relative = path.sub(%r{\A/?assets/}, '')
          full = assets_root.join(relative)
          missing << { question_id: q.id, path: path } unless full.exist?
        end
      end
      expect(missing).to be_empty, "Missing figure assets: #{missing.inspect}"
    end

    it 'has at least one exemplar referencing a figure' do
      figure_users = questions.select { |q| "#{q.content}\n#{q.answer}".match?(image_regex) }
      expect(figure_users).not_to be_empty
    end
  end

  describe 'LaTeX-wrapping and cloze hygiene (new structural rules)' do
    it 'wraps any backslash-bearing answer_label in $...$' do
      questions.find_each do |q|
        label = q.answer_label.to_s
        next unless label.include?('\\')

        expect(label).to match(/\A\s*\$.*\$\s*\z/m),
          "Q##{q.id} answer_label contains LaTeX but is not $...$-wrapped: #{label.inspect}"
      end
    end

    it 'wraps any backslash-bearing composite-part answer_label in $...$' do
      questions.where(question_type: 'composite').find_each do |q|
        Array(q.options['parts']).each_with_index do |part, idx|
          label = part['answer_label'].to_s
          next unless label.include?('\\')

          expect(label).to match(/\A\s*\$.*\$\s*\z/m),
            "Composite Q##{q.id} part #{idx} answer_label not $-wrapped: #{label.inspect}"
        end
      end
    end

    it 'keeps $ delimiters fully inside or outside each cloze {{...}} blank (no boundary crossing)' do
      questions.where(question_type: 'cloze').find_each do |q|
        q.content.to_s.scan(/\{\{(.+?)\}\}/).flatten.each do |blank|
          expect(blank.count('$')).to be_even,
            "Q##{q.id} cloze blank has unbalanced $ (delimiter crossing): #{blank.inspect}"
        end
      end
    end
  end
end
