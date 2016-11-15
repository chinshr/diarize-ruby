require 'rubygems'
require 'to_rdf'
require 'uri'

module Diarize
  class Segment
    include ToRdf

    attr_reader :start, :duration, :gender, :bandwidth

    def initialize(audio, start, duration, gender, bandwidth, speaker_id)
      @audio = audio
      @start = start
      @duration = duration
      @bandwidth = bandwidth
      @speaker_id = speaker_id
      @speaker_gender = gender
    end

    def speaker
      Speaker.find_or_create(URI("#{@audio.base_uri}##{@speaker_id}"), @speaker_gender)
    end

    def namespaces
      super.merge 'ws' => 'http://wsarchive.prototype0.net/ontology/'
    end

    def uri
      # http://www.w3.org/TR/media-frags/
      URI("#{@audio.base_uri}#t=#{start},#{start + duration}")
    end

    def type_uri
      'ws:Segment'
    end

    def rdf_mapping
      {
        'ws:start' => start,
        'ws:duration' => duration,
        'ws:gender' => gender,
        'ws:bandwidth' => bandwidth,
        'ws:speaker' => speaker,
      }
    end
  end
end
