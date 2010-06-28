require 'logger'

module Resin
  class CLI
    RULES = {'SUJEITO'                             => [['SINTAGMA_SUBSTANTIVO']],
             'SINTAGMA_SUBSTANTIVO'                => [['SINTAGMA_SUBSTANTIVO_SIMPLES'], ['SUJEITO', 'CONECTIVO', 'SINTAGMA_SUBSTANTIVO_SIMPLES']],
             'SINTAGMA_SUBSTANTIVO_SIMPLES'        => [['SUBSTANTIVO'], ['ARTIGO', 'SUBSTANTIVO'], ['PRONOME'], ['ARTIGO', 'PRONOME'],
                                                       ['SUJEITO', 'SUBSTANTIVO'], ['SUJEITO', 'SINTAGMA_ADJETIVO'], ['SINTAGMA_ADJETIVO', 'SUJEITO']],
             'SINTAGMA_SUBSTANTIVO_PREPOSICIONADO' => [['PREPOSICAO', 'SINTAGMA_SUBSTANTIVO_SIMPLES']],
             'SINTAGMA_ADJETIVO'                   => [['SINTAGMA_ADJETIVO_SIMPLES'], ['SINTAGMA_ADJETIVO', 'CONECTIVO', 'SINTAGMA_ADJETIVO']],
             'SINTAGMA_ADJETIVO_SIMPLES'           => [['ADJETIVO'], ['SINTAGMA_SUBSTANTIVO_PREPOSICIONADO']],
             'SINTAGMA_ADVERBIAL'                  => [['ADVERBIO'], ['SINTAGMA_ADVERBIAL', 'ADVERBIO'],
                                                       ['SINTAGMA_ADVERBIAL', 'CONECTIVO', 'ADVERBIO'], ['SINTAGMA_SUBSTANTIVO_PREPOSICIONADO']],
             'SINTAGMA_VERBAL'                     => [['VERBO'], ['SINTAGMA_VERBAL', 'VERBO']]}
    GOAL  = {'FRASE'   => [['SUJEITO', 'FIM_DE_FRASE'],
                           ['SINTAGMA_VERBAL', 'FIM_DE_FRASE'],
                           ['SUJEITO', 'SINTAGMA_VERBAL', 'FIM_DE_FRASE'],
                           ['SINTAGMA_ADVERBIAL', 'CONECTIVO', 'SUJEITO', 'SINTAGMA_VERBAL', 'SINTAGMA_ADVERBIAL', 'FIM_DE_FRASE'],
                           ['SINTAGMA_ADVERBIAL', 'CONECTIVO', 'SUJEITO', 'FIM_DE_FRASE'],
                           ['SUJEITO', 'SINTAGMA_VERBAL', 'SINTAGMA_ADVERBIAL', 'FIM_DE_FRASE'],
                           ['SINTAGMA_ADVERBIAL', 'FIM_DE_FRASE'],

                           # Com sintagma adjetivo
                           ['SUJEITO', 'SINTAGMA_ADJETIVO', 'FIM_DE_FRASE'],
                           ['SINTAGMA_VERBAL', 'SINTAGMA_ADJETIVO',  'FIM_DE_FRASE'],
                           ['SUJEITO', 'SINTAGMA_VERBAL', 'SINTAGMA_ADJETIVO',  'FIM_DE_FRASE'],
                           ['SINTAGMA_ADVERBIAL', 'CONECTIVO', 'SUJEITO', 'SINTAGMA_VERBAL', 'SINTAGMA_ADJETIVO',  'SINTAGMA_ADVERBIAL', 'FIM_DE_FRASE'],
                           ['SINTAGMA_ADVERBIAL', 'CONECTIVO', 'SUJEITO', 'SINTAGMA_ADJETIVO',  'FIM_DE_FRASE'],
                           ['SUJEITO', 'SINTAGMA_VERBAL', 'SINTAGMA_ADJETIVO',  'SINTAGMA_ADVERBIAL', 'FIM_DE_FRASE']] }

    def self.execute(stdout=STDOUT, stdin=STDIN, log=Logger.new(STDERR), arguments=[])
      @log = log

      s = phrase = stdin.read
      @log.debug "Input: #{s.inspect}"
      s = s.gsub(/\n/, ' ').strip.split
      s.each_index { |i|
        s[i] = s[i].split('|') if s[i].split('|').length > 1
      }

      success = false
      permute(s).each { |value|
        result = analyze_phrase(value)
        @log.debug "Result: #{result.inspect}"
        success = result && result.length == 1 && GOAL.keys.include?(result[0])
        break if success
      }
      if !success && !s.empty?
        phrase = phrase.gsub(/\n/, ' ').strip.downcase
        phrase = phrase.gsub(/ /, ', ').gsub(/\|/, ' ou ').gsub(/_/, ' ')
        phrase = phrase.gsub(/\(m/, ' masculino').gsub(/\(f/, ' feminino')
        phrase = phrase.gsub(/s\)/, ' singular').gsub(/p\)/, ' plural')
        error_message = "Frase '#{phrase}' inválida"
        @log.error error_message
        stdout.puts error_message
        `espeak -vpt -s130 "#{error_message}"` if !arguments.empty?
      end
    end

    private
    def self.analyze_phrase(phrase)
        @log.debug "Analyzing #{phrase.inspect}..."
        return phrase if phrase.empty?
        return nil if tem_erros_de_concordancia?(phrase)
        phrase.map! { |v|
            if v =~ /\(.*\)$/
                v[0..-5]
            else
                v
            end
        }
        stack = []

        @log.debug "Stack: #{stack.inspect}"
        phrase.each { |token|
            stack.push(token)
            @log.debug "Stack: #{stack.inspect}"
            reduce!(stack).inspect
        }
        @log.debug "Stack: #{stack.inspect}"

        result = reduce!(stack, GOAL) 
        @log.debug "Stack: #{stack.inspect}"

        result
    end

    def self.tem_erros_de_concordancia?(phrase)
        flexoes = phrase.map { |v| v[-4..-1] if v =~ /\(.*\)/ }
        flexoes.delete(nil)
        @log.debug "Flexões: #{flexoes.inspect}"
        flexoes.uniq!
        flexoes.length > 1
    end

    def self.reduce!(stack, rules = RULES)
        stack.length.downto(1) { |i|
            rules.each { |rule, values|
                values.each { |value|
                    phrase = stack[-i..-1]

                    if phrase == value
                        @log.debug "Reduce: #{phrase.inspect} => #{rule.inspect}"
                        stack[-i..-1] = rule
                        return self.reduce!(stack, rules) if rules == RULES
                        return stack
                    end
                }
            }
        }

        nil
    end

    def self.permute(list)
        res = []
        array_indexes = []
        arrays = []
        list.each_with_index { |e, i| 
            if e.class == Array
                array_indexes << i
                arrays << e
            end
        }
        return [list] if arrays.empty?

        arrays_products = arrays[0].product(*arrays[1..-1])
        arrays_products.each { |p|
            res << Array.new(list)
            array_indexes.each_with_index { |e, i| res.last[e] = p[i] }
        }
        res
    end
  end
end
