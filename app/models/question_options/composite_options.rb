module QuestionOptions
  # Composite: parent question whose body is composed of `question_parts`
  # (child rows after PR #8) or legacy jsonb `parts` array. Value object
  # is a thin reader — writes go via QuestionPart AR rows once PR #8 lands.
  class CompositeOptions < Base
    Part = Data.define(:position, :label, :stem, :marks, :part_type, :options)

    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      parts = Array(hash['parts'] || hash[:parts]).each_with_index.map do |p, idx|
        next unless p.is_a?(Hash)
        Part.new(
          position:  (p['position']  || p[:position]  || (idx + 1)).to_i,
          label:     (p['label']     || p[:label]).to_s.presence,
          stem:      (p['stem']      || p[:stem] || p['content'] || p[:content]).to_s,
          marks:     (p['marks']     || p[:marks] || 1).to_i,
          part_type: (p['part_type'] || p[:part_type] || p['type'] || 'written').to_s,
          options:   (p['options']   || p[:options] || {})
        )
      end.compact
      new(parts: parts)
    end

    def initialize(parts: [])
      @parts = parts
    end
    attr_reader :parts

    def to_jsonb
      {
        'parts' => parts.sort_by(&:position).map do |p|
          {
            'position'  => p.position,
            'label'     => p.label,
            'stem'      => p.stem,
            'marks'     => p.marks,
            'part_type' => p.part_type,
            'options'   => p.options
          }
        end
      }
    end

    def validate(_errors); end
  end
end
