require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'resin/cli'

describe Resin::CLI, "execute" do
  def run(input)
    stdout_io = StringIO.new
    stdin_io = StringIO.new(input)
    stderr_io = StringIO.new
    logger = Logger.new(stderr_io)
    Resin::CLI.execute(stdout_io, stdin_io, logger)
    stdout_io.rewind
    stdout_io.read
  end

  def batch_test(input_tests, formatted_expected_output, should_be_true=true)
    input_tests.each { |input|
      expected_output = formatted_expected_output.gsub('#value#') { |v| Regexp.escape(input) }
      stdout = run(input)
      if should_be_true
        stdout.should =~ Regexp.new("^#{expected_output}$")
      else
        stdout.should_not =~ Regexp.new("^#{expected_output}$")
      end 
    }
  end

  it "should ignore empty inputs" do
    input_tests = ['']
    batch_test(input_tests, "")
  end

  it "should ignore whitespace" do
    input_tests = [" ", "\t", "\n"]
    batch_test(input_tests, "")
  end

  it "should not accept phrases without FIM_DE_FRASE" do
    input_tests = ["SUJEITO", "SUBSTANTIVO", "SINTAGMA_VERBAL", "ARTIGO", "PRONOME", "CONECTIVO", "VERBO",
                   "SINTAGMA_ADJETIVO", "SINTAGMA_ADJETIVO_SIMPLES", "SINTAGMA_SUBSTANTIVO", "SINTAGMA_SUBSTANTIVO_SIMPLES",
                   "SUBSTANTIVO CONECTIVO SUBSTANTIVO", "SUBSTANTIVO CONECTIVO SUBSTANTIVO CONECTIVO SUBSTANTIVO",
                   "ARTIGO SUBSTANTIVO", "ARTIGO SUBSTANTIVO CONECTIVO ARTIGO SUBSTANTIVO",
                   "PRONOME CONECTIVO PRONOME", "PRONOME SUBSTANTIVO", "PRONOME SUBSTANTIVO CONECTIVO PRONOME SUBSTANTIVO",
                   "SUJEITO|SUBSTANTIVO|SINTAGMA_VERBAL|ARTIGO|PRONOME|CONECTIVO|VERBO|ADJETIVO",
                   "ARTIGO|PRONOME|SUBSTANTIVO ARTIGO|PRONOME|SUBSTANTIVO"]
    batch_test(input_tests, "ERRO")
  end

  it "should not accept FIM_DE_FRASE" do
    input_tests = ["FIM_DE_FRASE"]
    batch_test(input_tests, "ERRO")
  end

  it "should not accept anything that ends with FRASE" do
    input_tests = ["QUALQUER COISA TERMINANDO COM FRASE"]
    batch_test(input_tests, "ERRO")
  end

  it "should accept SUJEITO FIM_DE_FRASE" do
    input_tests = ["SUJEITO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SINTAGMA_VERBAL FIM_DE_FRASE" do
    input_tests = ["SINTAGMA_VERBAL FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SUJEITO SINTAGMA_VERBAL FIM_DE_FRASE" do
    input_tests = ["SUJEITO SINTAGMA_VERBAL FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept VERBO FIM_DE_FRASE" do
    input_tests = ["VERBO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SUJEITO VERBO FIM_DE_FRASE" do
    input_tests = ["SUJEITO VERBO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SUBSTANTIVO (CONECTIVO SUBSTANTIVO)* FIM_DE_FRASE" do
    input_tests = ["SUBSTANTIVO FIM_DE_FRASE", "SUBSTANTIVO CONECTIVO SUBSTANTIVO FIM_DE_FRASE",
                   "SUBSTANTIVO CONECTIVO SUBSTANTIVO CONECTIVO SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept ARTIGO SUBSTANTIVO (CONECTIVO ARTIGO SUBSTANTIVO)* FIM_DE_FRASE" do
    input_tests = ["ARTIGO SUBSTANTIVO FIM_DE_FRASE", "ARTIGO SUBSTANTIVO CONECTIVO ARTIGO SUBSTANTIVO FIM_DE_FRASE",
                   "ARTIGO SUBSTANTIVO CONECTIVO ARTIGO SUBSTANTIVO CONECTIVO ARTIGO SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept PRONOME (CONECTIVO PRONOME)* FIM_DE_FRASE" do
    input_tests = ["PRONOME FIM_DE_FRASE", "PRONOME CONECTIVO PRONOME FIM_DE_FRASE",
                   "PRONOME CONECTIVO PRONOME CONECTIVO PRONOME FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept PRONOME SUBSTANTIVO (CONECTIVO PRONOME SUBSTANTIVO)* FIM_DE_FRASE" do
    input_tests = ["PRONOME SUBSTANTIVO FIM_DE_FRASE", "PRONOME SUBSTANTIVO CONECTIVO PRONOME SUBSTANTIVO FIM_DE_FRASE",
                   "PRONOME SUBSTANTIVO CONECTIVO PRONOME SUBSTANTIVO CONECTIVO PRONOME SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SUJEITO ADJETIVO FIM_DE_FRASE" do
    input_tests = ["SUJEITO ADJETIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept ADJETIVO SUJEITO FIM_DE_FRASE" do
    input_tests = ["ADJETIVO SUJEITO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SINTAGMA_ADJETIVO SUJEITO FIM_DE_FRASE" do
    input_tests = ["SINTAGMA_ADJETIVO SUJEITO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SINTAGMA_ADJETIVO_SIMPLES (CONECTIVO SINTAGMA_ADJETIVO_SIMPLES)* SUJEITO FIM_DE_FRASE" do
    input_tests = ["SINTAGMA_ADJETIVO_SIMPLES SUJEITO FIM_DE_FRASE",
                   "SINTAGMA_ADJETIVO_SIMPLES CONECTIVO SINTAGMA_ADJETIVO_SIMPLES SUJEITO FIM_DE_FRASE",
                   "SINTAGMA_ADJETIVO_SIMPLES CONECTIVO SINTAGMA_ADJETIVO_SIMPLES CONECTIVO SINTAGMA_ADJETIVO_SIMPLES SUJEITO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept SUJEITO|SINTAGMA_VERBAL FIM_DE_FRASE" do
    input_tests = ["SUJEITO|SINTAGMA_VERBAL FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept ARTIGO|SUBSTANTIVO ARTIGO|SUBSTANTIVO (CONECTIVO ARTIGO|SUBSTANTIVO ARTIGO|SUBSTANTIVO)* FIM_DE_FRASE" do
    input_tests = ["ARTIGO|SUBSTANTIVO ARTIGO|SUBSTANTIVO FIM_DE_FRASE",
                   "ARTIGO|SUBSTANTIVO ARTIGO|SUBSTANTIVO CONECTIVO ARTIGO|SUBSTANTIVO ARTIGO|SUBSTANTIVO FIM_DE_FRASE",
                   "ARTIGO|SUBSTANTIVO CONECTIVO ARTIGO|SUBSTANTIVO CONECTIVO ARTIGO|SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
 end

  it "should accept ARTIGO|PRONOME|SUBSTANTIVO+ (CONECTIVO ARTIGO|PRONOME|SUBSTANTIVO)* FIM_DE_FRASE" do
    input_tests = ["ARTIGO|PRONOME|SUBSTANTIVO FIM_DE_FRASE", "ARTIGO|PRONOME|SUBSTANTIVO CONECTIVO ARTIGO|PRONOME|SUBSTANTIVO FIM_DE_FRASE",
                   "ARTIGO|PRONOME|SUBSTANTIVO CONECTIVO ARTIGO|PRONOME|SUBSTANTIVO CONECTIVO ARTIGO|PRONOME|SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end
end
