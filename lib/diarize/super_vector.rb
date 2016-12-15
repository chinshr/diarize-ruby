module Diarize
  class SuperVector
    attr_reader :vector

    def initialize(vector)
      @vector = vector
    end

    class << self

      def generate_from_model(model)
        # Generates a supervector from a LIUM GMM
        dim = model.nb_of_components * model.components.get(0).dim
        vector = GSL::Vector::alloc(dim)
        model.nb_of_components.times do |k|
          gaussian = model.components.get(k)
          gaussian.dim.times do |i|
            vector[k * gaussian.dim + i] = gaussian.mean(i)
          end
        end
        SuperVector.new(vector)
      end

      def ubm_gaussian_weights
        # Returns a vector of gaussian weights, same dimension as speaker's super vectors
        @@ubm_gaussian_weights ||= begin
          ubm = Speaker.ubm
          weights = GSL::Vector::alloc(ubm.supervector.dim)
          ubm.model.nb_of_components.times do |k|
            gaussian = ubm.model.components.get(k)
            gaussian.dim.times do |i|
              weights[k * gaussian.dim + i] = gaussian.weight
            end
          end
          weights
        end
      end

      def ubm_covariance
        # Returns a vector of diagonal covariances, same dimension as speaker's super vectors
        @@ubm_covariance ||= begin
          ubm = Speaker.ubm
          cov = GSL::Vector::alloc(ubm.supervector.dim)
          ubm.model.nb_of_components.times do |k|
            gaussian = ubm.model.components.get(k)
            gaussian.dim.times do |i|
              cov[k * gaussian.dim + i] = gaussian.getCovariance(i, i)
            end
          end
          cov
        end
      end

      def divergence(sv1, sv2)
        return ubm_gaussian_weights.mul(((sv1.vector - sv2.vector) ** 2) / ubm_covariance).sum
      end

    end # class

    def dim
      @vector.size
    end

    def hash
      @vector.to_a.hash
    end

    def to_a
      @vector.to_a
    end

  end # SuperVector
end # Diarize
