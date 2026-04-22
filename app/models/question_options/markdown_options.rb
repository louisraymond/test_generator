module QuestionOptions
  # Markdown question — prose with markdown formatting.
  class MarkdownOptions < Base
    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      new(
        body: (hash['body'] || hash[:body]).to_s.presence
      )
    end

    def initialize(body: nil)
      @body = body
    end
    attr_reader :body

    def to_jsonb
      { 'body' => body }.compact
    end
  end
end
