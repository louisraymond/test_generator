module QuestionOptions
  # Cloze options: { tokens: [{index, blanked, word, answer, accepts}], ui_mode }.
  # Legacy: {} or { 'tokens' => [...] }. New shape adds `accepts_map` lookup for
  # per-blank synonym lists.
  class ClozeOptions < Base
    Token = Data.define(:index, :blanked, :word, :answer, :accepts)

    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      tokens = Array(hash['tokens'] || hash[:tokens]).map do |t|
        if t.is_a?(Hash)
          Token.new(
            index:   (t['index']   || t[:index]).to_i,
            blanked: bool(t['blanked'] || t[:blanked]),
            word:    (t['word']    || t[:word]).to_s,
            answer:  (t['answer']  || t[:answer]).to_s,
            accepts: Array(t['accepts'] || t[:accepts]).map(&:to_s)
          )
        end
      end.compact
      ui_mode = (hash['ui_mode'] || hash[:ui_mode] || 'wysiwyg').to_s
      new(tokens: tokens, ui_mode: ui_mode)
    end

    def initialize(tokens:, ui_mode: 'wysiwyg')
      @tokens = tokens
      @ui_mode = ui_mode
    end
    attr_reader :tokens, :ui_mode

    def blanked_indices
      tokens.select(&:blanked).map(&:index)
    end

    def to_jsonb
      {
        'ui_mode' => ui_mode,
        'tokens'  => tokens.map do |t|
          {
            'index'   => t.index,
            'blanked' => t.blanked,
            'word'    => t.word,
            'answer'  => t.answer,
            'accepts' => t.accepts
          }
        end
      }
    end

    def validate(_errors)
      # cloze is permissive — rendering falls back to raw content when tokens
      # are missing; validator stays a no-op.
    end
  end
end
