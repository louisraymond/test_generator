# frozen_string_literal: true

# A single credit event on a Question's mark scheme.
# Examples: "State gradient formula — M1" / "Evaluate at w0 — A1".
class MarkingStep < ApplicationRecord
  KINDS = %w[m a b dm].freeze

  belongs_to :question

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
