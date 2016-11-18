## [v0.3.7] - 2016-11-18

- Sort segments by start time by default
- Allow to pass audio file names to `Diarize::Audio.new("~/foo.wav")`
- Download https URLs without certs checking
- Fix `diarize` druby uri for remote audio

## [v0.3.6] - 2016-11-16

- Add pidfile option to diarize server command (--pidfile, -P)
- Change diarize option port (--port, -p)

## [v0.3.5] - 2016-11-16

- Refactor server interface to build_audio

## [v0.3.4] - 2016-11-16

- Add diarize binary
- DRb server

## [v0.3.3] - 2016-11-14

- Remove require for audio-playback

## [v0.3.2] - 2016-11-14

- Remove audio player and playback option

## [v0.3.1] - 2016-11-08

- Fixed README and examples
- First round to fix audio playback
- Move LIUM jar into bin folder
- Use `DIARIZE_RUBY_RJB_LOAD_PATH` env variable for alternative loading

## [v0.3.0] - 2016-11-08

- Pushed first version of v0.3.0 to rubygems.org
