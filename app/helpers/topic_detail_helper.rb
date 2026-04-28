# Topic detail helpers.
#
# === sub-55: modules ===
module TopicDetailHelper
  HEAT_BUCKETS = [
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
    bucket        = HEAT_BUCKETS.find { |b| initial_value <= b[:max] }
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
