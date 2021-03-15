require 'test_helper'

class RDocTocTest < Minitest::Test
  def test_version
    refute_nil ::RDocToc::VERSION
  end

  def test_empty
    do_good('', 'empty.toc')
  end

  def test_six_levels
    do_good(six_levels_rdoc, 'six_levels.toc')
  end

  def test_tree
    do_good(tree_rdoc, 'tree.toc')
  end

  def test_title
    do_good(six_levels_rdoc, 'title.toc', {title: 'Contents'})
  end

  def test_indent
    do_good(tree_rdoc, 'indentation.toc', {indentation: 2})
  end

  def six_levels_rdoc
    <<-EOT
= Header 1
== Header 2
=== Header 3
==== Header 4
===== Header 5
====== Header 6
    EOT
  end

  def tree_rdoc
    <<-EOT
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

  def do_good(rdoc_string, exp_toc_file_path, options = {})
    exp_toc_file_path = File.join('test', 'files', exp_toc_file_path)
    Dir.mktmpdir do |tmp_dir_path|
      rdoc_file_path = File.join(tmp_dir_path, 'input.rdoc')
      File.write(rdoc_file_path, rdoc_string)
      act_toc_file_path = File.join(tmp_dir_path, 'output.toc')
      RDocToc.toc_file(rdoc_file_path, act_toc_file_path, options)
      assert_files(exp_toc_file_path, act_toc_file_path, exp_toc_file_path)
    end

  end

  def assert_files(exp_file_path, act_file_path, file_base_name)
    if FileUtils.compare_file(exp_file_path, act_file_path)
      assert(true)
      return
    end
    exp_toc = File.read(exp_file_path)
    act_toc = File.read(act_file_path)
    assert_equal(exp_toc, act_toc, file_base_name)
  end

end
