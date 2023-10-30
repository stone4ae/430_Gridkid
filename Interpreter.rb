require_relative "Model.rb"
include Model

module Interpreter
    class Lexer
        def lexer (input)
            tokens = []
            index = 0
            inputs = input.chars
            len = inputs.length
    
            while index < len
    
                current_char = inputs.at(index)
                current_token = current_char
                finish = index
                type = :temp
                str = false
                
                if current_char == ' '
                    index += 1
                elsif current_char == '+'
                    type = :add
                elsif current_char == '-'
                    type = :subtract
                elsif current_char == '/'
                    type = :divide
                elsif current_char == '%'
                    type = :modulo
                elsif current_char == '^'
                    type = :bitwise_xor
                elsif current_char == ','
                    type = :comma
                elsif current_char == "("
                    type = :left_parenthesis  
                elsif current_char == ")"
                    type = :right_parenthesis
                elsif current_char == "~"
                    type = :bitwise_not
                # All operators that have 2 digits
                elsif current_char == '!'
                    if (index + 1) < len && inputs.at(index + 1) == '='
                        current_token += inputs.at(index + 1)
                        finish = index + 1
                        type = :not_equal
                    else
                        type = :logical_not
                    end
                elsif current_char == '=' || current_char == '*' || 
                      current_char == '&' || current_char == '|' || 
                      current_char == '<' || current_char == '>'
                    if (index + 1) < len && inputs.at(index + 1) != ' '
                        current_token += inputs.at(index + 1)
                        finish = index + 1
                    end
                    case current_token
                    when '=='
                        type = :equals
                    when '&'
                        type = :bitwise_and
                    when '&&'
                        type = :logical_and
                    when '|'
                        type = :bitwise_or
                    when '||'
                        type = :logical_or
                    when '<'
                        type = :less_than
                    when '<<'
                        type = :bitwise_left
                    when '<='
                        type = :less_equal
                    when '>'
                        type = :greater_than
                    when '>>'
                        type = :bitwise_right
                    when '>='
                        type = :greater_equal
                    when '*'
                        type = :multiply
                    when '**'
                        type = :exponentiate
                    else
                        raise "Unrecognized token at #{index} : #{current_token}"
                    end
                elsif current_char == "\"" # For string literals
                    if (index + 1) < len
                        index += 1
                        current_token = ""
                        i = index
                        while (i < len && inputs.at(i) != "\"") #Tokenize until end quote
                            current_token += inputs.at(i)
                            i += 1
                        end
                        if (inputs.at(i) != "\"")
                            raise "Unrecognized token at #{index} : #{current_token}, no closing quote\n"
                        end
                        type = :string_literal
                        finish = index + current_token.length - 1
                        str = true # Accounts for the endquote
                    else
                        raise "Unrecognized token at #{index} : #{current_token}"
                    end
                elsif current_char.match?(/\d/) # Records numerals
                    type = :integer_literal
                    i = index
                    if (index + 1) < len
                        i += 1
                        while i < len && inputs.at(i).match?(/\d/)
                            current_token += inputs.at(i)
                            i += 1
                        end
                        if inputs.at(i) == '.' # Float value
                            current_token += inputs.at(i)
                            if (i + 1) < len 
                                i += 1
                                while i < len && inputs.at(i).match?(/\d/) # Makes sure its reading in numerals
                                    current_token += inputs.at(i)
                                    i += 1
                                end
                                if !current_token.chars.at(current_token.length - 1).match?(/\d/) # Catches 5. or something
                                    raise "Unrecognized token at #{index} : #{current_token}"
                                end
                                type = :float_literal
                            else
                                raise "Unrecognized token at #{index} : #{current_token}"
                            end
                        elsif i < len && inputs.at(i) != ',' && inputs.at(i) != ')' && 
                              inputs.at(i) != ' '
                            current_token += inputs.at(i)
                            raise "Unrecognized token at #{index} : #{current_token}"
                        end
                        finish = i - 1
                    end
                elsif current_char.match?(/[A-Za-z_.]/) #Takes in letters to get function names/booleans
                    if (index + 1) < len
                        i = index + 1
                        while i < len && inputs.at(i) != ' ' && 
                              inputs.at(i) != ')' && inputs.at(i) != '('
                            current_token += inputs.at(i)
                            i += 1
                        end
                        finish = i - 1
                        if current_token.downcase == 'max'
                            type = :max 
                        elsif current_token.downcase == 'min'
                            type = :min
                        elsif current_token.downcase == 'mean'
                            type = :mean
                        elsif current_token.downcase == 'sum'
                            type = :sum
                        elsif current_token.downcase == '.to_i'
                            type = :float_to_int
                        elsif current_token.downcase == '.to_f'
                            type = :int_to_float
                        elsif current_token.downcase == 'true' || 
                              current_token.downcase == 'false'
                            type = :boolean_literal
                        elsif current_token.downcase == 'rvalue'
                          type = :rvalue
                        else
                            raise "Unrecognized token at #{index} : #{current_token}"
                        end
                    end
                end
                if current_char != ' '
                    tokens.push({type: type, value: current_token, start: index, end: finish})
                    index += current_token.length
                    if str
                        index += 1
                    end
                end
            end
            tokens.push(type: :EOF, value: nil, start: nil, end: nil)
            return tokens
        end
    end

    class Parser
        attr_accessor :tokens, :index, :env
        def initialize (tokens, environment)
            self.tokens = tokens
            self.index = 0
            self.env = env
        end

        def has (type)
            return self.tokens.at(index)[:type] == type
        end
        
        def capture
            token = tokens.at(index)
            self.index += 1
            token
        end

        def parse
            expression
        end

        def expression
            operation
        end

        def operation
            left = unary
            loop do
                # Arithmetic Expression
                if has(:add) || has(:subtract) || has(:multiply) || has(:divide) || 
                   has(:modulo) || has(:exponentiate)
                    left = arithmetic_expression(left)
                # Logical Expression
                elsif has(:logical_and) || has(:logical_or)
                    left = logical_expression(left)
                # Bitwise Expression
                elsif has(:bitwise_and) || has(:bitwise_or) || has(:bitwise_xor) || 
                      has(:bitwise_left) || has(:bitwise_right)
                    return bitwise_expression(left)
                # Relational Expression
                elsif has(:equals) || has(:less_than) || has(:less_equal) || 
                      has(:greater_than) || has(:greater_equal) || has(:not_equal)
                    left = relational_expression(left)
                # Cast Expression
                elsif has(:float_to_int) || has(:int_to_float)
                    left = cast_expression(left)
                # Cell Lvalue
                elsif has(:comma)
                    capture
                    right = unary
                    left = Address.new(left, right, left.loc_x, right.loc_y)
                # Cell Rvalue assignment
                elsif has(:assignment)
                    capture
                    right = expression
                    left = CellRValue.new(left.x, left.y, left.loc_x, left.loc_y)
                else
                    break
                end
            end
            left
        end

        def arithmetic_expression (left)
            if has(:add)
                capture
                right = unary
                left = Add.new(left, right, left.loc_x, right.loc_y)
            elsif has(:subtract)
                capture
                right = unary
                left = Subtract.new(left, right, left.loc_x, right.loc_y)
            elsif has(:multiply)
                capture
                right = unary
                left = Multiply.new(left, right, left.loc_x, right.loc_y)
            elsif has(:divide)
                capture
                right = unary
                left = Divide.new(left, right, left.loc_x, right.loc_y)
            elsif has(:modulo)
                capture
                right = unary
                left = Modulo.new(left, right, left.loc_x, right.loc_y)
            elsif has(:exponentiate)
                capture
                right = unary
                left = Exponentiate.new(left, right, left.loc_x, right.loc_y)
            end
        end

        def logical_expression (left)
            if has(:logical_and)
                capture
                right = unary
                AndLogical.new(left, right, left.loc_x, right.loc_y)
            elsif has(:logical_or)
                capture
                right = unary
                OrLogical.new(left, right, left.loc_x, right.loc_y)
            elsif has(:logical_not)
                capture
                right = unary
                NotLogical.new(right, right.loc_x, right.loc_y)
            end
        end

        def bitwise_expression (left)
            if has(:bitwise_and)
                capture
                right = unary
                AndBitwise.new(left, right, left.loc_x, right.loc_y)
            elsif has(:bitwise_or)
                capture
                right = unary
                OrBitwise.new(left, right, left.loc_x, right.loc_y)
            elsif has(:bitwise_xor)
                capture
                right = unary
                Xor.new(left, right, left.loc_x, right.loc_y)
            elsif has(:bitwise_left)
                capture
                right = unary
                LeftShift.new(left, right, left.loc_x, right.loc_y)
            elsif has(:bitwise_right)
                capture
                right = unary
                RightShift.new(left, right, left.loc_x, right.loc_y)
            elsif has(:bitwise_not)
                capture
                right = unary
                NotBitwise.new(right, right.loc_x, right.loc_y)
            end
        end

        def relational_expression (left)
            if has(:equals)
                capture
                right = unary
                Equals.new(left, right, left.loc_x, right.loc_y)
            elsif has(:less_than)
                capture
                right = unary
                LessThan.new(left, right, left.loc_x, right.loc_y)
            elsif has(:less_equal)
                capture
                right = unary
                LessEquals.new(left, right, left.loc_x, right.loc_y)
            elsif has(:greater_than)
                capture
                right = unary
                GreaterThan.new(left, right, left.loc_x, right.loc_y)
            elsif has(:greater_equal)
                capture
                right = unary
                GreaterEquals.new(left, right, left.loc_x, right.loc_y)
            elsif has(:not_equal)
                capture
                right = unary
                NotEquals.new(left, right, left.loc_x, right.loc_y)
            end
        end

        def statistical_expression
            if has(:max)
                capture
                left = unary
                right = unary
                Max.new(left, right, left.loc_x, right.loc_y)
            elsif has(:min)
                capture
                left = unary
                right = unary
                Min.new(left, right, left.loc_x, right.loc_y)
            elsif has(:mean)
                capture
                left = unary
                right = unary
                Mean.new(left, right, left.loc_x, right.loc_y)
            elsif has(:sum)
                capture
                left = unary
                right = unary
                Sum.new(left, right, left.loc_x, right.loc_y)
            end
        end

        def cast_expression (left)
            if has(:float_to_int)
                capture
                FloatToInt.new(left, left.loc_x, left.loc_y)
            elsif has(:int_to_float)
                capture
                IntToFloat.new(left, left.loc_x, left.loc_y)
            end
        end

        def unary
            # Isolate Expression in Parentheses
            if has(:left_parenthesis)
                capture
                e = expression
                if has(:right_parenthesis)
                    capture
                else
                    raise "Missing Right Parenthesis in #{e} at (#{e.loc_x}, #{e.loc_y})" 
                end
                e
            # Prefix functions ie Max, Min, !, ~
            elsif has(:logical_not)
                logical_expression(nil)
            elsif has(:bitwise_not)
                bitwise_expression(nil)
            elsif has(:max) || has(:min) ||  has(:mean) || has(:sum)
                statistical_expression
            # Primitives
            elsif has(:integer_literal) || has(:float_literal) || 
                  has(:boolean_literal) || has(:string_literal)
                primitive
            elsif has(:rvalue)
                capture
                left = unary
                CellRValue.new(left.x, left.y, @index, @index)
            elsif has(:EOF)
                raise "#{err_token("Out of tokens")}"
            else
                raise "#{err_token("Unknown Token")}"
            end
        end

        def primitive
            if has(:integer_literal)
                token = capture
                IntegerPrimitive.new(token[:value], token[:start], token[:end])
            elsif has(:float_literal)
                token = capture
                FloatPrimitive.new(token[:value], token[:start], token[:end])
            elsif has(:boolean_literal)
                token = capture
                BooleanPrimitive.new(token[:value], token[:start], token[:end])
            elsif has(:string_literal)
                StringPrimitive.new(token[:value], token[:start], token[:end])
            end
        end

        def err_token(msg)
            information = "Type: #{tokens.at(index)[:type]}\n" +
                          "Value: #{tokens.at(index)[:value]}\n" +
                          "Location: (#{tokens.at(index)[:start]}, #{tokens.at(index)[:end]})\n"          
            raise "#{msg}\n#{information}"
        end

        def err_abstract(msg, obj)
            raise "#{msg}\n"
        end
    end
end