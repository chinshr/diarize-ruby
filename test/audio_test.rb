require 'test_helper'
require 'ostruct'

class AudioTest < Test::Unit::TestCase

  def setup
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    @audio = Diarize::Audio.new audio_uri
  end

  def test_initialize_file_uri
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.uri, audio_uri
    assert_equal audio.path, File.join(File.dirname(__FILE__), 'data', 'foo.wav')
  end

  def test_initialize_http_uri
    audio_url = 'http://example.com/test.wav'
    hash = Digest::MD5.hexdigest(audio_url)
    File.expects(:new).with('/tmp/' + hash).returns(true)
    stub_request(:get, audio_url).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
    audio = Diarize::Audio.new URI(audio_url)
    assert_equal audio.path, '/tmp/' + hash
  end

  def test_clean_local_file
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).never
    audio.clean!
  end

  def test_clean_http_file
    audio_url = 'http://example.com/test.wav'
    hash = Digest::MD5.hexdigest(audio_url)
    File.expects(:new).with('/tmp/' + hash).returns(true)
    stub_request(:get, audio_url).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
    audio = Diarize::Audio.new URI(audio_url)
    File.expects(:delete).with('/tmp/' + hash).returns(true)
    audio.clean!
  end

  def test_segments_raises_exception_when_audio_is_not_analysed
    assert_raise Exception do
      @audio.segments
    end
  end

  def test_analyze
    # TODO - We don't test the full ESTER2 algorithm for now
  end

  def test_segments
    @audio.instance_variable_set('@segments', [1, 2, 3])
    assert_equal @audio.segments, [1, 2, 3]
  end

  def test_speakers_is_cached
    @audio.instance_variable_set('@speakers', [1, 2, 3])
    assert_equal @audio.speakers, [1, 2, 3]
  end

  def test_speakers
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.speakers, ['s1', 's2']
  end

  def test_segments_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.segments_by_speaker('s1'), [ segment1, segment1 ]
    assert_equal @audio.segments_by_speaker('s2'), [ segment2 ]
  end

  def test_duration_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.duration_by_speaker('s1'), 4
    assert_equal @audio.duration_by_speaker('s2'), 3
  end

  def test_top_speakers
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.top_speakers, ['s1', 's2']
  end

  def test_set_uri_and_type_uri
    @audio.uri = 'foo'
    @audio.type_uri = 'bar'
    assert_equal @audio.uri, 'foo'
    assert_equal @audio.type_uri, 'bar'
  end

  def test_show
    assert_equal @audio.show, 'foo'
  end

end
