module Diarize
  class Segment
    include ToRdf

    attr_reader :start, :duration, :speaker_gender, :bandwidth, :speaker_id

    def initialize(audio, start, duration, speaker_gender, bandwidth, speaker_id)
      @audio          = audio
      @start          = start
      @duration       = duration
      @bandwidth      = bandwidth
      @speaker_id     = speaker_id
      @speaker_gender = speaker_gender
    end

    def speaker
      Speaker.find_or_create(URI("#{@audio.base_uri}##{@speaker_id}"), @speaker_gender)
    end

    def namespaces
      super.merge({'ws' => 'http://wsarchive.prototype0.net/ontology/'})
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
        'ws:gender' => speaker_gender,
        'ws:bandwidth' => bandwidth,
        'ws:speaker' => speaker,
      }
    end

    def as_json
      {
        'start' => start,
        'duration' => duration,
        'gender' => speaker_gender,
        'bandwidth' => bandwidth,
        'speaker_id' => speaker_id
      }.tap {|s|
        s['speaker'] = speaker.as_json if speaker
      }
    end
    alias_method :_as_json, :as_json

    def to_json
      as_json.to_json
    end
    alias_method :_to_json, :to_json
  end
end
