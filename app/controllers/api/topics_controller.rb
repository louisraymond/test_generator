module Api
  class TopicsController < BaseController
    def index
      topics = Topic.all
      topics = topics.where(name: params[:name]) if params[:name].present?
      topics = topics.where(parent_topic_id: nil) if params[:top_level] == 'true'

      render json: topics.map { |t|
        {
          id: t.id,
          name: t.name,
          parent_topic_id: t.parent_topic_id,
          question_count: t.questions.count
        }
      }
    end

    def show
      topic = Topic.includes(topic_modules: :learning_objectives).find(params[:id])

      render json: topic_tree(topic)
    end

    def create
      existing = Topic.find_by(name: topic_params[:name])
      if existing
        topic = Topic.includes(topic_modules: :learning_objectives).find(existing.id)
        render json: topic_tree(topic), status: :ok
        return
      end

      topic = nil
      ActiveRecord::Base.transaction do
        topic = Topic.create!(
          name: topic_params[:name],
          parent_topic_id: topic_params[:parent_topic_id]
        )

        Array(topic_params[:modules]).each_with_index do |mod_attrs, mod_index|
          position = mod_attrs[:position] || mod_index + 1
          topic_module = topic.topic_modules.create!(
            name: mod_attrs[:name],
            position: position
          )

          Array(mod_attrs[:learning_objectives]).each_with_index do |lo_attrs, lo_index|
            topic.learning_objectives.create!(
              topic_module: topic_module,
              category: lo_attrs[:category] || topic_module.name,
              description: lo_attrs[:description],
              position: lo_attrs[:position] || lo_index + 1,
              category_order: position
            )
          end
        end
      end

      topic = Topic.includes(topic_modules: :learning_objectives).find(topic.id)
      render json: topic_tree(topic), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def update
      topic = Topic.find(params[:id])
      if topic.update(topic_update_params)
        render json: topic_tree(topic.reload), status: :ok
      else
        render json: { error: topic.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def destroy
      topic = Topic.find(params[:id])
      topic.destroy!
      head :no_content
    end

    private

    def topic_params
      params.permit(
        :name, :parent_topic_id,
        modules: [
          :name, :position,
          learning_objectives: %i[category description position]
        ]
      )
    end

    def topic_update_params
      params.permit(:name, :parent_topic_id)
    end

    def topic_tree(topic)
      {
        id: topic.id,
        name: topic.name,
        parent_topic_id: topic.parent_topic_id,
        children: topic.subtopics.map { |c| { id: c.id, name: c.name } },
        modules: topic.topic_modules.ordered.map { |tm|
          {
            id: tm.id,
            name: tm.name,
            position: tm.position,
            learning_objectives: tm.learning_objectives.order(:position, :id).map { |lo|
              {
                id: lo.id,
                position: lo.position,
                category: lo.category,
                description: lo.description
              }
            }
          }
        }
      }
    end
  end
end
