require '../src/assertions'
module Esperador
  def espera(nombre_test, objeto, bloque)
    self.send :define_method, "test_#{nombre_test}".to_sym do
      assert_true objeto.instance_eval &bloque
    end
  end
end

class RunitRunner

  def run(*test_classes)
    resultado = Resultado.new
    resultado.empezar_ejecucion
    test_classes.each do |test_class|
      self.run_tests_for test_class, resultado
    end
    resultado.termino_ejecucion
    resultado
  end

  def run_tests_for(test_class, resultado)
    prepare_for_test(test_class)
    methods = self.get_test_methods test_class
    methods.each do |method|
      begin
        self.run_test test_class, method
        resultado.test_success test_class, method
      rescue AssertionError => exception
        resultado.test_failed test_class, method, exception
      rescue StandardError => exception
        resultado.test_error test_class, method, exception
      end
    end
  end

  def prepare_for_test(test_class)
    test_class.class_eval do
      include Assertions
    end

    unless test_class.instance_methods.include? :before_each
      test_class.class_eval do
        define_method :before_each do
        end
      end
    end
  end

  def get_test_methods(test_class)
    test_class.instance_methods.
        select { |m| is_test(m) | is_tests(m) }
  end

  def is_tests(m)
    m.to_s.start_with?('tests_')
  end

  def is_test(m)
    m.to_s.start_with?('test_')
  end

  def run_test(test_class, method)
    if (is_test(method))
      instance = get_instance(test_class)
      instance.send method
    else
      parametros = test_class.parametros
      parametros.each { |unos_parametros|
        instance = get_instance(test_class)

        instance.define_singleton_method :method_missing do
          |symbol, *args, &block|
          if (unos_parametros.has_key? symbol)
            unos_parametros[symbol]
          else
            super
          end
        end

        instance.send method
      }
    end
  end

  def get_instance(test_class)
    instance = test_class.new
    instance.before_each
    instance
  end

end

class Resultado
  attr_accessor :resultados, :comienzo_corrida, :fin_corrida

  def initialize
    self.resultados = []
  end

  def empezar_ejecucion
    self.comienzo_corrida = Time.now
  end

  def termino_ejecucion
    self.fin_corrida = Time.now
  end

  def test_failed(test_class, method, exception)
    self.resultados << FailedTestResult.new(test_class, method, exception)
  end

  def test_error(test_class, method, exception)
    self.resultados << ErrorTestResult.new(test_class, method, exception)
  end

  def test_success(test_class, method)
    self.resultados << SuccessTestResult.new(test_class, method)
  end

  def failed?(a_class, test)
    self.resultados.any? { |resultado| resultado.failed? a_class, test }
  end

  def success?(a_class, test)
    self.resultados.any? { |resultado| resultado.success? a_class, test }
  end

  def error?(a_class, test)
    self.resultados.any? { |resultado| resultado.error? a_class, test }
  end

  def get_total_results
    self.resultados.length
  end

  def get_failed_results
    self.resultados.select { |resultado| resultado.is_a?(FailedTestResult) }
  end

  def get_successful_results
    self.resultados.select { |resultado| resultado.is_a?(SuccessTestResult) }
  end

  def report_resultados
    self.resultados.each do |resultado|
      resultado.report
    end
  end

  def report
    self.report_resultados
    puts "#{self.get_total_results} tests,#{self.get_successful_results.length} tests corrieron bien, fallaron  #{self.get_failed_results.length} tests"
    puts "Los tests corrieron en #{(self.fin_corrida - self.comienzo_corrida)*1000} milliseconds"
  end

end

class TestResult
  attr_accessor :test_class, :method

  #Compara si la instancia del receptor impicito y self refieren al mismo objeto, implementa la misma funcionalidad que ==
  def eql?(other)
    self.test_class == other.test_class &&
        self.method == other.method
  end

  def success?(a_class, test)
    false
  end

  def failed?(a_class, test)
    false
  end

  def error?(a_class, test)
    false
  end
end

class SuccessTestResult < TestResult
  def initialize(test_class, method)
    self.method = method
    self.test_class = test_class
  end

  def success?(a_class, test)
    self.eql? SuccessTestResult.new a_class, test
  end

  def report

  end
end

class FailedTestResult < TestResult
  attr_accessor :exception

  def initialize(test_class, method, exception)
    self.test_class = test_class
    self.method = method
    self.exception = exception
  end

  def failed?(a_class, test)
    self.eql? FailedTestResult.new a_class, test, nil
  end

  def report
    puts "Error en test #{self.method}: #{self.exception.message}"
    puts self.exception.backtrace.join("\n")
    puts "\n"
  end

end

class ErrorTestResult < FailedTestResult
  def failed?(a_class, test)
    false
  end

  def error?(a_class, test)
    self.eql? ErrorTestResult.new a_class, test, nil
  end

end
