require 'rails_helper'

RSpec.describe TopicDetailHelper, type: :helper do
  describe '#module_collapsed_default?' do
    let(:mod) { build_stubbed(:topic_module) }

    it 'returns false for the first module (idx 0)' do
      expect(helper.module_collapsed_default?(mod, 0)).to be false
    end

    it 'returns true for idx >= 1' do
      expect(helper.module_collapsed_default?(mod, 1)).to be true
      expect(helper.module_collapsed_default?(mod, 5)).to be true
    end
  end

  describe '#category_grouping' do
    let(:topic) { create(:topic) }
    let(:mod)   { create(:topic_module, topic: topic) }

    it 'groups LOs by category, sorted alphabetically by category' do
      lo_b = create(:learning_objective, topic: topic, topic_module: mod, category: 'Beta',  position: 0)
      lo_a = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 0)
      lo_c = create(:learning_objective, topic: topic, topic_module: mod, category: 'Gamma', position: 0)

      mod.reload
      grouping = helper.category_grouping(mod)
      categories = grouping.map(&:first)
      expect(categories).to eq(%w[Alpha Beta Gamma])
      # contains references back
      _ = [lo_a, lo_b, lo_c]
    end

    it 'preserves position order within a category' do
      first  = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 0, description: 'first')
      second = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 1, description: 'second')
      third  = create(:learning_objective, topic: topic, topic_module: mod, category: 'Alpha', position: 2, description: 'third')
      mod.reload

      grouping = helper.category_grouping(mod)
      _, los = grouping.first
      expect(los.map(&:description)).to eq(%w[first second third])
      _ = [first, second, third]
    end
  end

  describe '#lo_chip_html' do
    let(:topic) { create(:topic) }
    let(:lo)    { create(:learning_objective, topic: topic) }

    def render_chip(lo, exam_usage: {}, mode: 'questions')
      Capybara.string(helper.lo_chip_html(lo, exam_usage: exam_usage, mode: mode))
    end

    it 'renders <span class="topic-detail__chip" data-questions data-usage>' do
      html = render_chip(lo)
      chip = html.find('.topic-detail__chip')
      expect(chip['data-questions']).to eq('0')
      expect(chip['data-usage']).to eq('0')
    end

    it 'applies bucket-zero (dashed) class when questionCount == 0' do
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--zero')
    end

    it 'applies bucket-1 colour for n == 1' do
      create(:question, topic: topic, learning_objectives: [lo])
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b1')
    end

    it 'applies bucket-2 colour for n == 2' do
      2.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b2')
    end

    it 'applies bucket-3 colour for n == 4' do
      4.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b3')
    end

    it 'applies bucket-4 colour for n == 7' do
      7.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      expect(render_chip(lo)).to have_css('.topic-detail__chip.topic-detail__chip--b4')
    end

    it 'sets aria-label "{n} questions" in questions mode' do
      3.times { create(:question, topic: topic, learning_objectives: [lo]) }
      lo.reload
      chip = render_chip(lo).find('.topic-detail__chip')
      expect(chip['aria-label']).to eq('3 questions')
    end

    it 'embeds data-usage attribute pulled from the exam_usage map' do
      chip = render_chip(lo, exam_usage: { lo.id => 4 }).find('.topic-detail__chip')
      expect(chip['data-usage']).to eq('4')
    end

    it 'shows usage text "{n}x" in usage mode and updates aria-label accordingly' do
      chip = render_chip(lo, exam_usage: { lo.id => 5 }, mode: 'usage').find('.topic-detail__chip')
      expect(chip.text).to eq('5x')
      expect(chip['aria-label']).to eq('5 exam uses')
    end
  end
end
