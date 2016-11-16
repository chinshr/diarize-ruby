# diarize-ruby

This library provides an easy-to-use toolkit for speaker segmentation (diarization) and identification from audio. It was adopted from [diarize-jruby](https://github.com/bbc/diarize-jruby), being used within the BBC R&D World Service.

The main reason from deviating from the original is to provide support for Ruby MRI. It uses [Ruby Java Bridge](http://rjb.rubyforge.org) instead of [JRuby](http://jruby.org).

## Speaker Diarization

This library gives acccess to the algorithm developed by the LIUM
for the ESTER 2 evaluation campaign and described in [Meigner2010].

It wraps a binary JAR file compiled from [LIUM](http://lium3.univ-lemans.fr/diarization/doku.php/welcome).

## Speaker Identification

This library also implements an algorithm for speaker identification
based on the comparison of normalised speaker models, which can be
accessed through the Speaker#match method.

This algorithm builds on top of the LIUM toolkit and uses the following
techniques:

 * "M-Norm" normalisation of speaker models [Ben2003]
 * The symmetric Kullback-Leibler divergence approximation described in [Do2003]
 * The detection score specified in [Ben2005]

It also includes support for speaker supervectors [Campbell2006], which
can be used in combination with our ruby-lsh library for fast speaker
identification.

## Install

    $ bundle install

If you are using a different version of LIUM than what is bundled in the `bin` folder, you can do so by setting an environment variable.

    $ export DIARIZE_RUBY_RJB_LOAD_PATH=<path-to-LIUM-jar-file>

## Examples

### Get Segments and Speakers

From Ruby:

    $ diarize console

```ruby
audio = Diarize::Audio.new(URI.join('file:///', File.join(File.expand_path(File.dirname(__FILE__)), "test", "data", "will-and-juergen.wav")))

audio.analyze!
audio.segments
audio.speakers
audio.to_rdf
speakers = audio.speakers
speakers.first.gender
speakers.first.model.mean_log_likelihood
speakers.first.model.components.size
...
speakers ||= other_speakers
Diarize::Speaker.match(speakers)
```

From bash:

    $ diarize audio speaker example.wav

### Start Server

Some Java implementations (i.e. OpenJDK on Linux) are causing trouble running [Rjb](http://rjb.rubyforge.org) on threaded environments (e.g. [Celluloid](https://github.com/celluloid/celluloid), [Sidekick](https://github.com/mperham/sidekiq), [Shoryuken](https://github.com/phstc/shoryuken)) leading to instability. One workaround is to start diarize as server [DRb](http://ruby-doc.org/stdlib-2.0.0/libdoc/drb/rdoc/DRb.html) by a client proxy.

Start the diarizer in a separate process as a server:

    $ diarize server -P 9999 -H localhost
    Drb server
    diarize-ruby 0.3.4
    Listening on druby://localhost:9999, CTRL+C to stop

### Client

From bash:

    $ diarize remote audio segment example.wav

From Ruby:

```ruby
require "diarize"
require "drb/drb"

server_uri = "druby://localhost:9999"
DRb.start_service
client = DRbObject.new_with_uri(server_uri)

audio_uri = URI.join('file:///', File.join(File.expand_path(File.dirname(__FILE__)), "test", "data", "will-and-juergen.wav"))
audio = client.new_audio(audio_uri)
audio.analyze!
audio.segments
...
```

## Running tests

    $ rake

## References

[Meigner2010] S. Meignier and T. Merlin, "LIUM SpkDiarization:
An Open Source Toolkit For Diarization" in Proc. CMU SPUD Workshop,
March 2010, Dallas (Texas, USA)

[Ben2003] M. Ben and F. Bimbot, "D-MAP: A Distance-Normalized Map
Estimation of SPeaker Models for Automatic Speaker Verification",
Proceedings of ICASSP, 2003

[Do2003] M. N. Do, "Fast Approximation of Kullback-Leibler Distance
for Dependence Trees and Hidden Markov Models",
IEEE Signal Processing Letters, April 2003

[Ben2005] M. Ben and G. Gravier and F. Bimbot. "A model space
framework for efficient speaker detection",
Proceedings of INTERSPEECH, 2005

[Campbell2006] W. M. Campbell, D. E. Sturim and D. A. Reynolds,
"Support vector machines using GMM supervectors for speaker verification",
IEEE Signal Processing Letters, 2006, 13, 308-311

## License

See 'LICENSE' and 'AUTHORS' files.

All code here, except where otherwise indicated, is licensed under
the GNU Affero General Public License version 3. This license includes
many restrictions. If this causes a problem, please contact us.
See "AUTHORS" for contact details.

This library includes a binary JAR file from the LIUM project, which code
is licensed under the GNU General Public License version 2. See
http://lium3.univ-lemans.fr/diarization/doku.php/licence for more
information.

## TODOs

* Universal gem that works on JRuby and various Ruby implementations (MRI) and versions
* Use performant math packages tuned to either Ruby implementation
* Add support for alternative diarization tools
* Add CI tool

## Developer Resources

* [Connecting Ruby to Java and vice versa](http://nofail.de/2010/04/ruby-in-java-java-in-ruby-jruby-or-ruby-java-bridge/)
* [LIUM scripts](https://github.com/StevenLOL/LIUM/blob/master/ilp_diarization2.sh)
* [Speaker Identification for the whole World Service Archive](http://www.bbc.co.uk/rd/blog/2014-01-speaker-identification-for-the-whole-world-service-archive)
