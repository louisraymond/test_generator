class TopicModule < ApplicationRecord
  belongs_to :topic
  has_many :learning_objectives, dependent: :destroy
  has_many :questions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :topic_id, message: "already exists for this topic" }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  default_scope { order(position: :asc) }

  def categories
    learning_objectives.pluck(:category).compact.uniq.sort
  end
end
