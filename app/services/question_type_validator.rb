class QuestionTypeValidator
  def initialize(question_data)
    @question_data = question_data
    @errors = []
    @warnings = []
  end

  def validate
    validate_question_type_specific_rules
    validate_options_structure
  end

  def errors
    @errors
  end

  def warnings
    @warnings
  end

  private

  def validate_question_type_specific_rules
    case @question_data[:question_type]
    when 'multiple_choice'
      validate_multiple_choice
    when 'matching'
      validate_matching
    when 'ordering', 'ranking'
      validate_ordering_ranking
    when 'diagram_label'
      validate_diagram_label
    when 'image_occlusion'
      validate_image_occlusion
    when 'composite'
      validate_composite
    when 'calculation'
      validate_calculation
    end
  end

  def validate_multiple_choice
    options = @question_data[:options]
    
    unless options.is_a?(Array) && options.any?
      @errors << "Multiple choice questions must have options array"
      return
    end
    
    if options.length < 2
      @errors << "Multiple choice questions must have at least 2 options"
    end
    
    if options.length > 10
      @warnings << "Multiple choice questions with more than 10 options may be difficult to display"
    end
    
    # Check for duplicate options
    if options.uniq.length != options.length
      @warnings << "Multiple choice options contain duplicates"
    end
  end

  def validate_matching
    options = @question_data[:options]
    
    unless options.is_a?(Hash) && options['left'].is_a?(Array) && options['right'].is_a?(Array)
      @errors << "Matching questions must have left and right arrays in options"
      return
    end
    
    left = options['left']
    right = options['right']
    
    if left.length != right.length
      @errors << "Matching left and right arrays must have the same length"
    end
    
    if left.length < 2
      @errors << "Matching questions must have at least 2 pairs"
    end
    
    if left.length > 8
      @warnings << "Matching questions with more than 8 pairs may be difficult to display"
    end
  end

  def validate_ordering_ranking
    options = @question_data[:options]
    
    unless options.is_a?(Array) && options.length >= 2
      @errors << "Ordering/ranking questions must have at least 2 items"
      return
    end
    
    if options.length > 10
      @warnings << "Ordering/ranking questions with more than 10 items may be difficult to display"
    end
    
    # Check for duplicate items
    if options.uniq.length != options.length
      @warnings << "Ordering/ranking items contain duplicates"
    end
  end

  def validate_diagram_label
    options = @question_data[:options]
    
    unless options.is_a?(Hash)
      @errors << "Diagram label questions must have options hash"
      return
    end
    
    # Image is required
    unless options['image'].present?
      @errors << "Diagram label questions must specify an image"
    end
    
    # Labels are required
    unless options['labels'].is_a?(Array) && options['labels'].any?
      @errors << "Diagram label questions must have labels array"
    end
    
    # Validate markers if present
    if options['markers'].present?
      unless options['markers'].is_a?(Array)
        @errors << "Markers must be an array"
        return
      end
      
      options['markers'].each_with_index do |marker, index|
        unless marker.is_a?(Hash) && marker['x'].present? && marker['y'].present?
          @errors << "Marker #{index + 1} must have x and y coordinates"
        end
        
        if marker['x'].present? && (marker['x'].to_f < 0 || marker['x'].to_f > 100)
          @errors << "Marker #{index + 1} x coordinate must be between 0 and 100"
        end
        
        if marker['y'].present? && (marker['y'].to_f < 0 || marker['y'].to_f > 100)
          @errors << "Marker #{index + 1} y coordinate must be between 0 and 100"
        end
      end
    end
    
    # Warn if markers and labels count don't match
    if options['markers'].present? && options['labels'].present?
      if options['markers'].length != options['labels'].length
        @warnings << "Number of markers (#{options['markers'].length}) doesn't match number of labels (#{options['labels'].length})"
      end
    end
  end

  def validate_image_occlusion
    options = @question_data[:options]
    
    unless options.is_a?(Hash)
      @errors << "Image occlusion questions must have options hash"
      return
    end
    
    # Image is required
    unless options['image'].present?
      @errors << "Image occlusion questions must specify an image"
    end
    
    # Masks are optional but if present must be valid
    if options['masks'].present?
      unless options['masks'].is_a?(Array)
        @errors << "Masks must be an array"
        return
      end
      
      options['masks'].each_with_index do |mask, index|
        unless mask.is_a?(Hash)
          @errors << "Mask #{index + 1} must be a hash"
          next
        end
        
        required_fields = %w[x y w h]
        required_fields.each do |field|
          unless mask[field].present?
            @errors << "Mask #{index + 1} must have #{field} coordinate"
          end
        end
        
        # Validate coordinate ranges
        if mask['x'].present? && (mask['x'].to_f < 0 || mask['x'].to_f > 100)
          @errors << "Mask #{index + 1} x coordinate must be between 0 and 100"
        end
        
        if mask['y'].present? && (mask['y'].to_f < 0 || mask['y'].to_f > 100)
          @errors << "Mask #{index + 1} y coordinate must be between 0 and 100"
        end
        
        if mask['w'].present? && (mask['w'].to_f <= 0 || mask['w'].to_f > 100)
          @errors << "Mask #{index + 1} width must be between 0 and 100"
        end
        
        if mask['h'].present? && (mask['h'].to_f <= 0 || mask['h'].to_f > 100)
          @errors << "Mask #{index + 1} height must be between 0 and 100"
        end
      end
    end
  end

  def validate_composite
    options = @question_data[:options]
    
    unless options.is_a?(Hash) && options['parts'].is_a?(Array)
      @errors << "Composite questions must have parts array"
      return
    end
    
    parts = options['parts']
    
    if parts.empty?
      @errors << "Composite questions must have at least one part"
      return
    end
    
    if parts.length > 5
      @warnings << "Composite questions with more than 5 parts may be difficult to display"
    end
    
    parts.each_with_index do |part, index|
      unless part.is_a?(Hash)
        @errors << "Part #{index + 1} must be a hash"
        next
      end
      
      unless part['type'].present?
        @errors << "Part #{index + 1} must have a type"
      end
      
      unless part['content'].present?
        @errors << "Part #{index + 1} must have content"
      end
      
      unless part['points'].present? && part['points'].to_i > 0
        @errors << "Part #{index + 1} must have positive points"
      end
      
      # Validate part-specific requirements
      case part['type']
      when 'multiple_choice'
        unless part['options'].is_a?(Array) && part['options'].any?
          @errors << "Part #{index + 1} (multiple_choice) must have options array"
        end
      when 'calculation'
        if part['answer_label'].blank?
          @warnings << "Part #{index + 1} (calculation) should have answer_label"
        end
      end
    end
  end

  def validate_calculation
    if @question_data[:answer_label].blank?
      @warnings << "Calculation questions should have answer_label"
    end
    
    if @question_data[:unit].blank?
      @warnings << "Calculation questions should have unit"
    end
  end

  def validate_options_structure
    # General validation for options structure
    options = @question_data[:options]
    
    if options.present?
      unless options.is_a?(Array) || options.is_a?(Hash)
        @errors << "Options must be an array or hash"
      end
    end
  end
end
