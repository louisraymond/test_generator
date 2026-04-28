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
  # === sub-53: chrome ===
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
  # === /sub-53 ===

  # === sub-54: heat-map ===
  HEAT_BUCKETS = {
    0 => 'topic-heatmap__cell--heat-0',
    1 => 'topic-heatmap__cell--heat-1',
    2 => 'topic-heatmap__cell--heat-2',
    3 => 'topic-heatmap__cell--heat-3',
    4 => 'topic-heatmap__cell--heat-4'
  }.freeze

  def heat_bucket(count)
    case count.to_i
    when ..0 then 0
    when 1..2 then 1
    when 3..4 then 2
    when 5..6 then 3
    else 4
    end
  end

  def heat_color(count)
    HEAT_BUCKETS.fetch(heat_bucket(count))
  end

  def heat_text(count, mode: :coverage) # rubocop:disable Lint/UnusedMethodArgument
    n = count.to_i
    return "#{TopicHeatmapPresenter::CLAMP}+" if n > TopicHeatmapPresenter::CLAMP

    n.to_s
  end

  def heat_units(mode)
    mode.to_s == 'utilization' ? 'exam uses' : 'questions'
  end
  # === /sub-54 ===

  # === sub-55: modules ===
  # Note: renamed from HEAT_BUCKETS at integration time — sub-54 already
  # owns the HEAT_BUCKETS constant for the heat-map cell colours, and the
  # two have different shapes (hash vs array of hashes) and semantics.
  LO_CHIP_BUCKETS = [
    { max: 0,                klass: 'topic-detail__chip--zero' },
    { max: 1,                klass: 'topic-detail__chip--b1' },
    { max: 3,                klass: 'topic-detail__chip--b2' },
    { max: 6,                klass: 'topic-detail__chip--b3' },
    { max: Float::INFINITY,  klass: 'topic-detail__chip--b4' }
  ].freeze

  # The first module is expanded; the rest are collapsed by default.
  def module_collapsed_default?(_mod, idx)
    idx.positive?
  end

  # Group LOs by category, sorted alphabetically by category, with each
  # group's LOs in position order. Returns Array<[category, los]>.
  def category_grouping(mod)
    mod.learning_objectives
       .group_by(&:category)
       .sort_by { |cat, _| cat.to_s }
       .map { |cat, los| [cat, los.sort_by { |lo| [lo.position || 0, lo.id] }] }
  end

  # Render a heat-coloured Nq / Nx chip for a learning objective.
  # `exam_usage` is the topic-wide hash from sub-52 ({lo_id => count}).
  # `mode` is 'questions' (default) or 'usage' — chooses initial text/colour.
  def lo_chip_html(lo, exam_usage:, mode: 'questions')
    q_count = lo.questions.size
    u_count = exam_usage.fetch(lo.id, 0)

    initial_value = mode == 'usage' ? u_count : q_count
    bucket        = LO_CHIP_BUCKETS.find { |b| initial_value <= b[:max] }
    chip_text     = mode == 'usage' ? "#{initial_value}x" : "#{initial_value}q"
    units         = mode == 'usage' ? 'exam uses' : 'questions'

    render partial: 'topics/lo_chip', locals: {
      q_count:    q_count,
      u_count:    u_count,
      chip_class: bucket[:klass],
      chip_text:  chip_text,
      chip_title: "#{q_count} questions, #{u_count} exam uses",
      chip_label: "#{initial_value} #{units}"
    }
  end
  # === /sub-55 ===
end
