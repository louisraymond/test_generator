module QuestionOptions
  # Diagram label: { image, pins: [{x,y,answer,accepts}] }.
  # Legacy also used `markers` and `labels` keys; we accept both.
  class DiagramLabelOptions < Base
    Pin = Data.define(:x, :y, :answer, :accepts)

    def self.from(raw)
      hash = raw.is_a?(Hash) ? raw : {}
      raw_pins = Array(hash['pins'] || hash[:pins] || hash['markers'] || hash[:markers])
      pins = raw_pins.map do |m|
        next unless m.is_a?(Hash)
        Pin.new(
          x:       (m['x']       || m[:x]       || 0).to_f,
          y:       (m['y']       || m[:y]       || 0).to_f,
          answer:  (m['answer']  || m[:answer]  || '').to_s,
          accepts: Array(m['accepts'] || m[:accepts]).map(&:to_s)
        )
      end.compact
      labels = Array(hash['labels'] || hash[:labels]).map(&:to_s)
      new(
        image: (hash['image'] || hash[:image]).to_s.presence,
        image_blob_id: (hash['image_blob_id'] || hash[:image_blob_id]),
        pins: pins,
        labels: labels
      )
    end

    def initialize(image: nil, image_blob_id: nil, pins: [], labels: [])
      @image, @image_blob_id, @pins, @labels = image, image_blob_id, pins, labels
    end
    attr_reader :image, :image_blob_id, :pins, :labels

    def to_jsonb
      {
        'image'         => image,
        'image_blob_id' => image_blob_id,
        'pins'          => pins.map { |p| { 'x' => p.x, 'y' => p.y, 'answer' => p.answer, 'accepts' => p.accepts } },
        'labels'        => labels
      }.compact
    end

    def validate(errors)
      if image.blank? && image_blob_id.blank? && labels.empty? && pins.empty?
        errors.add(:options, "should include 'image' (asset path or URL) and 'labels' array")
      end
    end
  end
end
