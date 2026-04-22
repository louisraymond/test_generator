module QuestionOptions
  # Multiple-choice options: array of { text, correct, eliminated }.
  #
  # Legacy shapes accepted:
  #   ['a', 'b']                                    -> text only, correct=false
  #   [{ text: 'a', correct: true }]                -> current seed shape
  # New shape:
  #   [{ text: 'a', correct: true, eliminated: false, shuffle_group: nil }]
  class MCQOptions < Base
    Choice = Data.define(:text, :correct, :eliminated)

    def self.from(raw)
      rows = raw.is_a?(Array) ? raw : []
      choices = rows.map do |row|
        if row.is_a?(Hash)
          Choice.new(
            text:       (row['text'] || row[:text]).to_s,
            correct:    bool(row['correct'] || row[:correct]),
            eliminated: bool(row['eliminated'] || row[:eliminated])
          )
        else
          Choice.new(text: row.to_s, correct: false, eliminated: false)
        end
      end
      new(choices: choices)
    end

    def initialize(choices:)
      @choices = choices
    end
    attr_reader :choices

    def correct_indices
      choices.each_with_index.select { |c, _| c.correct }.map(&:last)
    end

    def single_correct?
      correct_indices.length <= 1
    end

    def to_jsonb
      choices.map do |c|
        { 'text' => c.text, 'correct' => c.correct, 'eliminated' => c.eliminated }
      end
    end

    def with_correct(idx:, exclusive: true)
      new_choices = choices.each_with_index.map do |c, i|
        if exclusive
          Choice.new(text: c.text, correct: (i == idx), eliminated: c.eliminated)
        else
          i == idx ? Choice.new(text: c.text, correct: !c.correct, eliminated: c.eliminated) : c
        end
      end
      self.class.new(choices: new_choices)
    end

    def validate(errors)
      if choices.length < 2
        errors.add(:options, 'must include at least two choices')
        return
      end
      unless choices.all? { |c| c.text.to_s.strip.present? }
        errors.add(:options, 'each choice must include text')
      end
      unless choices.any?(&:correct)
        errors.add(:options, 'must have at least one correct choice')
      end
    end
  end
end
