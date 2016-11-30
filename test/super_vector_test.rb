require 'test_helper'

class SuperVectorTest < Test::Unit::TestCase

  def test_generate_from_model
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal 512 * 24, sv.dim
    # Checking all elements are OK
    model.nb_of_components.times do |i|
      gaussian = model.components.get(i)
      gaussian.dim.times do |j|
        assert_equal gaussian.mean(j), sv.vector[i * gaussian.dim + j]
      end
    end
  end

  def test_initialize_from_supervector
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv1 = Diarize::SuperVector.generate_from_model(model)
    sv2 = Diarize::SuperVector.new(sv1)
    assert_equal sv1.hash, sv2.hash
  end

  def test_initialize_from_array
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv1 = Diarize::SuperVector.generate_from_model(model)
    sv2 = Diarize::SuperVector.new(sv1.to_a)
    assert_equal sv1.hash, sv2.hash
  end

  def test_hash
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal sv.vector.hash, sv.hash
  end

  def test_to_a
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal sv.instance_variable_get("@vector").to_a, sv.to_a
  end

end
