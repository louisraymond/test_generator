require 'rails_helper'

RSpec.describe TopicModule, type: :model do
  describe 'default position' do
    let(:topic) { create(:topic) }

    it 'appends after the highest existing position when none is given' do
      create(:topic_module, topic: topic, position: 4)

      mod = topic.topic_modules.create!(name: 'Appended')

      expect(mod.position).to eq(5)
    end

    it 'starts at 1 for a topic with no modules' do
      mod = topic.topic_modules.create!(name: 'First')

      expect(mod.position).to eq(1)
    end

    it 'keeps an explicit position' do
      mod = topic.topic_modules.create!(name: 'Explicit', position: 0)

      expect(mod.position).to eq(0)
    end

    it 'numbers modules built together on a new topic in order' do
      new_topic = Topic.new(
        name: 'New topic',
        topic_modules_attributes: [{ name: 'First' }, { name: 'Second' }]
      )

      new_topic.save!

      expect(new_topic.topic_modules.reload.pluck(:name, :position)).to eq([['First', 1], ['Second', 2]])
    end
  end
end
