require 'cgi'
require 'rdoc'
require 'rdoc/markup/formatter'

require 'rdoc_toc/version'

class RDocToc

  def self.toc(rdoc_file_path, toc_file_path, options = {})
    default_options = {
      title: nil
    }
    options = default_options.merge(options)

    rdoc_string = File.read(rdoc_file_path)
    markup = RDoc::Markup.parse(rdoc_string)
    doc = RDoc::Markup::Document.new(markup)
    to_label = RDoc::Markup::ToLabel.new

    toc_lines = []
    if options[:title]
      toc_lines.push("= #{options[:title]}")
    end
    doc.table_of_contents.each do |header|
      text = header.text
      href = to_label.convert(text)
      indent = '  ' * (header.level - 1)
      toc_line = "#{indent}- {#{text}}[#label-#{href}]"
      toc_lines.push(toc_line)
    end
    toc_lines.push('')
    toc_string = toc_lines.join("\n")
    File.write(toc_file_path, toc_string)
  end

end
