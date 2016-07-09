require 'rubygems'
require 'test/unit'
require 'test/unit/assertions'
require 'diarize'
require 'mocha/test_unit'

class Test::Unit::TestCase

  # Add global extensions to the test case class here

  # E.g. "/Users/foo/work/test"
  def test_root
    File.dirname(__FILE__)
  end

  def fixtures_root
    "#{test_root}/data"
  end

end
