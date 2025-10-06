class SectionSourceRule < ApplicationRecord
  belongs_to :exam_section
  belongs_to :source, polymorphic: true
  
  validates :source_type, presence: true, inclusion: { in: %w[Topic TopicModule LearningObjective] }
  validates :source_id, presence: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 }
  
  # Helper to get the actual source object
  def source_name
    source&.name || "Unknown"
  end
end

