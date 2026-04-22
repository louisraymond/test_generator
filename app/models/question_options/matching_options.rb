module QuestionOptions
  # Matching: { left: [strings], right: [strings], seed: Int, distractors: [strings] }.
  class MatchingOptions < Base
    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      left  = Array(hash['left']  || hash[:left]).map(&:to_s)
      right = Array(hash['right'] || hash[:right]).map(&:to_s)
      distractors = Array(hash['distractors'] || hash[:distractors]).map(&:to_s)
      seed = (hash['seed'] || hash[:seed]).to_i
      new(left: left, right: right, distractors: distractors, seed: seed)
    end

    def initialize(left:, right:, distractors: [], seed: 0)
      @left, @right, @distractors, @seed = left, right, distractors, seed
    end
    attr_reader :left, :right, :distractors, :seed

    def to_jsonb
      { 'left' => left, 'right' => right, 'distractors' => distractors, 'seed' => seed }
    end

    def validate(errors)
      if left.empty? || right.empty?
        errors.add(:options, "must include 'left' and 'right' arrays")
      elsif left.length != right.length
        errors.add(:options, 'left and right must be same length')
      end
    end

    def pairs
      left.zip(right)
    end
  end
end
