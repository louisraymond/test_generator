# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopicDetailHelper, type: :helper do
  # Fixture: 1 topic, 2 modules, outcomes spread across 3 categories.
  let(:topic) { create(:topic, name: 'Sub-56 Helper Topic') }
  let!(:mod_a) { create(:topic_module, topic: topic, name: 'Module Alpha', position: 0) }
  let!(:mod_b) { create(:topic_module, topic: topic, name: 'Module Beta',  position: 1) }

  let!(:lo_a1) do
    create(:learning_objective,
           topic: topic, topic_module: mod_a,
           category: 'Quanta',  category_order: 0, position: 0,
           description: 'Explain Schrödinger equation')
  end
  let!(:lo_a2) do
    create(:learning_objective,
           topic: topic, topic_module: mod_a,
           category: 'Heat',    category_order: 1, position: 0,
           description: 'Define entropy')
  end
  let!(:lo_b1) do
    create(:learning_objective,
           topic: topic, topic_module: mod_b,
           category: 'Quanta',  category_order: 0, position: 1,
           description: 'Compute eigenvalues')
  end
  let!(:lo_b2) do
    create(:learning_objective,
           topic: topic, topic_module: mod_b,
           category: 'Atoms',   category_order: 2, position: 0,
           description: 'Describe Bohr model')
  end

  describe '#topic_outcomes_grouped_by_category' do
    subject(:grouped) { helper.topic_outcomes_grouped_by_category(topic) }

    it 'groups outcomes by category sorted alphabetically (case-insensitive)' do
      categories = grouped.map(&:first)
      expect(categories).to eq(%w[Atoms Heat Quanta])
    end

    it 'tags every outcome with its source-module index (1-based)' do
      quanta_rows = grouped.find { |cat, _| cat == 'Quanta' }.last
      module_indexes = quanta_rows.map { |row| row[:module_idx] }
      expect(module_indexes).to contain_exactly(1, 2)
    end

    it 'preserves the LO record itself in each row' do
      atoms_rows = grouped.find { |cat, _| cat == 'Atoms' }.last
      expect(atoms_rows.first[:lo]).to eq(lo_b2)
    end

    it 'returns an Array of [category, rows] pairs (Enumerable contract)' do
      expect(grouped).to be_an(Array)
      expect(grouped.first).to be_an(Array)
      expect(grouped.first.size).to eq(2)
    end
  end

  describe '#topic_outcomes_flat' do
    it 'defaults to topic order (category_order, position, id)' do
      flat = helper.topic_outcomes_flat(topic)
      expect(flat.map { |r| r[:lo] }).to eq([lo_a1, lo_b1, lo_a2, lo_b2])
    end

    it 'tags rows with module_idx and topic_order' do
      flat = helper.topic_outcomes_flat(topic)
      first = flat.first
      expect(first).to include(:lo, :module_idx, :topic_order)
      expect(first[:topic_order]).to eq(0)
      expect(first[:module_idx]).to be_in([1, 2])
    end

    it 'sorts by alpha when requested' do
      flat = helper.topic_outcomes_flat(topic, sort: :alpha)
      descriptions = flat.map { |r| r[:lo].description.downcase }
      expect(descriptions).to eq(descriptions.sort)
    end

    it 'sorts by Nq descending and ascending' do
      # Give one LO three questions, another one — leaves the rest at zero.
      create_list(:question, 3, topic: topic).each do |q|
        q.learning_objectives << lo_a1
      end
      q_one = create(:question, topic: topic)
      q_one.learning_objectives << lo_b2

      desc = helper.topic_outcomes_flat(topic, sort: :nq_desc)
      expect(desc.first[:lo]).to eq(lo_a1)
      expect(desc.first[:lo].questions.size).to eq(3)

      asc = helper.topic_outcomes_flat(topic, sort: :nq_asc)
      # First LO in asc has size 0; lo_a1 (size 3) is last
      expect(asc.last[:lo]).to eq(lo_a1)
    end
  end
end
