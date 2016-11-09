# diarize-ruby

This library provides an easy-to-use toolkit for speaker segmentation (diarization) and identification from audio.

This library was adopted from [diarize-jruby](https://github.com/bbc/diarize-jruby), being used within the BBC R&D World Service.

The main reason from deviating from the original library is to have a universal that works with either Ruby interpreter. It uses [Ruby Java Bridge](http://rjb.rubyforge.org) instead of [JRuby](http://jruby.org).

Work to be done:

* Universal gem that works on JRuby and various Ruby implementations (MRI) and versions
* Use performant math packages tuned to either Ruby implementation
* Add support for alternative diarization tools

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

Note: To make audio playback work with [Audio Playback](https://github.com/arirusso/audio-playback), you should install the following native libraries (homebrew):

    brew install libffi
    brew install portaudio

## Examples

    $ irb -I lib
    > require "diarize"
    > audio = Diarize::Audio.new URI.join('file:///', File.join(File.expand_path(File.dirname(__FILE__)), "test", "data", "will-and-juergen.wav"))
    > audio.analyze!
    > audio.segments
    > audio.speakers
    > audio.to_rdf
    > speakers = audio.speakers
    > speakers.first.gender
    > speakers.first.model.mean_log_likelihood
    > speakers.first.model.components.size
    > audio.segments_by_speaker(speakers.first)[0].play
    > audio.segments_by_speaker(speakers.first)[1].play
    > ...
    > speakers ||= other_speakers
    > Diarize::Speaker.match(speakers)


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

## Developer Resources

* [Connecting Ruby to Java and vice versa](http://nofail.de/2010/04/ruby-in-java-java-in-ruby-jruby-or-ruby-java-bridge/)
* [LIUM scripts](https://github.com/StevenLOL/LIUM/blob/master/ilp_diarization2.sh)
* [Speaker Identification for the whole World Service Archive](http://www.bbc.co.uk/rd/blog/2014-01-speaker-identification-for-the-whole-world-service-archive)
