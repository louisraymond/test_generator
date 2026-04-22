# frozen_string_literal: true

# Helpers for the workspace pill-tab shell and Dashboard screen.
# Phase 12 ships static values for stats/activity; Phase 13 wires them to
# live queries.
module WorkspacesHelper
  # "Good morning" / "Good afternoon" / "Good evening" based on local hour.
  def greeting_for(time = Time.current)
    hour = time.hour
    return 'Good morning' if hour < 12
    return 'Good afternoon' if hour < 18
    'Good evening'
  end

  # Basic-auth username titleised. Falls back to "there" in the test env
  # where AUTH_USER isn't set (application_controller skips auth in test).
  def dashboard_user_name
    ENV['AUTH_USER'].to_s.strip.titleize.presence || 'there'
  end

  # Stat tiles shown in the dashboard's top row.
  # Each entry: { label:, value:, detail:, trend:, trend_muted: }
  def dashboard_stats
    [
      { label: 'Exams generated', value: Exam.count,          detail: '· all time',    trend: '+12 this month',  trend_muted: false },
      { label: 'Question bank',   value: Question.count,      detail: '· questions',   trend: "+#{Question.where('created_at > ?', 7.days.ago).count} this week", trend_muted: false },
      { label: 'Topics',          value: Topic.count,         detail: "· #{TopicModule.count} modules", trend: 'no change', trend_muted: true },
      { label: 'Templates',       value: ExamTemplate.count,  detail: '· reusable',    trend: "#{ExamTemplate.where('use_count > 0').count} used this term", trend_muted: true }
    ]
  end

  # Activity feed — unions recent activity across several record types and
  # orders by the most recent timestamp. Each entry: { time:, title:, meta:, type: }.
  def dashboard_activity_feed(limit: 5)
    items = []

    Exam.order(created_at: :desc).limit(limit).each do |e|
      items << {
        time: e.created_at,
        title: "#{e.title} generated",
        meta: "#{e.exam_questions.size} questions · #{e.duration_minutes || '—'} min",
        type: 'Exam'
      }
    end

    ExamTemplate.where.not(updated_at: nil).order(updated_at: :desc).limit(limit).each do |t|
      items << {
        time: t.updated_at,
        title: "Template \"#{t.name}\" edited",
        meta: "#{t.total_questions} questions · tier #{t.tier || '—'}",
        type: 'Template'
      }
    end

    TopicModule.order(created_at: :desc).limit(limit).each do |m|
      items << {
        time: m.created_at,
        title: "New module: #{m.name}",
        meta: "Under Topic: #{m.topic&.name || 'Orphaned'}",
        type: 'Topic'
      }
    end

    items.sort_by { |i| -i[:time].to_i }.first(limit)
  end

  # Relative time label like "09:42" / "yesterday" / "Apr 15".
  def activity_time_label(time, now: Time.current)
    return time.strftime('%H:%M') if time.to_date == now.to_date
    return 'yesterday' if time.to_date == now.to_date - 1
    time.strftime('%b %-d')
  end

  # Five dashboard quick-action cards. Each: { icon:, title:, subtitle:, href: }.
  def dashboard_quick_actions
    [
      { icon: '+', title: 'Generate a new exam',      subtitle: 'Pick topics, weights, and question types.',    href: new_exam_path },
      { icon: 'T', title: 'Use a saved template',     subtitle: "#{ExamTemplate.count} templates ready.",         href: exam_templates_path },
      { icon: 'Q', title: 'Add a question',           subtitle: 'Fill the bank for future exams.',                href: new_question_path },
      { icon: 'ʘ', title: 'Edit learning outcomes',   subtitle: 'Keep LOs in sync with syllabus.',                href: topics_path },
      { icon: '↘', title: 'Review past exam',         subtitle: 'Re-export, adjust seed, send to marker.',        href: workspace_path(tab: 'review') }
    ]
  end
end
