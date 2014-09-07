require 'rspec'
require_relative '../src/xunit'
require_relative '../fixture/fixture_xunit'

class TestSinAssertionLogica

  def test_verdadero_es_verdadero
    true
  end

end

describe 'Testear RUnit Rspec' do

  it 'should test get methods RUnitRunner' do
    runner = RunitRunner.new
    expected = [:test_verdadero_es_verdadero,:test_verdadero_es_falso, :test_suma]
    expect(
        runner.get_test_methods TestLogica).to eq(expected)

  end

  it 'should test mock TestLogica' do
    runner = RunitRunner.new
    expect(runner.run_test TestSinAssertionLogica,
                           :test_verdadero_es_verdadero).
        to eq(true)
  end

  it 'should test run Unit TestLogica' do
    runner = RunitRunner.new
    runner.run_test TestLogica,
           :test_verdadero_es_verdadero
  end

  it 'should test run Unit TestLogica Falso' do
    runner = RunitRunner.new
    expect{runner.run_test TestLogica,
                           :test_verdadero_es_falso}.
        to raise_error AssertionError
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

end