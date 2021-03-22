require 'fileutils'

require 'test_helper'
require 'rdoc_toc/version'

class RDocTocTest < Minitest::Test
  def test_version
    refute_nil ::RDocToc::VERSION
  end

  # Default options.
  def test_empty
    make_toc_file('empty', '', '', {})
    embed_toc('empty', '', '', {})
  end

  def test_six_levels
    rdoc_string = six_levels_rdoc
    exp_toc_string = <<-EOT
- {Header 1}[#label-Header+1]
  - {Header 2}[#label-Header+2]
    - {Header 3}[#label-Header+3]
      - {Header 4}[#label-Header+4]
        - {Header 5}[#label-Header+5]
          - {Header 6}[#label-Header+6]
    EOT
    make_toc_file('six_levels', rdoc_string, exp_toc_string, {})
    # embed_toc('six_levels', rdoc_string, exp_toc_string, {})
  end

  def test_tree
    exp_toc_string = <<-EOT
- {Header 1}[#label-Header+1]
  - {Header 1.1}[#label-Header+1.1]
    - {Header 1.1.1}[#label-Header+1.1.1]
    - {Header 1.1.2}[#label-Header+1.1.2]
  - {Header 1.2}[#label-Header+1.2]
    - {Header 1.2.1}[#label-Header+1.2.1]
    - {Header 1.2.2}[#label-Header+1.2.2]
- {Header 2}[#label-Header+2]
  - {Header 2.1}[#label-Header+2.1]
    - {Header 2.1.1}[#label-Header+2.1.1]
    - {Header 2.1.2}[#label-Header+2.1.2]
  - {Header 2.2}[#label-Header+2.2]
    - {Header 2.2.1}[#label-Header+2.2.1]
    - {Header 2.2.2}[#label-Header+2.2.2]
    EOT
    make_toc_file('tree', tree_rdoc, exp_toc_string, {})
  end

  def test_title
    exp_toc_string = <<-EOT
= Contents
- {Header 1}[#label-Header+1]
  - {Header 2}[#label-Header+2]
    - {Header 3}[#label-Header+3]
      - {Header 4}[#label-Header+4]
        - {Header 5}[#label-Header+5]
          - {Header 6}[#label-Header+6]
    EOT
    make_toc_file('title', six_levels_rdoc, exp_toc_string, {title: 'Contents'})
  end

  def test_indent_0
    exp_toc_string = <<-EOT
- {Header 1}[#label-Header+1]
- {Header 1.1}[#label-Header+1.1]
- {Header 1.1.1}[#label-Header+1.1.1]
- {Header 1.1.2}[#label-Header+1.1.2]
- {Header 1.2}[#label-Header+1.2]
- {Header 1.2.1}[#label-Header+1.2.1]
- {Header 1.2.2}[#label-Header+1.2.2]
- {Header 2}[#label-Header+2]
- {Header 2.1}[#label-Header+2.1]
- {Header 2.1.1}[#label-Header+2.1.1]
- {Header 2.1.2}[#label-Header+2.1.2]
- {Header 2.2}[#label-Header+2.2]
- {Header 2.2.1}[#label-Header+2.2.1]
- {Header 2.2.2}[#label-Header+2.2.2]
    EOT
    make_toc_file('indentation', tree_rdoc, exp_toc_string, {indentation: 0})
  end

  def test_bad_indentation_class
    e = assert_raises RDocToc::IndentationException do
      RDocToc.toc_string(tree_rdoc, {indentation: false})
    end
    assert_match('non-negative', e.message)
  end

  def test_bad_indentation_value
    e = assert_raises RDocToc::IndentationException do
      RDocToc.toc_string(tree_rdoc, {indentation: -1})
    end
    assert_match('non-negative', e.message)
  end

  def test_bad_level_jump
    rdoc_string = "= Foo\n=== Bar\n"
    e = assert_raises RDocToc::LevelException do
      RDocToc.toc_string(rdoc_string)
    end
    assert_match('2 or more', e.message)
  end

  def test_bad_level
    rdoc_string = "== Foo\n= Bar\n"
    e = assert_raises RDocToc::LevelException do
      RDocToc.toc_string(rdoc_string)
    end
    assert_match('first seen level', e.message)
  end

  def six_levels_rdoc
    <<-EOT
= Header 1
:toc:
== Header 2
=== Header 3
==== Header 4
===== Header 5
====== Header 6
    EOT
  end

  def tree_rdoc
    <<-EOT
:toc:
= Header 1
== Header 1.1
=== Header 1.1.1
=== Header 1.1.2
== Header 1.2
=== Header 1.2.1
=== Header 1.2.2
= Header 2
== Header 2.1
=== Header 2.1.1
=== Header 2.1.2
== Header 2.2
=== Header 2.2.1
=== Header 2.2.2
    EOT
  end

  def make_toc_file(name, rdoc_string, exp_toc_string, options = {})
    Dir.mktmpdir do |dir_path|
      rdoc_file_path = File.join(dir_path, 't.rdoc')
      File.write(rdoc_file_path, rdoc_string)
      exp_toc_file_path = File.join(dir_path, 'exp_toc.rdoc')
      File.write(exp_toc_file_path, exp_toc_string)
      act_toc_file_path = File.join(dir_path, 'act_toc.rdoc')
      # API
      RDocToc.toc_file(rdoc_file_path, act_toc_file_path, options)
      message = "#{__method__} API #{name}"
      assert_file_equal(exp_toc_file_path, act_toc_file_path, message)
      # CLI
      options_string = ''
      options.each_pair do |name, value|
        options_string += " --#{name.to_s} #{value}"
      end
      command = "rdoc_toc make_toc_file #{rdoc_file_path} #{act_toc_file_path} #{options_string}"
      system(command)
      message = "#{__method__} CLI #{name}"
      assert_file_equal(exp_toc_file_path, act_toc_file_path, message)
    end
  end

  def embed_toc(name, rdoc_string, exp_rdoc_string, options = {})
    Dir.mktmpdir do |dir_path|
      # API
      rdoc_file_path = File.join(dir_path, 't.rdoc')
      File.write(rdoc_file_path, rdoc_string)
      RDocToc.embed_toc(rdoc_file_path, options)
      act_rdoc_string = File.read(rdoc_file_path)
      assert_equal(exp_rdoc_string, act_rdoc_string, name)
      # CLI
      # This file was overwritten by API above, needs refresh.
      File.write(rdoc_file_path, rdoc_string)
      options_string = ''
      options.each_pair do |name, value|
        options_string += " --#{name.to_s} #{value}"
      end
      command = "rdoc_toc embed_toc #{rdoc_file_path} #{options_string}"
      system(command)
      assert_equal(act_rdoc_string, File.read(rdoc_file_path), name)
    end
  end

  def assert_file_equal(exp_file_path, act_file_path, message)
    equal = FileUtils.cmp(exp_file_path, act_file_path)
    if equal
      assert(equal, message)
      return
    end
    exp_toc_string = File.read(exp_file_path)
    act_toc_string = File.read(act_file_path)
    assert_equal(exp_toc_string, act_toc_string, message)
  end
end
