require 'test_helper'

class RDocTocTest < Minitest::Test
  def test_version
    refute_nil ::RDocToc::VERSION
  end

  # Default options.
  def test_empty
    do_rdoc('empty', '', '', {})
  end

  def test_six_levels
    exp_toc_string = <<-EOT
- {Header 1}[#label-Header+1]
- {Header 2}[#label-Header+2]
- {Header 3}[#label-Header+3]
- {Header 4}[#label-Header+4]
- {Header 5}[#label-Header+5]
- {Header 6}[#label-Header+6]
    EOT
    do_rdoc('six_levels', six_levels_rdoc, exp_toc_string, {})
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
    do_rdoc('tree', tree_rdoc, exp_toc_string, {})
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
    do_rdoc('title', six_levels_rdoc, exp_toc_string, {title: 'Contents'})
  end

  def test_indent
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
    do_rdoc('indentation', tree_rdoc, exp_toc_string, {indentation: 2})
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

  def do_rdoc(name, rdoc_string, exp_toc_string, options = {})
    act_toc_string = RDocToc.toc_string(rdoc_string, options)
    assert_equal(exp_toc_string, act_toc_string, name)
  end

end
