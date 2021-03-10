require 'test_helper'

class RdocTocTest < Minitest::Test
  def test_version
    refute_nil ::RdocToc::VERSION
  end

end
