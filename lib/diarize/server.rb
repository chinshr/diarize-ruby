module Diarize
  class Server

    def new_audio(url_or_uri)
      Audio.new(url_or_uri)
    end

  end
end
