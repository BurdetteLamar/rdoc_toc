require 'cgi'
require 'rdoc'
require 'rdoc/markup/formatter'

class RDocToc

  class RDocTocException < StandardError; end
  class LevelException < RDocTocException; end
  class IndentationException < RDocTocException; end

  DEFAULT_OPTIONS = {
    title: nil,
    indentation: 2,
    linked_file_path: nil
  }

  def self.toc_lines(rdoc_string, options = {})
    opts = DEFAULT_OPTIONS.merge(options)
    values = opts.values_at(*DEFAULT_OPTIONS.keys)
    title, indentation, linked_file_path = *values
    indentation = indentation.to_i if indentation.respond_to?(:to_i)

    if (!indentation.kind_of?(Integer)) || (indentation < 0)
      message = "Option indentation must be a non-negative integer, not #{indentation}"
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
        if (indentation > 0) && (b.level > a.level + 1)
          message = <<-EOT
  Level may not be 2 or more greater than its predecessor:
    #{a.inspect}
    #{b.inspect}
  Consider setting indentation to 0.
          EOT
          raise LevelException.new(message)
        end
      end
    end

    headers.each do |header|
      indent = ' ' * (header.level - first_header.level) * indentation
      bullet = '- '
      text = header.text
      href = "#label-#{to_label.convert(text)}"
      href = File.join(linked_file_path, href) if linked_file_path
      toc_line = "#{indent}#{bullet}{#{text}}[#{href}]"
      toc_lines.push(toc_line)
    end
    toc_lines.push('')
    toc_lines
  end

  def self.toc_string(rdoc_string, options = {})
    self.toc_lines(rdoc_string, options).join($/)
  end

  def self.toc_file(rdoc_file_path, toc_file_path, options = {})
    rdoc_string = File.read(rdoc_file_path)
    toc_string = self.toc_string(rdoc_string, options)
    File.write(toc_file_path, toc_string)
  end

  def self.embed_toc(rdoc_file_path, options = {})
    rdoc_string = File.read(rdoc_file_path)
    rdoc_lines = rdoc_string.lines.to_a
    # Find the line with :toc: directive.
    # # Accumulate all lines following that for toc.
    toc_line_index = nil
    toc_line_prefix = nil
    toccable_lines = []
    rdoc_lines.each_with_index do |line, i|
      line.chomp
      if line.match(/:toc:/)
        toc_line_index = i
        toc_line_prefix = line.split(':toc:').first
      else
        toccable_lines.push(toc_line_prefix + line) if toc_line_index
      end
    end
    return unless toc_line_index
    # Make and insert toc.
    toccable_string = toccable_lines.join
    toc_string = self.toc_string(toccable_string, options)
    rdoc_lines.delete_at(toc_line_index)
    rdoc_lines.insert(toc_line_index, toc_string)
    # Write tocced rdoc.
    rdoc_string = rdoc_lines.join
    File.write(rdoc_file_path, rdoc_string)
  end
end
