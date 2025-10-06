module Api
  class TopicsController < BaseController
    def index
      topics = Topic.includes(:learning_objectives).order(:name)

      render json: topics.map { |topic| serialize_topic_summary(topic) }
    end

    def show
      topic = Topic.includes(:learning_objectives).find(params[:id])

      render json: serialize_topic_detail(topic)
    end

    private

    def serialize_topic_summary(topic)
      {
        id: topic.id,
        name: topic.name,
        description: topic.epigraph_quote,
        category_count: topic.learning_outcome_sections.size,
        learning_objective_count: topic.learning_objectives.count
      }
    end

    def serialize_topic_detail(topic)
      {
        id: topic.id,
        name: topic.name,
        description: topic.epigraph_quote,
        categories: topic.learning_outcome_sections_with_counts.map do |section|
          {
            title: section['title'],
            prefix: section['prefix'],
            learning_objectives: section['items'].map.with_index do |item, idx|
              # Find the actual learning objective
              lo = topic.learning_objectives.find { |obj| obj.category == section['title'] && obj.description == item['text'] }
              {
                id: lo&.id,
                description: item['text'],
                position: idx,
                question_count: item['count']
              }
            end
          }
        end
      }
    end
  end
end
