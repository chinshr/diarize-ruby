require "rjb"

RJB_LOAD_PATH = [ENV.fetch('DIARIZE_RUBY_RJB_LOAD_PATH', File.join(File.expand_path('..', File.dirname(__FILE__)), 'bin', 'LIUM_SpkDiarization-4.2.jar'))].join(File::PATH_SEPARATOR)
RJB_OPTIONS   = ['-Xms16m', '-Xmx1024m']

Rjb::load(RJB_LOAD_PATH, RJB_OPTIONS)

require "uri"
require "open-uri"
require "digest"
require "to_rdf"
require "gsl"

require "rjb/java_object_wrapper"

require "diarize/version"
require "diarize/audio"
require "diarize/segment"
require "diarize/speaker"
require "diarize/segmentation"
require "diarize/super_vector"
require "diarize/server"
