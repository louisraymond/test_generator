# frozen_string_literal: true

# Helper for the Topic Detail v2 chrome (sub-53).
#
# Hosts the small string/format helpers used by the v2 sidebar, toolbar,
# and stat strip partials, plus the feature-flag predicate that gates the
# v2 markup behind a `?v2=1` query param or a `TOPIC_DETAIL_V2=true` ENV.
#
# Sub-issues #54-#57 will read these helpers; do not move them inline back
# into the partials.
module TopicDetailHelper
  # Renders a module's category / LO / question counts as the dot-separated
  # mono caption shown beside each sidebar entry.
  #
  # Returns the literal string "0 cat · 0 LO · 0 Q" for empty modules — the
  # caller never has to nil-check.
  def module_ministats(mod)
    cats = mod.learning_objectives.map(&:category).compact.uniq.size
    los  = mod.learning_objectives.size
    qs   = mod.questions.size
    "#{cats} cat · #{los} LO · #{qs} Q"
  end

  # Two-digit zero-padded label for module index.  Pads 1-9 to "01"-"09",
  # leaves 10-99 unchanged, returns the bare number for 100+.
  def module_index_label(idx)
    idx < 100 ? format('%02d', idx) : idx.to_s
  end

  # Returns a hash the `_stat_card` partial can splat into HTML attributes.
  # Pass `mode: :usage` for the 4th card so sub-3 (#52) can find it via
  # `data-stat-target="usage"` to swap Questions ↔ Exam-uses without re-rendering.
  def topic_stat(label:, value:, mode: nil)
    html_data = mode == :usage ? { stat_target: 'usage' } : {}
    { label: label, value: value, html_data: html_data }
  end

  # Feature-flag predicate.  V2 chrome ships behind `?v2=1` (per-request
  # opt-in for QA) or a `TOPIC_DETAIL_V2=true` ENV (global opt-in for staging).
  # Once #54-#57 land we'll graduate this to a real flag library.
  def topic_detail_v2?(params_like)
    return true if params_like.respond_to?(:[]) && params_like[:v2].to_s == '1'

    ENV['TOPIC_DETAIL_V2'].to_s.downcase == 'true'
  end

  # Convenience wrapper that takes a request-like object (anything with
  # `#params`) and forwards to `topic_detail_v2?`.  Lets controllers and
  # views call the same predicate without re-extracting params.
  def topic_v2_enabled_for?(request_like)
    topic_detail_v2?(request_like.params)
  end
end
