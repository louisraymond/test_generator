# Editor #11 (ticket 47) — backfill `question_parts` AR rows from the
# legacy `questions.options['parts']` jsonb shape.
#
# AR is now the source of truth for composite-question parts. The jsonb
# column is left intact for one deprecation cycle so we can roll back
# without losing data — drop it in a follow-up migration once the editor
# has shipped to prod and we've verified the AR rows are correct.
#
# Idempotency: skipping any composite that already has AR rows means this
# can be re-run safely (e.g. after a partial deploy or a staging refresh).
#
# Rollback: there is intentionally no `down` that destroys AR rows — that's
# a real foot-gun (it would silently drop authored content if the jsonb
# fallback was already cleared). If you really need to undo this, do it
# by hand: `Question.composite.find_each { _1.question_parts.destroy_all }`.
#
# Verification on prod after deploy:
#   bin/rails runner 'puts Question.where(question_type: "composite").count, QuestionPart.count'
# The two counts won't match exactly (one composite has many parts), but
# QuestionPart.count should be >= the composite count and >= the sum of
# `options["parts"].length` across composites before the migration.
class BackfillQuestionPartsFromJsonb < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Use a lightweight model in case Question's validations evolve
    # before this migration is squashed away.
    composite_klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'questions'
      has_many :question_parts, foreign_key: :question_id
    end
    part_klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'question_parts'
    end

    composite_klass.where(question_type: 'composite').find_each do |q|
      next if part_klass.where(question_id: q.id).exists?

      raw_parts = q.options.is_a?(Hash) ? Array(q.options['parts']) : []
      next if raw_parts.empty?

      raw_parts.each_with_index do |part, idx|
        next unless part.is_a?(Hash)

        attrs = {
          question_id: q.id,
          position:    idx + 1,
          stem:        part['stem'],
          marks:       (part['marks'].presence || 1).to_i,
          part_type:   (part['type'].presence || 'written'),
          options:     (part['options'].is_a?(Hash) ? part['options'] : {}),
          created_at:  Time.current,
          updated_at:  Time.current
        }
        attrs[:answer_label] = part['answer_label'] if part.key?('answer_label')
        attrs[:unit]         = part['unit']         if part.key?('unit')
        # `answer_size` is on the parts column in the source jsonb but is
        # serialized into the `options` jsonb on QuestionPart so the AR
        # row stays slim. Keep both shapes during the deprecation cycle.
        if part.key?('answer_size')
          attrs[:options] = (attrs[:options] || {}).merge('answer_size' => part['answer_size'])
        end

        part_klass.create!(attrs)
      end
    end
  end

  def down
    # Intentional no-op. See class docstring — undoing this destroys
    # authored content. Do it by hand if you really mean it.
    say "BackfillQuestionPartsFromJsonb#down is a no-op by design (see migration source)."
  end
end
