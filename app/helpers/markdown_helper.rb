module MarkdownHelper
  require 'redcarpet'
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  # Custom renderer with Rouge syntax highlighting
  class RougeRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  # Render full markdown with LaTeX support
  # LaTeX delimiters: $...$ for inline, $$...$$ for display
  def render_markdown(text)
    return '' if text.blank?

    renderer = RougeRenderer.new(
      hard_wrap: true,
      safe_links_only: true,
      with_toc_data: false
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      no_intra_emphasis: true,
      space_after_headers: true
    )

    # Render markdown and mark as html_safe
    # LaTeX will be rendered client-side by KaTeX
    markdown.render(text).html_safe
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

  # Render only inline markdown (no block elements) for simple formatting
  def render_markdown_inline(text)
    return '' if text.blank?

    # For inline, we just do simple replacements
    html = ERB::Util.html_escape(text)
    
    # Inline code
    html = html.gsub(/`([^`]+)`/) { %(<code class="md-inline">#{$1}</code>) }
    
    # Bold
    html = html.gsub(/\*\*([^\*]+)\*\*/) { %(<strong>#{$1}</strong>) }
    html = html.gsub(/__([^_]+)__/) { %(<strong>#{$1}</strong>) }
    
    # Italic
    html = html.gsub(/\*([^\*]+)\*/) { %(<em>#{$1}</em>) }
    html = html.gsub(/_([^_]+)_/) { %(<em>#{$1}</em>) }
    
    html.html_safe
  end
end
