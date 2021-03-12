require 'test_helper'

class RDocTocTest < Minitest::Test
  def test_version
    refute_nil ::RDocToc::VERSION
  end

  def test_good
    %w/
        empty
        six_levels
      /.each do |file_base_name|
      do_good(file_base_name)
    end
  end

  def test_title
    do_good('title', {title: 'Contents'})
  end

  def do_good(file_base_name, options = {})
    rdoc_file_name = file_base_name + '.rdoc'
    toc_file_name = file_base_name + '.toc'
    rdoc_file_path = File.join('test', 'files', rdoc_file_name)
    exp_toc_file_path = File.join('test', 'files', toc_file_name)
    Dir.mktmpdir do |tmp_dir_path|
      act_toc_file_path = File.join(tmp_dir_path, toc_file_name)
      RDocToc.toc(rdoc_file_path, act_toc_file_path, options)
      assert_files(exp_toc_file_path, act_toc_file_path, file_base_name)
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
