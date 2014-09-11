require 'colorize'

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
    methods = self.get_test_methods test_class
    methods.each do |method|
      begin
        self.run_test test_class, method
        resultado.test_success test_class, method
      rescue AssertionError => exception
        resultado.test_failed test_class, method, exception
      end
    end
  end

  def get_test_methods(test_class)
    test_class.instance_methods.
        select { |m| m.to_s.start_with? 'test_' }
  end

  def run_test(test_class, method)
    test_class.new.send method
  end

end

class Resultado
  attr_accessor :resultados,:comienzo_corrida,:fin_corrida

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

  def test_success(test_class, method)
    self.resultados << SuccessTestResult.new(test_class, method)
  end

  def failed?(a_class, test)
    self.resultados.any? {|resultado| resultado.failed? a_class,test}
  end

  def success?(a_class, test)
    self.resultados.any? {|resultado| resultado.success? a_class,test}
  end

  def get_total_results
    self.resultados.length
  end

  def get_failed_results
    self.resultados.select{|resultado| resultado.is_a?(FailedTestResult)}
  end

  def get_successful_results
    self.resultados.select{|resultado| resultado.is_a?(SuccessTestResult)}
  end

  def report_resultados
    self.resultados.each do |resultado|
      resultado.report
    end
  end

  def report
    self.report_resultados
    puts "#{self.get_total_results} tests,#{self.get_successful_results.length} tests corrieron bien, fallaron  #{self.get_failed_results.length} tests".
             colorize(:color => :blue, :background => :black)
    puts "Los tests corrieron en #{(self.fin_corrida - self.comienzo_corrida)*1000} milliseconds".colorize(:color => :cyan, :background => :black)
  end

end

class TestResult
  attr_accessor :test_class, :method

  #Compara si la instancia del receptor impicito y self refieren al mismo objeto, implementa la misma funcionalidad que ==
  def eql?(other)
    self.test_class == other.test_class &&
        self.method == other.method
  end

  def success?(a_class,test)
    false
  end

  def failed?(a_class,test)
    false
  end
end

class SuccessTestResult < TestResult
  def initialize(test_class, method)
    self.method = method
    self.test_class = test_class
  end

  def success?(a_class,test)
    self.eql? SuccessTestResult.new a_class,test
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
    self.eql? FailedTestResult.new a_class,test,nil
  end

  def report
    puts "Error en test #{self.method}: #{self.exception.message}".colorize(:color => :red, :background => :black)
    puts self.exception.backtrace.join("\n").colorize(:color => :red, :background => :black)
    puts "\n"
  end

end
