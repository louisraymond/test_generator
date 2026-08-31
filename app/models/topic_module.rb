class TopicModule < ApplicationRecord
  belongs_to :topic
  has_many :learning_objectives, dependent: :destroy
  has_many :questions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :topic_id, message: "already exists for this topic" }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :assign_default_position, on: :create, if: -> { position.blank? }

  scope :ordered, -> { order(position: :asc) }

  def categories
    learning_objectives.pluck(:category).compact.uniq.sort
  end

  private

  # `position` is NOT NULL with no DB default and is not in the controller's
  # permitted params, so an API-created module (name only) would otherwise hit a
  # NotNullViolation. Default it to the next slot within the owning topic.
  def assign_default_position
    self.position = (TopicModule.where(topic_id: topic_id).maximum(:position) || 0) + 1
  end
end
