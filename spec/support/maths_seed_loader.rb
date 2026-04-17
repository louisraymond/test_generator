# frozen_string_literal: true

# Minimal loader used by maths exemplar specs. Idempotent — skips reload if the
# topic already has questions.
module MathsSeedLoader
  EXEMPLAR_TOPIC_NAME = 'Maths - Exemplars (v1 sampler)'
  SEED_DIR = Rails.root.join('db/seeds/maths_exemplars')
  SEED_FILES = %w[topic written calculation multiple_choice cloze composite].freeze

  module_function

  def load_exemplars!
    # Always reload the exemplar topic so specs see the current seed files.
    # Sources are created only when the maths-specific ones are missing (they
    # have no unique constraint, so re-running sources.rb would duplicate).
    Topic.where(name: EXEMPLAR_TOPIC_NAME).destroy_all
    load Rails.root.join('db/seeds/sources.rb') unless Source.exists?(name: 'Claude (claude-opus-4-7, 2026)')
    SEED_FILES.each do |f|
      path = SEED_DIR.join("#{f}.rb")
      load path if path.exist?
    end
  end

  def exemplar_questions
    Question.joins(:topic).where(topics: { name: EXEMPLAR_TOPIC_NAME })
  end
end
