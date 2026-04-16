class PdfRenderer
  DEFAULT_OPTIONS = {
    emulate_media: 'print',
    print_background: true,
    prefer_css_page_size: true,
    wait_until: 'domcontentloaded',
    timeout: 45_000
  }.freeze

  def self.render_to_pdf(html:, base_url:, **options)
    Grover.new(html, **DEFAULT_OPTIONS.merge(base_url: base_url, **options)).to_pdf
  end
end
