module MarkdownHelper
  require 'redcarpet'
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  # Custom renderer with Rouge syntax highlighting
  class RougeRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  # Matches a LaTeX math span: $$...$$ (longest first) or single $...$ on one line.
  MATH_SPAN_PATTERN = /\$\$(?:[^$]|\$(?!\$))*?\$\$|\$[^$\n]+?\$/m

  MARKDOWN_EXTENSIONS = {
    autolink: true,
    tables: true,
    fenced_code_blocks: true,
    strikethrough: true,
    superscript: true,
    no_intra_emphasis: true,
    space_after_headers: true
  }.freeze

  BLOCK_MARKDOWN = Redcarpet::Markdown.new(
    RougeRenderer.new(hard_wrap: true, safe_links_only: true, with_toc_data: false),
    **MARKDOWN_EXTENSIONS
  )
  INLINE_MARKDOWN = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(filter_html: false),
    **MARKDOWN_EXTENSIONS.merge(fenced_code_blocks: false)
  )

  BLOCK_ALLOWED_TAGS = %w[p br h1 h2 h3 h4 h5 h6 strong em a ul ol li code pre
                          blockquote table thead tbody tr th td hr sup del img span div].freeze
  INLINE_ALLOWED_TAGS = %w[code strong em sup del].freeze
  ALLOWED_ATTRIBUTES = %w[href src alt title class id lang].freeze

  # Render full markdown with LaTeX support. KaTeX renders $...$/$$...$$ client-side;
  # math spans are extracted before Redcarpet runs so its extensions
  # (superscript, strikethrough, emphasis) don't mangle `x^2`, `a~b`, or `a_1`
  # inside formulas — while still processing `^` as superscript in plain prose.
  def render_markdown(text)
    return '' if text.blank?

    with_math_protected(text) do |t|
      sanitize(BLOCK_MARKDOWN.render(t), tags: BLOCK_ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
    end
  end

  # Split a markdown string at the first fenced code block. Returns [prompt, body].
  def markdown_split(md)
    lines = md.to_s.split(/\r?\n/, -1)
    idx = lines.index { |l| l.lstrip.start_with?('```') }
    if idx
      [lines[0...idx].join("\n"), lines[idx..-1].join("\n")]
    else
      [md.to_s, '']
    end
  end

  # Render inline-only markdown (strips the outer paragraph wrapper). Math-safe
  # identically to render_markdown. Uses Redcarpet for correctness on nested
  # emphasis and backticks.
  def render_markdown_inline(text)
    return '' if text.blank?

    with_math_protected(text) do |t|
      html = INLINE_MARKDOWN.render(t).sub(/\A<p>/, '').sub(%r{</p>\s*\z}, '')
      html = html.gsub('<code>', '<code class="md-inline">')
      sanitize(html, tags: INLINE_ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
    end
  end

  private

  # Replace every math span with an unambiguous placeholder, run the block on
  # the placeholder-bearing text, then swap math back in. Prevents Redcarpet
  # from touching LaTeX.
  def with_math_protected(text)
    token = SecureRandom.hex(8)
    spans = []
    protected_text = text.gsub(MATH_SPAN_PATTERN) do |match|
      spans << match
      "MATH#{token}#{spans.length - 1}ENDMATH"
    end
    rendered = yield(protected_text)
    # Restore math AFTER the caller's sanitize/post-processing so bare `&` / `<`
    # / `>` inside LaTeX (common in `\begin{aligned} x &= 1`) aren't escaped.
    # The final `.html_safe` reapplies the safe-buffer marker lost by `.gsub`.
    rendered.to_s.gsub(/MATH#{token}(\d+)ENDMATH/) { spans[Regexp.last_match(1).to_i] }.html_safe
  end
end
