module QuestionOptions
  # Image occlusion: { image, masks: [{x,y,w,h,answer,shape}] }.
  class ImageOcclusionOptions < Base
    Mask = Data.define(:x, :y, :w, :h, :answer, :accepts, :shape)

    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      masks = Array(hash['masks'] || hash[:masks]).map do |m|
        next unless m.is_a?(Hash)
        Mask.new(
          x:       (m['x'] || m[:x] || 0).to_f,
          y:       (m['y'] || m[:y] || 0).to_f,
          w:       (m['w'] || m[:w] || 0).to_f,
          h:       (m['h'] || m[:h] || 0).to_f,
          answer:  (m['answer'] || m[:answer] || '').to_s,
          accepts: Array(m['accepts'] || m[:accepts]).map(&:to_s),
          shape:   (m['shape'] || m[:shape] || 'rect').to_s
        )
      end.compact
      new(
        image: (hash['image'] || hash[:image]).to_s.presence,
        image_blob_id: (hash['image_blob_id'] || hash[:image_blob_id]),
        masks: masks
      )
    end

    def initialize(image: nil, image_blob_id: nil, masks: [])
      @image, @image_blob_id, @masks = image, image_blob_id, masks
    end
    attr_reader :image, :image_blob_id, :masks

    def to_jsonb
      {
        'image'         => image,
        'image_blob_id' => image_blob_id,
        'masks'         => masks.map do |m|
          { 'x' => m.x, 'y' => m.y, 'w' => m.w, 'h' => m.h,
            'answer' => m.answer, 'accepts' => m.accepts, 'shape' => m.shape }
        end
      }.compact
    end

    def validate(errors)
      if image.blank? && image_blob_id.blank?
        errors.add(:options, "should include 'image' and optional 'masks' array")
      end
    end
  end
end
