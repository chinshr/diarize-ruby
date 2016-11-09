module Diarize

  class AudioPlayer

    def play(file, options = {})
      output = AudioPlayback::Device::Output.by_id(1) rescue nil
      defaults = {
        :channels      => [0, 1],
        :latency       => 1,
        :output_device => output,
        :buffer_size   => 4048
      }
      options, stream = defaults.merge(options), nil
      playback = AudioPlayback.play(file.path, options)
      stream ||= playback.stream
      stream.start
      stream.block
    end

  end

end
