module QuestionOptions
  # Calculation: working-room size + unit + tolerance.
  # Most fields mirror sibling Question columns (unit, answer_label).
  # Legacy: empty / old `{unit, answer_label}` hash. New shape adds tolerance.
  class CalculationOptions < Base
    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      new(
        working_lines: (hash['working_lines'] || hash[:working_lines] || 0).to_i,
        unit:          (hash['unit']          || hash[:unit]).to_s.presence,
        tolerance:     (hash['tolerance']     || hash[:tolerance]).to_s.presence,
        answer_value:  (hash['answer_value']  || hash[:answer_value]).to_s.presence,
        answer_format: (hash['answer_format'] || hash[:answer_format] || 'numeric').to_s
      )
    end

    def initialize(working_lines: 0, unit: nil, tolerance: nil, answer_value: nil, answer_format: 'numeric')
      @working_lines = working_lines
      @unit = unit
      @tolerance = tolerance
      @answer_value = answer_value
      @answer_format = answer_format
    end
    attr_reader :working_lines, :unit, :tolerance, :answer_value, :answer_format

    def to_jsonb
      {
        'working_lines' => working_lines,
        'unit'          => unit,
        'tolerance'     => tolerance,
        'answer_value'  => answer_value,
        'answer_format' => answer_format
      }.compact
    end

    def validate(errors)
      unless %w[numeric expression].include?(answer_format)
        errors.add(:options, "answer_format must be 'numeric' or 'expression'")
      end
    end
  end
end
