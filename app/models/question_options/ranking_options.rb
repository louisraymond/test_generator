module QuestionOptions
  # Ranking: array of { text, rank }.
  # Legacy accepted: plain strings.
  class RankingOptions < Base
    Item = Data.define(:text, :rank)

    def self.from(raw)
      rows = raw.is_a?(Array) ? raw : []
      items = rows.each_with_index.map do |row, idx|
        if row.is_a?(Hash)
          text = (row['text'] || row[:text]).to_s
          rank_v = row['rank'] || row[:rank]
          rank = rank_v.to_i
          Item.new(text: text, rank: rank.positive? ? rank : idx + 1)
        else
          Item.new(text: row.to_s, rank: idx + 1)
        end
      end
      new(items: items)
    end

    def initialize(items:)
      @items = items
    end
    attr_reader :items

    def to_jsonb
      items.map { |it| { 'text' => it.text, 'rank' => it.rank } }
    end

    def validate(errors)
      if items.length < 2
        errors.add(:options, 'must include at least two rankable items')
      elsif items.any? { |it| it.text.to_s.strip.blank? }
        errors.add(:options, 'each option must include text')
      end
    end
  end
end
