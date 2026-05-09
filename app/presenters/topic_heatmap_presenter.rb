# frozen_string_literal: true

# Builds the data payload for the topic-heatmap block (sub-54).
#
# One instance per request. Pure: no DB queries beyond the already-preloaded
# associations on `topic` (see TopicsController#set_topic) and the
# `exam_usage` hash from #52 (`{ lo_id => uses_count }`).
class TopicHeatmapPresenter
  CLAMP = 99

  Cell = Struct.new(:lo, :coverage_count, :utilization_count, keyword_init: true) do
    def display(mode)
      n = mode.to_sym == :utilization ? utilization_count : coverage_count
      n > CLAMP ? "#{CLAMP}+" : n.to_s
    end

    def bucket(mode)
      n = mode.to_sym == :utilization ? utilization_count : coverage_count
      case n
      when ..0 then 0
      when 1..2 then 1
      when 3..4 then 2
      when 5..6 then 3
      else 4
      end
    end
  end

  Row = Struct.new(:topic_module, :cells, :totals, keyword_init: true) do
    def empty?
      cells.empty?
    end
  end

  def initialize(topic, exam_usage: {})
    @topic = topic
    @exam_usage = exam_usage || {}
  end

  def rows
    return [] if @topic.learning_objectives.empty?

    @topic.topic_modules.sort_by { |m| [m.position.to_i, m.id] }.map { |mod| build_row(mod) }
  end

  def summary(mode)
    los = @topic.learning_objectives
    case mode.to_sym
    when :utilization
      appearances = los.sum { |lo| @exam_usage.fetch(lo.id, 0) }
      zeros = los.count { |lo| @exam_usage.fetch(lo.id, 0).zero? }
      { appearances: appearances, zero_count: zeros }
    else
      { question_count: los.sum(&:question_count), outcome_count: los.size }
    end
  end

  private

  def build_row(mod)
    cells = mod.learning_objectives.sort_by { |lo| [lo.position.to_i, lo.id] }.map do |lo|
      Cell.new(
        lo: lo,
        coverage_count: lo.question_count,
        utilization_count: @exam_usage.fetch(lo.id, 0)
      )
    end
    Row.new(
      topic_module: mod,
      cells: cells,
      totals: {
        lo_count: cells.size,
        question_count: cells.sum(&:coverage_count),
        uses_count: cells.sum(&:utilization_count)
      }
    )
  end
end
