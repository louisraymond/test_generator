class QuestionRowParser
  def initialize(row_data, row_number)
    @row_data = row_data
    @row_number = row_number
    @errors = []
  end

  def parse
    parsed_data = {
      topic: extract_field('topic'),
      question_type: extract_field('question_type'),
      content: extract_field('content'),
      answer: extract_field('answer'),
      points: extract_field('points').to_i,
      answer_size: extract_field('answer_size'),
      source: extract_field('source'),
      source_reference: extract_field('source_reference'),
      answer_label: extract_field('answer_label'),
      unit: extract_field('unit')
    }

    # Validate required fields
    validate_required_fields(parsed_data)

    # Parse type-specific data
    parsed_data[:options] = parse_type_specific_options(parsed_data[:question_type])

    parsed_data
  end

  def errors
    @errors
  end

  private

  def extract_field(field_name)
    field_index = field_index_map[field_name]
    return nil unless field_index && @row_data[field_index]
    
    value = @row_data[field_index]
    value.present? ? value.strip : nil
  end

  def field_index_map
    @field_index_map ||= {
      'topic' => 0,
      'question_type' => 1,
      'content' => 2,
      'answer' => 3,
      'points' => 4,
      'answer_size' => 5,
      'source' => 6,
      'source_reference' => 7,
      'answer_label' => 8,
      'unit' => 9,
      'options' => 10,
      'left_items' => 11,
      'right_items' => 12,
      'image' => 13,
      'labels' => 14,
      'markers' => 15,
      'masks' => 16,
      'parts' => 17
    }
  end

  def validate_required_fields(data)
    required_fields = %w[topic question_type content answer points]
    
    required_fields.each do |field|
      if data[field.to_sym].blank?
        @errors << "Missing required field: #{field}"
      end
    end

    # Validate question_type
    if data[:question_type].present? && !Question::QUESTION_TYPES.include?(data[:question_type])
      @errors << "Invalid question_type: #{data[:question_type]}. Must be one of: #{Question::QUESTION_TYPES.join(', ')}"
    end

    # Validate points
    if data[:points].present? && (data[:points] < 1 || data[:points] > 100)
      @errors << "Points must be between 1 and 100, got: #{data[:points]}"
    end

    # Validate answer_size
    if data[:answer_size].present? && !Question::ANSWER_SIZES.include?(data[:answer_size])
      @errors << "Invalid answer_size: #{data[:answer_size]}. Must be one of: #{Question::ANSWER_SIZES.join(', ')}"
    end
  end

  def parse_type_specific_options(question_type)
    case question_type
    when 'multiple_choice'
      parse_multiple_choice_options
    when 'matching'
      parse_matching_options
    when 'ordering', 'ranking'
      parse_ordering_options
    when 'diagram_label'
      parse_diagram_label_options
    when 'image_occlusion'
      parse_image_occlusion_options
    when 'composite'
      parse_composite_options
    else
      []
    end
  end

  def parse_multiple_choice_options
    options_text = extract_field('options')
    return [] if options_text.blank?
    
    options = parse_pipe_separated(options_text)
    if options.empty?
      @errors << "Multiple choice questions require at least 2 options"
    end
    options
  end

  def parse_matching_options
    left_items = extract_field('left_items')
    right_items = extract_field('right_items')
    
    if left_items.blank? || right_items.blank?
      @errors << "Matching questions require both left_items and right_items"
      return {}
    end
    
    left_array = parse_pipe_separated(left_items)
    right_array = parse_pipe_separated(right_items)
    
    if left_array.length != right_array.length
      @errors << "Left and right items must have the same length"
    end
    
    {
      'left' => left_array,
      'right' => right_array
    }
  end

  def parse_ordering_options
    options_text = extract_field('options')
    return [] if options_text.blank?
    
    options = parse_pipe_separated(options_text)
    if options.length < 2
      @errors << "Ordering/ranking questions require at least 2 items"
    end
    options
  end

  def parse_diagram_label_options
    options = {}
    
    image = extract_field('image')
    if image.present?
      options['image'] = image
    end
    
    labels_text = extract_field('labels')
    if labels_text.present?
      options['labels'] = parse_pipe_separated(labels_text)
    end
    
    markers_text = extract_field('markers')
    if markers_text.present?
      begin
        options['markers'] = JSON.parse(markers_text)
      rescue JSON::ParserError
        @errors << "Invalid markers JSON: #{markers_text}"
      end
    end
    
    options
  end

  def parse_image_occlusion_options
    options = {}
    
    image = extract_field('image')
    if image.present?
      options['image'] = image
    end
    
    masks_text = extract_field('masks')
    if masks_text.present?
      begin
        options['masks'] = JSON.parse(masks_text)
      rescue JSON::ParserError
        @errors << "Invalid masks JSON: #{masks_text}"
      end
    end
    
    options
  end

  def parse_composite_options
    parts_text = extract_field('parts')
    return {} if parts_text.blank?
    
    begin
      parts = JSON.parse(parts_text)
      unless parts.is_a?(Array)
        @errors << "Composite parts must be an array"
        return {}
      end
      
      parts.each_with_index do |part, index|
        unless part.is_a?(Hash)
          @errors << "Part #{index + 1} must be a hash"
          next
        end
        
        unless part['type'].present? && part['content'].present?
          @errors << "Part #{index + 1} must have type and content"
        end
        
        if part['type'] == 'multiple_choice' && (!part['options'].is_a?(Array) || part['options'].empty?)
          @errors << "Part #{index + 1} (multiple_choice) must have options array"
        end
      end
      
      { 'parts' => parts }
    rescue JSON::ParserError
      @errors << "Invalid parts JSON: #{parts_text}"
      {}
    end
  end

  def parse_pipe_separated(text)
    return [] if text.blank?
    
    text.split('|').map(&:strip).reject(&:blank?)
  end
end
