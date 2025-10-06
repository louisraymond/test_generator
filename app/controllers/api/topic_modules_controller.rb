class Api::TopicModulesController < Api::BaseController
  before_action :set_topic

  def create
    @module = @topic.topic_modules.build(topic_module_params)

    if @module.save
      render json: {
        id: @module.id,
        name: @module.name,
        description: @module.description
      }, status: :created
    else
      render json: { errors: @module.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def topic_module_params
    params.require(:topic_module).permit(:name, :description)
  end
end

