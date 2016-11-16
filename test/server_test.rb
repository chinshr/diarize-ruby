require 'test_helper'

class ServerTest < Test::Unit::TestCase

  def test_build_audio_server_wrapper
    server = Diarize::Server.new
    audio = server.build_audio(URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav')))
    assert_equal Diarize::Audio, audio.class
  end

end
