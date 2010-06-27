require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'resin/cli'

describe Resin::CLI, "execute" do
  def run(input)
    stdout_io = StringIO.new
    stdin_io = StringIO.new(input)
    Resin::CLI.execute(stdout_io, stdin_io, [])
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

  it "should not accept phrases in the form SUJEITO" do
    input_tests = ["SUJEITO"]
    batch_test(input_tests, "ERRO")
  end

  it "should not accept phrases in the form SUBSTANTIVO" do
    input_tests = ["SUBSTANTIVO"]
    batch_test(input_tests, "ERRO")
  end

  it "should not accept phrases in the form SUBSTANTIVO (CONECTIVO SUBSTANTIVO)+" do
    input_tests = ["SUBSTANTIVO CONECTIVO SUBSTANTIVO", "SUBSTANTIVO CONECTIVO SUBSTANTIVO CONECTIVO SUBSTANTIVO"]
    batch_test(input_tests, "ERRO")
  end

  it "should not accept phrases in the form FIM_DE_FRASE" do
    input_tests = ["FIM_DE_FRASE"]
    batch_test(input_tests, "ERRO")
  end

  it "should accept phrases in the form SUJEITO FIM_DE_FRASE" do
    input_tests = ["SUJEITO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form SINTAGMA_VERBAL FIM_DE_FRASE" do
    input_tests = ["SINTAGMA_VERBAL FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form SUJEITO SINTAGMA_VERBAL FIM_DE_FRASE" do
    input_tests = ["SUJEITO SINTAGMA_VERBAL FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form SUBSTANTIVO FIM_DE_FRASE" do
    input_tests = ["SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form SUBSTANTIVO (CONECTIVO SUBSTANTIVO)+ FIM_DE_FRASE" do
    input_tests = ["SUBSTANTIVO CONECTIVO SUBSTANTIVO FIM_DE_FRASE", "SUBSTANTIVO CONECTIVO SUBSTANTIVO CONECTIVO SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form ARTIGO SUBSTANTIVO FIM_DE_FRASE" do
    input_tests = ["ARTIGO SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form ARTIGO SUBSTANTIVO (CONECTIVO ARTIGO SUBSTANTIVO)+ FIM_DE_FRASE" do
    input_tests = ["ARTIGO SUBSTANTIVO CONECTIVO ARTIGO SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form PRONOME FIM_DE_FRASE" do
    input_tests = ["PRONOME SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form PRONOME (CONECTIVO PRONOME)+ FIM_DE_FRASE" do
    input_tests = ["PRONOME CONECTIVO PRONOME FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end



  it "should accept phrases in the form PRONOME SUBSTANTIVO FIM_DE_FRASE" do
    input_tests = ["PRONOME SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end

  it "should accept phrases in the form PRONOME SUBSTANTIVO (CONECTIVO PRONOME SUBSTANTIVO)+ FIM_DE_FRASE" do
    input_tests = ["PRONOME SUBSTANTIVO CONECTIVO PRONOME SUBSTANTIVO FIM_DE_FRASE"]
    batch_test(input_tests, "")
  end



end
