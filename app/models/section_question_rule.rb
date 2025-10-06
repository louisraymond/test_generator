class SectionQuestionRule < ApplicationRecord
  belongs_to :exam_section
  belongs_to :question
  
  validates :rule_type, presence: true, inclusion: { in: %w[force_include exclude] }
  validates :repeat_count, numericality: { only_integer: true, greater_than: 0 }
  validates :question_id, uniqueness: { scope: [:exam_section_id, :rule_type] }
  
  scope :force_includes, -> { where(rule_type: 'force_include') }
  scope :excludes, -> { where(rule_type: 'exclude') }
end

