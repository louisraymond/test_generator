class Api::LearningObjectivesController < Api::BaseController
  before_action :set_topic
  before_action :set_learning_objective, only: %i[update destroy]

  def create
    @learning_objective = @topic.learning_objectives.build(learning_objective_params)
    
    # Set position to be last in the category
    existing_in_category = @topic.learning_objectives.where(category: @learning_objective.category)
    @learning_objective.position = existing_in_category.maximum(:position).to_i + 1
    
    # Set category_order
    categories = @topic.learning_objectives.pluck(:category).uniq
    @learning_objective.category_order = categories.index(@learning_objective.category) || categories.size

    if @learning_objective.save
      render json: {
        id: @learning_objective.id,
        description: @learning_objective.description,
        category: @learning_objective.category
      }, status: :created
    else
      render json: { errors: @learning_objective.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @learning_objective.update(learning_objective_params)
      render json: {
        id: @learning_objective.id,
        description: @learning_objective.description
      }
    else
      render json: { errors: @learning_objective.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @learning_objective.destroy
    head :no_content
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_learning_objective
    @learning_objective = @topic.learning_objectives.find(params[:id])
  end

  def learning_objective_params
    params.require(:learning_objective).permit(:description, :category)
  end
end
