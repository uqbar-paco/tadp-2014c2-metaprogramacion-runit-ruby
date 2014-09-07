require_relative '../src/assertions'

class TestLogica
  include Assertions

  def test_verdadero_es_verdadero
    self.assert_equals true,true
  end

  def test_verdadero_es_falso
    self.assert_equals true,false
  end

  def test_suma
    self.assert_equals 3,3
  end

end