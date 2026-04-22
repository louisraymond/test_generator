module QuestionOptions
  # Code analysis: { language, code, answer_format, choices?, highlighted_lines? }.
  class CodeAnalysisOptions < Base
    Choice = Data.define(:text, :correct)

    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      choices = Array(hash['choices'] || hash[:choices]).map do |c|
        next unless c.is_a?(Hash)
        Choice.new(text: (c['text'] || c[:text]).to_s, correct: bool(c['correct'] || c[:correct]))
      end.compact
      new(
        language: (hash['language'] || hash[:language] || 'plaintext').to_s,
        code:     (hash['code']     || hash[:code]     || '').to_s,
        answer_format: (hash['answer_format'] || hash[:answer_format] || 'lines').to_s,
        choices: choices,
        highlighted_lines: Array(hash['highlighted_lines'] || hash[:highlighted_lines]).map(&:to_i)
      )
    end

    def initialize(language:, code:, answer_format:, choices: [], highlighted_lines: [])
      @language = language
      @code = code
      @answer_format = answer_format
      @choices = choices
      @highlighted_lines = highlighted_lines
    end
    attr_reader :language, :code, :answer_format, :choices, :highlighted_lines

    def to_jsonb
      h = {
        'language'          => language,
        'code'              => code,
        'answer_format'     => answer_format,
        'highlighted_lines' => highlighted_lines
      }
      h['choices'] = choices.map { |c| { 'text' => c.text, 'correct' => c.correct } } if choices.any?
      h
    end

    def validate(errors)
      if code.strip.blank?
        errors.add(:options, "must include 'code'")
      end
      unless %w[lines multiple_choice].include?(answer_format)
        errors.add(:options, "answer_format must be 'lines' or 'multiple_choice'")
        return
      end
      if answer_format == 'multiple_choice'
        if choices.length < 2
          errors.add(:options, 'multiple_choice requires at least 2 choices')
        elsif choices.any? { |c| c.text.to_s.strip.blank? }
          errors.add(:options, 'each choice must include text')
        elsif choices.none?(&:correct)
          errors.add(:options, 'at least one choice must be correct')
        end
      end
    end
  end
end
