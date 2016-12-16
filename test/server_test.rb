require 'test_helper'

class ServerTest < Test::Unit::TestCase

  def test_build_audio_server_wrapper
    server = Diarize::Server.new
    audio = server.build_audio(URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav')))
    assert_equal Diarize::Audio, audio.class
  end

  def test_build_speaker_server_wrapper
    server = Diarize::Server.new
    # build with uri and gender
    speaker = server.build_speaker("http://www.example.com", "M")
    assert_equal Diarize::Speaker, speaker.class
    # load from model
    speaker = server.build_speaker(nil, nil, File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    assert_equal Diarize::Speaker, speaker.class
  end

end
