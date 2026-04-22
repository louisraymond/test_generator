class QuestionPart < ApplicationRecord
  belongs_to :question
  belongs_to :parent_part, class_name: 'QuestionPart', optional: true
  has_many :children,
           class_name: 'QuestionPart',
           foreign_key: :parent_part_id,
           dependent: :destroy,
           inverse_of: :parent_part
  has_many :marking_steps, as: :creditable, dependent: :destroy

  validates :part_type, inclusion: { in: Question::QUESTION_TYPES }
  validates :position, presence: true
  validates :marks, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:position) }
  scope :roots,   -> { where(parent_part_id: nil) }

  def typed_options
    QuestionTypes.for(part_type)&.options_class&.from(options || {})
  end

  def depth
    n = 0
    p = parent_part
    while p
      n += 1
      p = p.parent_part
    end
    n
  end
end
