module QuestionOptions
  # Ordering: array of items (the correct sequence).
  # Legacy accepted: ['a','b','c'] plain strings.
  # New shape: [{ text: 'a', position: 1 }].
  class OrderingOptions < Base
    Item = Data.define(:text, :position)

    def self.from(raw)
      rows = raw.is_a?(Array) ? raw : []
      items = rows.each_with_index.map do |row, idx|
        if row.is_a?(Hash)
          Item.new(
            text:     (row['text']     || row[:text]).to_s,
            position: (row['position'] || row[:position] || (idx + 1)).to_i
          )
        else
          Item.new(text: row.to_s, position: idx + 1)
        end
      end
      new(items: items)
    end

    def initialize(items:)
      @items = items
    end
    attr_reader :items

    def to_jsonb
      items.sort_by(&:position).map { |it| { 'text' => it.text, 'position' => it.position } }
    end

    def validate(errors)
      errors.add(:options, 'must be an array of 2 or more items') if items.length < 2
    end
  end
end
