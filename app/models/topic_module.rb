class TopicModule < ApplicationRecord
  belongs_to :topic
  has_many :learning_objectives, dependent: :destroy
  has_many :questions, dependent: :destroy

  before_validation :append_to_topic, on: :create, if: -> { position.nil? && topic }

  validates :name, presence: true, uniqueness: { scope: :topic_id, message: "already exists for this topic" }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(position: :asc) }

  def categories
    learning_objectives.pluck(:category).compact.uniq.sort
  end

  private

  # position is NOT NULL but the topic form and the module API don't send one.
  # Reading siblings off the in-memory association numbers modules built
  # together on an unsaved topic 1, 2, 3 instead of all 1.
  def append_to_topic
    self.position = (topic.topic_modules.filter_map(&:position).max || 0) + 1
  end
end
