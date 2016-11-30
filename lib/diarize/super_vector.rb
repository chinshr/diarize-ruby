module Diarize
  class SuperVector
    attr_reader :vector

    def initialize(vector)
      @vector = vector.is_a?(Array) ? Vector.elements(vector) : vector
    end

    class << self

      def generate_from_model(model)
        # Generates a supervector from a LIUM GMM
        dim = model.nb_of_components * model.components.get(0).dim
        vector = Array.new(dim, 0)
        model.nb_of_components.times do |k|
          gaussian = model.components.get(k)
          gaussian.dim.times do |i|
            vector[k * gaussian.dim + i] = gaussian.mean(i)
          end
        end
        SuperVector.new(Vector.elements(vector))
      end

      def ubm_gaussian_weights
        # Returns a vector of gaussian weights, same dimension as speaker's super vectors
        @@ubm_gaussian_weights ||= begin
          ubm = Speaker.ubm
          # weights = DoubleMatrix.new(1, ubm.supervector.dim)
          weights = Array.new(ubm.supervector.dim, 0)
          ubm.model.nb_of_components.times do |k|
            gaussian = ubm.model.components.get(k)
            gaussian.dim.times do |i|
              weights[k * gaussian.dim + i] = gaussian.weight
            end
          end
          Vector.elements(weights)
        end
      end

      def ubm_covariance
        # Returns a vector of diagonal covariances, same dimension as speaker's super vectors
        @@ubm_covariance ||= begin
          ubm = Speaker.ubm
          # cov = DoubleMatrix.new(1, ubm.supervector.dim)
          cov = Array.new(ubm.supervector.dim)
          ubm.model.nb_of_components.times do |k|
            gaussian = ubm.model.components.get(k)
            gaussian.dim.times do |i|
              cov[k * gaussian.dim + i] = gaussian.getCovariance(i, i)
            end
          end
          Vector.elements(cov)
        end
      end

      def divergence(sv1, sv2)
        # ubm_gaussian_weights.mul(((sv1.vector - sv2.vector) ** 2) / ubm_covariance).sum
        diff   = sv1.vector - sv2.vector
        square = diff.map {|el| el ** 2}
        codiv  = Vector.elements(square.each.with_index.inject([]) {|a,(el,ix)| a << el / ubm_covariance[ix]})
        mult   = ubm_gaussian_weights.each.with_index.inject([]) {|a,(el,ix)| a << el * codiv[ix]}
        mult.inject(0, :+)
      end

    end # class

    def dim
      @vector.size
    end

    def hash
      @vector.hash
    end

    def to_a
      @vector.to_a
    end

  end # SuperVector
end
