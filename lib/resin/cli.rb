require 'strscan'

module Resin
  class CLI
    RULES = {'SUJEITO'           => [['SINTAGMA_SUBSTANTIVO']],
             'SINTAGMA_SUBSTANTIVO' => [['SINTAGMA_SUBSTANTIVO_SIMPLES'], ['SUJEITO', 'CONECTIVO', 'SINTAGMA_SUBSTANTIVO_SIMPLES']],
             'SINTAGMA_SUBSTANTIVO_SIMPLES' => [['SUBSTANTIVO'], ['ARTIGO', 'SUBSTANTIVO'], ['PRONOME'], ['ARTIGO', 'PRONOME']], 
             'SINTAGMA_VERBAL'   => [['VERBO'], ['SINTAGMA_VERBAL', 'VERBO']]}
    GOAL  = {'FRASE'   => [['SUJEITO', 'FIM_DE_FRASE'],
                           ['SINTAGMA_VERBAL', 'FIM_DE_FRASE'],
                           ['SUJEITO', 'SINTAGMA_VERBAL', 'FIM_DE_FRASE']] }

    def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
      s = stdin.read
      s = s.gsub(/\n/, ' ').strip.split
      s.each_index { |i|
        s[i] = s[i].split('|') if s[i].split('|').length > 1
      }

      success = false
      permute(s).each { |value|
        success = analyze_phrase(value)
        break if success
      }
      stdout.puts "ERRO" if !success && !s.empty?
    end

    private
    def self.analyze_phrase(phrase)
        return phrase if phrase.empty?
        stack = []

        phrase.each { |token|
            stack.push(token)
            reduce!(stack).inspect
        }

        reduce!(stack, GOAL)
    end

    def self.reduce!(stack, rules = RULES)
        stack.length.downto(1) { |i|
            rules.each { |rule, values|
                values.each { |value| 
                    if stack[-i..-1] == value
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
