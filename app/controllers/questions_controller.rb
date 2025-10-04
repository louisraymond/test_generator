class QuestionsController < ApplicationController
  def index
    @topics = Topic.order(:name)
    @sources = Source.order(:name)

    scope = Question.includes(:topic, :source)
    scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
    scope = scope.where(source_id: params[:source_id]) if params[:source_id].present?
    scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?

    @total_count = scope.count
    @type_counts = scope.group(:question_type).count
    @questions = scope.order(created_at: :desc).limit(200)
    @capped = @total_count > @questions.size
  end

  def import
    @question_types = Question::QUESTION_TYPES
    @topics = Topic.order(:name)
    @sources = Source.order(:name)
  end

  def import_csv
    if params[:csv_file].blank?
      flash[:alert] = "Please select a CSV file to import"
      redirect_to import_questions_path and return
    end

    begin
      csv_data = parse_csv_file(params[:csv_file])
      
      if params[:preview_only] == 'true'
        # Preview mode - validate but don't create
        result = QuestionsImporter.call(csv_data, dry_run: true)
        
        if result[:success]
          flash[:notice] = "Preview successful! #{csv_data.length} questions validated."
          redirect_to import_questions_path(preview: true, 
                                          questions_count: csv_data.length,
                                          errors: result[:errors],
                                          warnings: result[:warnings])
        else
          flash[:alert] = "Validation failed: #{result[:errors].join(', ')}"
          redirect_to import_questions_path
        end
      else
        # Full import
        result = QuestionsImporter.call(csv_data, dry_run: false)
        
        if result[:success]
          flash[:notice] = "Import successful! Created #{result[:created_questions]} questions, #{result[:created_topics]} topics, #{result[:created_sources]} sources."
          redirect_to questions_path
        else
          flash[:alert] = "Import failed: #{result[:errors].join(', ')}"
          redirect_to import_questions_path
        end
      end
    rescue QuestionsImporter::Error => e
      flash[:alert] = "Import error: #{e.message}"
      redirect_to import_questions_path
    rescue => e
      flash[:alert] = "Unexpected error: #{e.message}"
      redirect_to import_questions_path
    end
  end

  def import_preview
    if params[:csv_data].blank?
      render json: { error: "No CSV data provided" }, status: :bad_request and return
    end

    begin
      csv_data = JSON.parse(params[:csv_data])
      result = QuestionsImporter.call(csv_data, dry_run: true)
      
      render json: result
    rescue QuestionsImporter::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
    end
  end
  def types_preview
    @random_questions = Question.order(Arel.sql('RANDOM()')).limit(15)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'questions/types_preview', layout: 'pdf', formats: [:html])
        pdf = Grover.new(
          html,
          base_url: request.base_url,
          emulate_media: 'print',
          print_background: true,
          prefer_css_page_size: true,
          wait_until: 'domcontentloaded',
          timeout: 90_000
        ).to_pdf
        send_data pdf, filename: 'preview.pdf', type: 'application/pdf'
      end
    end
  end

  private

  def parse_csv_file(file)
    require 'csv'
    
    csv_data = []
    CSV.foreach(file.path, headers: true) do |row|
      csv_data << row.fields
    end
    
    csv_data
  end
end
