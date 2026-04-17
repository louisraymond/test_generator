class PdfRenderer
  # `networkidle0` waits until the page has had zero network connections for
  # 500ms — enough for the CDN-loaded KaTeX script + fonts to settle before
  # Chromium snapshots, which the prior `domcontentloaded` missed (math would
  # ship as raw `$…$` intermittently).
  DEFAULT_OPTIONS = {
    emulate_media: 'print',
    print_background: true,
    prefer_css_page_size: true,
    wait_until: 'networkidle0',
    timeout: 60_000
  }.freeze

  def self.render_to_pdf(html:, base_url:, **options)
    # Grover recognises `display_url`, not `base_url`. With display_url set,
    # Chromium treats the page as if it were served from that URL, so relative
    # `/assets/...` paths in the HTML resolve against the running Rails server.
    Grover.new(html, **DEFAULT_OPTIONS.merge(display_url: base_url, **options)).to_pdf
  end
end
