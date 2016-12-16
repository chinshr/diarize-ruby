module Diarize
  class Server

    def build_audio(url_or_uri)
      Audio.new(url_or_uri)
    end

    def build_speaker(uri = nil, gender = nil, model_file = nil)
      Speaker.new(uri, gender, model_file)
    end

  end
end
