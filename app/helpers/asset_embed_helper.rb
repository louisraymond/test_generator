module AssetEmbedHelper
  # Render an <img> using a data URI when the asset exists locally.
  # Falls back to asset_path or direct URL when embedding isn't possible.
  def embedded_image_tag(path, alt: '', **html_options)
    return image_tag('', alt: alt, **html_options) if path.blank?

    # Absolute URLs or data URIs: just pass through
    if path.start_with?('http://', 'https://', 'data:')
      return image_tag(path, alt: alt, **html_options)
    end

    file_path = Rails.root.join('app', 'assets', 'images', path)

    if File.file?(file_path)
      mime = Rack::Mime.mime_type(File.extname(file_path), 'application/octet-stream')
      data = Base64.strict_encode64(File.binread(file_path))
      data_uri = "data:#{mime};base64,#{data}"
      image_tag(data_uri, alt: alt, **html_options)
    else
      # Fall back to the asset pipeline path
      image_tag(asset_path(path), alt: alt, **html_options)
    end
  end
end

