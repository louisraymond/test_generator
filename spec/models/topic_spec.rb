require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe 'validations' do
    it 'requires a name' do
      topic = build(:topic, name: nil)
      expect(topic).not_to be_valid
      expect(topic.errors[:name]).to include("can't be blank")
    end

    it 'validates module_aims is an array of strings' do
      topic = build(:topic, module_aims: [123, nil])
      expect(topic).not_to be_valid
      expect(topic.errors[:module_aims]).to be_present
    end

    it 'validates learning_outcomes shape' do
      topic = build(:topic, learning_outcomes: 'not an array')
      expect(topic).not_to be_valid
      expect(topic.errors[:learning_outcomes]).to be_present
    end

    it 'validates syllabus_outline shape' do
      topic = build(:topic, syllabus_outline: [{ 'title' => 'Unit 1' }]) # missing items
      expect(topic).not_to be_valid
      expect(topic.errors[:syllabus_outline]).to be_present
    end

    it 'validates reference_links is an array of strings' do
      topic = build(:topic, reference_links: [{ bad: true }])
      expect(topic).not_to be_valid
      expect(topic.errors[:reference_links]).to be_present
    end
  end

  describe 'parent_topic_must_be_root' do
    it 'allows a root topic as parent' do
      parent = create(:topic)
      child = build(:topic, parent_topic: parent)
      expect(child).to be_valid
    end

    it 'rejects a subtopic as parent' do
      grandparent = create(:topic)
      parent = create(:topic, parent_topic: grandparent)
      child = build(:topic, parent_topic: parent)
      expect(child).not_to be_valid
      expect(child.errors[:parent_topic_id]).to be_present
    end
  end

  describe '#learning_outcome_sections' do
    it 'returns sections from learning_objectives when present' do
      topic = create(:topic)
      create(:learning_objective, topic: topic, category: 'Knowledge', category_order: 0, position: 0, description: 'Know things')
      create(:learning_objective, topic: topic, category: 'Skills', category_order: 1, position: 0, description: 'Do things')

      sections = topic.learning_outcome_sections
      expect(sections.length).to eq(2)
      expect(sections.first['title']).to eq('Knowledge')
      expect(sections.last['title']).to eq('Skills')
    end

    it 'falls back to JSON learning_outcomes when no objectives exist' do
      topic = create(:topic, learning_outcomes: [
        { 'title' => 'Fallback', 'items' => ['Item 1'] }
      ])
      sections = topic.learning_outcome_sections
      expect(sections.first['title']).to eq('Fallback')
    end
  end

  describe '#replace_learning_objectives!' do
    it 'destroys old objectives and creates new ones' do
      topic = create(:topic)
      create(:learning_objective, topic: topic, category: 'Old', description: 'Old objective')

      topic.replace_learning_objectives!([
        { 'title' => 'New Category', 'items' => ['New objective 1', 'New objective 2'] }
      ])

      expect(topic.learning_objectives.count).to eq(2)
      expect(topic.learning_objectives.first.category).to eq('New Category')
      expect(topic.learning_objectives.first.description).to eq('New objective 1')
    end

    it 'syncs the learning_outcomes JSONB column' do
      topic = create(:topic)
      topic.replace_learning_objectives!([
        { 'title' => 'Synced', 'items' => ['Item A'] }
      ])

      topic.reload
      expect(topic.learning_outcomes).to eq([{ 'title' => 'Synced', 'items' => ['Item A'] }])
    end
  end

  describe 'normalize_learning_objectives callback' do
    it 'assigns category_order and position' do
      topic = build(:topic)
      topic.learning_objectives.build(category: 'Cat A', description: 'Obj 1')
      topic.learning_objectives.build(category: 'Cat A', description: 'Obj 2')
      topic.learning_objectives.build(category: 'Cat B', description: 'Obj 3')
      topic.save!

      objs = topic.learning_objectives.order(:category_order, :position)
      expect(objs[0].category_order).to eq(0)
      expect(objs[0].position).to eq(0)
      expect(objs[1].category_order).to eq(0)
      expect(objs[1].position).to eq(1)
      expect(objs[2].category_order).to eq(1)
      expect(objs[2].position).to eq(0)
    end

    it 'marks blank objectives for destruction' do
      topic = build(:topic)
      topic.learning_objectives.build(category: '', description: '')
      topic.learning_objectives.build(category: 'Valid', description: 'Valid obj')
      topic.save!

      expect(topic.learning_objectives.count).to eq(1)
    end
  end

  describe '#question_total_count' do
    it 'returns the count of associated questions' do
      topic = create(:topic)
      create_list(:question, 3, topic: topic)
      expect(topic.question_total_count).to eq(3)
    end
  end
end
