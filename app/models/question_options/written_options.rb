module QuestionOptions
  # Written / free-form prose. Options are mostly empty; the PORO gives the
  # paper editor a stable place to read `prompt` + `answer_size` presets.
  class WrittenOptions < Base
    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      new(
        prompt:      (hash['prompt']      || hash[:prompt]).to_s.presence,
        answer_size: (hash['answer_size'] || hash[:answer_size] || 'medium').to_s
      )
    end

    def initialize(prompt: nil, answer_size: 'medium')
      @prompt = prompt
      @answer_size = answer_size
    end
    attr_reader :prompt, :answer_size

    def prose? = true

    def to_jsonb
      { 'prompt' => prompt, 'answer_size' => answer_size }.compact
    end
  end
end
