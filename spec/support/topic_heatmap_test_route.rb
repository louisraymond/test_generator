# frozen_string_literal: true

# === sub-54: TEMP — test-only route for heat-map system specs ===
# Mounts the heat-map partial at /spec/topic_heatmap/:topic_id so JS specs
# can drive a real browser before sub-53's show.html.erb integration lands.
# REMOVE on merge with sub-53 (system spec retargets to /topics/:id).
return unless Rails.env.test?

class TopicHeatmapTestController < ApplicationController
  layout 'application'
  prepend_view_path File.expand_path('topic_heatmap_views', __dir__)

  def show
    @topic = Topic.includes(
      topic_modules: { learning_objectives: :questions },
      learning_objectives: :questions
    ).find(params[:topic_id])
    raw_usage = params[:exam_usage].to_s
    parsed = raw_usage.empty? ? {} : JSON.parse(raw_usage)
    @exam_usage = parsed.transform_keys(&:to_i)
    @presenter = TopicHeatmapPresenter.new(@topic, exam_usage: @exam_usage)
  end
end

unless Rails.application.routes.routes.any? { |r| r.name == 'spec_topic_heatmap' }
  Rails.application.routes.disable_clear_and_finalize = true
  Rails.application.routes.draw do
    get '/spec_support/topic_heatmap/:topic_id',
        to: 'topic_heatmap_test#show',
        as: :spec_topic_heatmap
  end
  Rails.application.routes.disable_clear_and_finalize = false
end
