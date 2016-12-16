require 'test_helper'

class VersionTest < Test::Unit::TestCase

  def test_current_version
    assert_equal "0.4.2", Diarize::VERSION
  end

end
