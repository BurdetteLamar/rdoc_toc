require 'cgi'
require 'rdoc'
require 'rdoc/markup/formatter'

require 'rdoc_toc/version'

class RDocToc

  class RDocTocException < StandardError; end
  class LevelException < RDocTocException; end
  class IndentationException < RDocTocException; end

  def self.toc_lines(rdoc_string, options = {})
    default_options = {
      title: nil,
      indentation: 0,
      linked_file_path: nil
    }
    opts = default_options.merge(options)
    values = opts.values_at(*default_options.keys)
    title, indent, linked_file_path = *values

    if (!indent.kind_of?(Integer)) || (indent < 0)
      message = "Option indent must be a non-negative integer, not #{indent}"
      raise IndentationException.new(message)
    end

    markup = RDoc::Markup.parse(rdoc_string)
    doc = RDoc::Markup::Document.new(markup)
    to_label = RDoc::Markup::ToLabel.new

    toc_lines = []
    toc_lines.push("= #{title}") if title

    headers = doc.table_of_contents

    unless headers.empty?
      first_header = headers.first
      headers.each_cons(2) do |a, b|
        if b.level < first_header.level
          message = <<-EOT
Level may not be < first seen level:
  #{b.level}
  #{first_header.level}"
          EOT
          raise LevelException.new(message)
        end
        if b.level > a.level + 1
          message = <<-EOT
  Level may not be 2 or more greater than its predecessor:
    #{a.inspect}
    #{b.inspect}
          EOT
          raise LevelException.new(message)
        end
      end
    end


    headers.each do |header|
      indentation = ' ' * (header.level - 1) * indent
      # if (indentation.size > 0) || top_bullets
      bullet = '- '
      # else
      #   bullet = ''
      # end

      text = header.text
      href = "#label-#{to_label.convert(text)}"
      href = File.join(linked_file_path, href) if linked_file_path
      toc_line = "#{indentation}#{bullet}{#{text}}[#{href}]"
      toc_lines.push(toc_line)
    end
    toc_lines.push('')
    toc_lines
  end

  def self.toc_string(rdoc_string, options = {})
    self.toc_lines(rdoc_string, options).join($/)
  end


  def self.toc_file(rdoc_file_path, toc_file_path, options = {})
    default_options = {
      title: nil,
      indentation: 0,
      linked_file_path: nil
    }
    opts = default_options.merge(options)
    values = opts.values_at(*default_options.keys)
    title, indent, linked_file_path = *values

    rdoc_string = File.read(rdoc_file_path)
    markup = RDoc::Markup.parse(rdoc_string)
    doc = RDoc::Markup::Document.new(markup)
    to_label = RDoc::Markup::ToLabel.new

    toc_lines = []
    toc_lines.push("= #{title}") if title

    doc.table_of_contents.each do |header|
      indentation = ' ' * (header.level - 1) * indent
      # if (indentation.size > 0) || top_bullets
      bullet = '- '
      # else
      #   bullet = ''
      # end

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
