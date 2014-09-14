require_relative '../src/assertions'

class TestLogica

  def test_verdadero_es_verdadero
    self.assert_equals true, true
  end

  def test_verdadero_es_falso
    self.assert_equals true, false
  end

  def test_suma
    self.assert_equals 3, 3
  end

end

class TestConBefore

  def before_each
    @quien = "Ernesto"
  end

  def test_bienvenida
    assert_equals "hola Ernesto", "hola #{@quien}"
    @quien = "Demian"
    assert_equals "hola Demian", "hola #{@quien}"
  end

  def test_despedida
    assert_equals "chau Ernesto", "chau #{@quien}"
  end

end

class TestBoom
  def test_explota
    1/0
  end
end

class Persona
  attr_accessor :nombre, :apellido

  def initialize
    self.nombre = "Demian"
    self.apellido = "Alonso"
  end

  def nombre_completo
    "#{nombre} #{apellido}"
  end
end

class TestPersona
  extend Esperador

  espera :persona_nombre_completo, Persona.new, proc {
    nombre_completo == nombre +
        " " + apellido
  }
end

# class TestPersonaPosta
#   extend Esperador
#   contexto :persona_nombre_completo do
#     para Persona.new1, Persona.new2, Persona.new3
#     cumplen { nombre_completo == nombre + " " + apellido}
#   end
# end


class TestConParametros
  def self.parametros
    [{x:1, y:2, z:3}, {x:3, y:4, z:7}]
  end

  def tests_suma
    assert_equals(z, x + y)
  end
end

