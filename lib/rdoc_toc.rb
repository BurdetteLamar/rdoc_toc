require 'cgi'
require 'rdoc'
require 'rdoc/markup/formatter'

require 'rdoc_toc/version'

class RDocToc

  def self.toc_file(rdoc_file_path, toc_file_path, options = {})
    default_options = {
      title: nil,
      indentation: 0,
      top_bullets: false,
      linked_file_path: nil
    }
    opts = default_options.merge(options)
    values = opts.values_at(*default_options.keys)
    title, indent, top_bullets, linked_file_path = *values

    rdoc_string = File.read(rdoc_file_path)
    markup = RDoc::Markup.parse(rdoc_string)
    doc = RDoc::Markup::Document.new(markup)
    to_label = RDoc::Markup::ToLabel.new

    toc_lines = []
    toc_lines.push("= #{title}") if title

    doc.table_of_contents.each do |header|
      indentation = '  ' * (header.level - 1) * indent
      p indentation
      if (indentation.size > 0) || top_bullets
        bullet = '- '
      else
        bullet = ''
      end

      text = header.text
      href = "#label-#{to_label.convert(text)}"
      href = File.join(linked_file_path, href) if linked_file_path
      toc_line = "#{indentation}#{bullet}{#{text}}[#{href}]"
      toc_lines.push(toc_line)
    end
    toc_lines.push('')
    toc_string = toc_lines.join($/)
    File.write(toc_file_path, toc_string)
  end

end
