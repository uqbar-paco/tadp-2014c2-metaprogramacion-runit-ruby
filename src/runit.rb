class RunitRunner


  def run(*test_classes)
    resultado = Resultado.new
    test_classes.each do |test_class|
      self.run_tests_for test_class, resultado
    end
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
  attr_accessor :resultados

  def initialize
    self.resultados = []
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

end
