module Diarize
  class Speaker
    include ToRdf

    @@log_likelihood_threshold = -33
    @@detection_threshold      = 0.2
    @@speakers                 = {}

    attr_accessor :model_uri, :model
    attr_reader :gender
    attr_writer :normalized

    def initialize(uri = nil, gender = nil, model_file = nil)
      @model      = Speaker.load_model(model_file) if model_file
      @uri        = uri
      @gender     = gender
      @normalized = false
    end

    class << self

      def ubm
        speaker = Speaker.new
        speaker.normalized = true
        speaker.model = Speaker.load_model(File.join(File.expand_path(File.dirname(__FILE__)), 'ubm.gmm'))
        speaker
      end

      def detection_threshold=(threshold)
        @@detection_threshold = threshold
      end

      def detection_threshold
        @@detection_threshold
      end

      def load_model(filename)
        read_gmm(filename)
      end

      def find_or_create(uri, gender)
        return @@speakers[uri] if @@speakers[uri]
        @@speakers[uri] = Speaker.new(uri, gender)
      end

      def divergence(speaker1, speaker2)
        # TODO bundle in mean_log_likelihood to weight down unlikely models?
        return unless speaker1.model and speaker2.model
        # MAP Gaussian divergence
        # See "A model space framework for efficient speaker detection", Interspeech'05
        divergence_lium(speaker1, speaker2)
      end

      def divergence_lium(speaker1, speaker2)
        Rjb::import('fr.lium.spkDiarization.libModel.Distance').GDMAP(speaker1.model, speaker2.model)
      end

      def divergence_ruby(speaker1, speaker2)
        SuperVector.divergence(speaker1.supervector, speaker2.supervector)
      end

      def match_sets(speakers1, speakers2)
        matches = []
        speakers1.each do |s1|
          speakers2.each do |s2|
            matches << [ s1, s2 ] if s1.same_speaker_as(s2)
          end
        end
        matches
      end

      def match(speakers)
        speakers.combination(2).select { |s1, s2| s1.same_speaker_as(s2) }
      end

      protected

      def read_gmm(filename)
        gmmlist = Rjb::JavaObjectWrapper.new("java.util.ArrayList")
        input = Rjb::import('fr.lium.spkDiarization.lib.IOFile').new(filename, 'rb')
        input.open
        Rjb::import('fr.lium.spkDiarization.libModel.ModelIO').readerGMMContainer(input, gmmlist.java_object)
        input.close
        gmmlist.to_a.first.java_object
      end

    end # class

    def mean_log_likelihood
      @mean_log_likelihood ? @mean_log_likelihood : model.mean_log_likelihood # Will be NaN if model was loaded from somewhere
    end

    def mean_log_likelihood=(mll)
      @mean_log_likelihood = mll
    end

    def save_model(filename, force = false)
      raise RuntimeError, "normalized model must be saved with force=true" if !force && normalized?
      write_gmm(filename, @model)
    end

    def normalized?
      !!@normalized
    end

    def normalize!
      unless normalized?
        # Applies M-Norm from "D-MAP: a Distance-Normalized MAP Estimation of Speaker Models for Automatic Speaker Verification"
        # to the associated GMM, placing it on a unit hyper-sphere with a UBM centre (model will be at distance one from the UBM
        # according to GDMAP)
        # Using supervectors: vector = (1.0 / distance_to_ubm) * vector + (1.0 - 1.0 / distance_to_ubm) * ubm_vector
        speaker_ubm = Speaker.ubm
        distance_to_ubm = Math.sqrt(Speaker.divergence(self, speaker_ubm))
        model.nb_of_components.times do |k|
          gaussian = model.components.get(k)
          gaussian.dim.times do |i|
            normalized_mean = (1.0 / distance_to_ubm) * gaussian.mean(i) + (1.0 - 1.0 / distance_to_ubm)  * speaker_ubm.model.components.get(k).mean(i)
            gaussian.set_mean(i, normalized_mean)
          end
        end
        @normalized = true
      end
      @normalized
    end

    def same_speaker_as(other)
      # Detection score defined in Ben2005
      return unless [ self.mean_log_likelihood, other.mean_log_likelihood ].min > @@log_likelihood_threshold
      self.normalize!
      other.normalize!
      detection_score = 1.0 - Speaker.divergence(other, self)
      detection_score > @@detection_threshold
    end

    def supervector
      if normalized?
        @supervector ||= begin
          SuperVector.generate_from_model(model)
        end
      else
        SuperVector.generate_from_model(model)
      end
    end

    def namespaces
      super.merge 'ws' => 'http://wsarchive.prototype0.net/ontology/'
    end

    def uri
      @uri
    end

    def type_uri
      'ws:Speaker'
    end

    def rdf_mapping
      {
        'ws:gender' => gender,
        'ws:model' => model_uri,
        'ws:mean_log_likelihood' => mean_log_likelihood,
        'ws:supervector_hash' => supervector.hash.to_s
      }
    end

    def as_json
      {
        'gender' => gender,
        'model' => model_uri,
        'mean_log_likelihood' => mean_log_likelihood,
        'supervector_hash' => supervector.hash.to_s
      }
    end
    alias_method :_as_json, :as_json

    def to_json
      as_json.to_json
    end
    alias_method :_to_json, :to_json

    protected

    def write_gmm(filename, model)
      gmmlist = Rjb::JavaObjectWrapper.new("java.util.ArrayList")
      gmmlist.java_object.add(model)
      output = Rjb::import('fr.lium.spkDiarization.lib.IOFile').new(filename, 'wb')
      output.open
      Rjb::import('fr.lium.spkDiarization.libModel.ModelIO').writerGMMContainer(output, gmmlist.java_object)
      output.close
    end

  end # Speaker
end
