# frozen_string_literal: true

module TopicDetailHelper
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
end
