require 'rspec'
require_relative '../src/runit'
require_relative '../fixture/fixture_runit'


describe 'Testear RUnit Rspec' do
  test_assertion_sin_logica = Class.new do

    def test_verdadero_es_verdadero
      true
    end

  end


  describe 'inner runit tests' do
    test_class = nil

    before(:all) {
      test_class = TestLogica.clone
      aRunner = RunitRunner.new
      aRunner.prepare_for_test test_class
      aRunner.prepare_for_test test_assertion_sin_logica
    }

    it 'should test get methods RUnitRunner' do
      runner = RunitRunner.new
      expected = [:test_verdadero_es_verdadero,:test_verdadero_es_falso, :test_suma]
      expect(
          runner.get_test_methods test_class).to eq(expected)

    end

    it 'should test mock TestLogica' do
      runner = RunitRunner.new
      expect(runner.run_test test_assertion_sin_logica,
                             :test_verdadero_es_verdadero).
          to eq(true)
    end

    it 'should test run Unit TestLogica' do
      runner = RunitRunner.new
      runner.run_test test_class,
             :test_verdadero_es_verdadero
    end

    it 'should test run Unit TestLogica Falso' do
      runner = RunitRunner.new
      expect{runner.run_test test_class,
                             :test_verdadero_es_falso}.
          to raise_error AssertionError
    end
  end

  it 'should tes run class  TestLogica' do
    runner = RunitRunner.new
    resultado = runner.run TestLogica
    expect(resultado.failed? TestLogica,
                             :test_verdadero_es_falso).
        to eq(true)
    expect(resultado.success? TestLogica,
                             :test_verdadero_es_verdadero).
        to eq(true)
  end

  it 'test con before deberia correr bien' do
    runner = RunitRunner.new
    resultado = runner.run TestConBefore

    resultado.report

    expect(resultado.success? TestConBefore, :test_bienvenida).to eq(true)
    expect(resultado.success? TestConBefore, :test_despedida).to eq(true)

  end

  it 'test que explota deberia reportar error' do
    runner = RunitRunner.new
    resultado = runner.run TestBoom

    expect(resultado.error? TestBoom, :test_explota).to eq(true)
  end

  it 'test con espera deberia reportar exito' do
    runner = RunitRunner.new
    resultado = runner.run TestPersona

    expect(resultado.success? TestPersona, :test_persona_nombre_completo).to eq(true)
  end

  it 'test con parametros deberia reportar exito' do
    runner = RunitRunner.new
    resultado = runner.run TestConParametros

    resultado.report

    expect(resultado.success? TestConParametros, :tests_suma).to eq(true)
  end

end