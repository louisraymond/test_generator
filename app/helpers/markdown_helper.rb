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
      if !in_code && line =~ /^\s*```([\w+-]*)\s*$/
        in_code = true
        code_lang = Regexp.last_match(1)
        flush_buf.call
        code_lines = []
      elsif in_code && line =~ /^\s*```\s*$/
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
end
