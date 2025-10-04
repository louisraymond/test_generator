module MarkdownHelper
  # Very small, safe markdown renderer supporting inline code and fenced code blocks.
  # We deliberately avoid adding a gem here; expand later if needed.
  def render_markdown(md)
    src = md.to_s

    lines = src.split(/\r?\n/, -1)
    parts = []
    buf = []
    in_code = false
    code_lang = ''
    code_lines = []

    flush_buf = lambda do
      return if buf.empty?
      text = buf.join("\n")
      # Inline code first
      text = text.gsub(/`([^`]+)`/) { %(<code class="md-inline">#{ERB::Util.html_escape($1)}</code>) }
      # Paragraphize by blank lines
      text.split(/\n{2,}/).each do |para|
        parts << "<p>#{para.gsub(/\n/, '<br>')}</p>"
      end
      buf.clear
    end

    lines.each do |line|
      stripped = line.lstrip
      if !in_code && stripped.start_with?('```')
        # Opening fence; capture language token after backticks (if any)
        code_lang = stripped.sub(/^```/, '').strip
        in_code = true
        flush_buf.call
        code_lines = []
      elsif in_code && stripped.start_with?('```')
        # Closing fence
        code = ERB::Util.html_escape(code_lines.join("\n"))
        parts << %(<pre class="md-code"><code class="language-#{code_lang}">#{code}</code></pre>)
        in_code = false
        code_lang = ''
      else
        if in_code
          code_lines << line
        else
          buf << ERB::Util.html_escape(line)
        end
      end
    end
    flush_buf.call

    html = parts.join
    sanitize(html, tags: %w[p br pre code strong em a ul ol li span], attributes: %w[class href])
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

  # Render only inline markdown (no fenced blocks) for headers/prompts.
  def render_markdown_inline(md)
    text = ERB::Util.html_escape(md.to_s)
    text = text.gsub(/`([^`]+)`/) { %(<code class="md-inline">#{$1}</code>) }
    html = text.split(/\n{2,}/).map { |para| "<p>#{para.gsub(/\n/, '<br>')}</p>" }.join
    sanitize(html, tags: %w[p br code span], attributes: %w[class])
  end
end
