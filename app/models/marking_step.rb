# frozen_string_literal: true

# A single credit event on a Question's mark scheme.
# Examples: "State gradient formula — M1" / "Evaluate at w0 — A1".
class MarkingStep < ApplicationRecord
  KINDS = %w[m a b dm].freeze

  belongs_to :question
  # Phase 7 / Wave 3 — mark steps may attach to either a Question directly
  # (today's shape) or to a QuestionPart (composite sub-parts). Back-fill in
  # migration sets creditable=Question for existing rows.
  belongs_to :creditable, polymorphic: true, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :n, numericality: { only_integer: true, greater_than: 0 }
  validates :text, presence: true
  validates :position, uniqueness: { scope: :question_id }, allow_nil: true

  before_validation :assign_position, on: :create

  scope :ordered, -> { order(:position) }

  def pill_label
    "#{kind.upcase}#{n}"
  end

  private

  def assign_position
    return if position.present?
    self.position = (question.marking_steps.maximum(:position) || 0) + 1
  end
end
