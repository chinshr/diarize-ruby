require 'test_helper'
require 'ostruct'
require 'uri'

class SegmentTest < Test::Unit::TestCase

  def test_initialize
    segment = Diarize::Segment.new('audio', 'start', 'duration', 'gender', 'bandwidth', 'speaker_id')

    # instance variables
    assert_equal 'audio', segment.instance_variable_get('@audio')
    assert_equal 'start', segment.instance_variable_get('@start')
    assert_equal 'duration', segment.instance_variable_get('@duration')
    assert_equal 'gender', segment.instance_variable_get('@speaker_gender')
    assert_equal 'bandwidth', segment.instance_variable_get('@bandwidth')
    assert_equal 'speaker_id', segment.instance_variable_get('@speaker_id')

    # attr readers
    assert_equal 'start', segment.start
    assert_equal 'duration', segment.duration
    assert_equal 'bandwidth', segment.bandwidth
    assert_equal 'gender', segment.speaker_gender
    assert_equal 'speaker_id', segment.speaker_id
  end

  def test_speaker
    segment = Diarize::Segment.new(OpenStruct.new({:base_uri => 'http://example.com'}), nil, nil, 'm', nil, 's1') 
    assert_equal segment.speaker.object_id, segment.speaker.object_id # same one should be generated twice
    assert_equal segment.speaker.uri, URI('http://example.com#s1')
    assert_equal segment.speaker.gender, 'm'
  end

  def test_uri
    segment = Diarize::Segment.new(OpenStruct.new({:base_uri => 'http://example.com'}), 2, 5, 'm', nil, 's1')
    assert_equal segment.uri, URI('http://example.com#t=2,7')
  end

end
