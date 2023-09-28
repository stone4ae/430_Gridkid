module Model

    #Abstractions
    class Environment
        attr_accessor :grid
        def initialize(grid)
            @grid = grid #reference to the grid
        end
    end
    
    class Grid
        attr_accessor :array
        def initialize
            @array = Array.new(10) { Array.new(10)}
        end

        def get(address)
            check(address.x, address.y)
            return @array[address.x][address.y]
        end

        def set (address, rvalue)
            if (address.x >= @array.length() or address.y >= @array[address.x].length())
                raise "Out of bounds"
            end
            @array[address.x][address.y] = rvalue
        end

        def check(x, y)
            if (x >= @array.length() or y >= @array[x].length() or @array[x][y] == nil)
                raise "Undefined"
            end
        end 

        def resize(x, y)
            if (x >= @array.length()) 
                dif = x - (@array.length() - 1)
                @array.concat(Array.new(dif) {Array.new(1)})
            end
            if (y >= @array[x].length() ) 
                dif = y - (@array[y].length() - 1)
                @array[x].concat(Array.new(dif))
            end
        end
    end
    
    class Expression
        def initialize(left, right)
            @left = left
            @right = right
        end
    end
    
    #Primitive
    class Primitive < Expression
        attr_reader :value
        def initialize(value)
            @value = value
        end
        def evaluate(environment)
            if (@value.is_a?(Expression)) 
                raise "Invalid input, must be primitive"
            end
            self
        end
        def to_s
            "#{@value}"
        end
    end
    
    class IntegerPrimitive < Primitive
    end

    class FloatPrimitive < Primitive
    end

    class StringPrimitive < Primitive
    end

    class BooleanPrimitive < Primitive
        def evaluate(environment)
            if (@value.instance_of? Expression)
                raise "Invalid input, must be primitive" 
            end
            if @value == false || @value == nil
                @value = false
            else
                @value = true
            end
            self
        end
    end

    #Arithmetic
    class Arithmetic < Expression
        def typecheck(val1, val2, environment)
            if (val1.instance_of?(FloatPrimitive) or val1.instance_of?(IntegerPrimitive))
                if (val1.class == val2.class)
                    return [val1, val2]
                end
                raise "Incompatible Operands"
            end
            raise "Operands must be numeric"
        end
    end
    
    class Add < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value + vals[1].value)
        end
        def to_s
            "#{@left.to_s} + #{@right.to_s}"
        end  
    end

    class Subtract < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value - vals[1].value)
        end
        def to_s
            "#{@left.to_s} - #{@right.to_s}"
        end   
    end
    
    class Multiply < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value * vals[1].value)
        end
        def to_s
            "#{@left.to_s} * #{@right.to_s}"
        end  
    end
    
    class Divide < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value / vals[1].value)
        end
        def to_s
            "#{@left.to_s} / #{@right.to_s}"
        end  
    end
    
    class Modulo < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value % vals[1].value)
        end
        def to_s
            "#{@left.to_s} % #{@right.to_s}"
        end  
    end
    
    class Exponentiate < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value ** vals[1].value)
        end
        def to_s
            "#{@left.to_s}^#{@right.to_s}"
        end 
    end

    #Logical
    class Logical < Expression
        def typecheck(val1, val2, environment)
            if (val1.instance_of?(BooleanPrimitive))
                if (val1.class == val2.class)
                    return [val1, val2]
                end
                raise "Incompatible Operands"
            end
            raise "Operands must be Boolean"
        end
    end

    class AndLogical < Logical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value && vals[1].value)
        end
        def to_s
            "#{@left.to_s} && #{@right.to_s}"
        end 
    end

    class OrLogical < Logical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value || vals[1].value)
        end
        def to_s
            "#{@left.to_s} || #{@right.to_s}"
        end 
    end

    class NotLogical < Logical
        def initialize(value)
            @value = value
        end
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(BooleanPrimitive))
                    return BooleanPrimitive.new(!val.value)
                end
                raise "Operand must be Boolean"
            end
            raise "Operand must be Expression"
        end
        def to_s
            "!#{@value}"
        end
    end

    #Bitwise
    class Bitwise < Expression
        def typecheck(val1, val2, environment)
            if (val1.is_a? Expression and val2.is_a? Expression)
                if (val1.instance_of?(IntegerPrimitive))
                    if (val1.class == val2.class)
                        return [val1, val2]
                    end
                    raise "Incompatible Operands"
                end
                raise "Operands must be Integers"
            end
            raise "Operand must be Expression"
        end
    end

    class AndBitwise < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value & vals[1].value)
        end
        def to_s
            "#{@left.to_s} & #{@right.to_s}"
        end 
    end

    class OrBitwise < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value | vals[1].value)
        end
        def to_s
            "#{@left.to_s} | #{@right.to_s}"
        end
    end

    class NotBitwise < Bitwise
        def initialize(value)
            @value = value
        end
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(IntegerPrimitive))
                    return IntegerPrimitive.new(~(val.value))
                end
                raise "Operand must be Integer" 
            end
            raise "Operand must be Expression"
            
        end
        def to_s
            "~#{@value.to_s}"
        end
    end

    class Xor < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value ^ vals[1].value)
        end
        def to_s
            "#{@left.to_s} ^ #{@right.to_s}"
        end
    end

    class LeftShift < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value << vals[1].value)
        end
        def to_s
            "#{@left.to_s} << #{@right.to_s}"
        end
    end

    class RightShift < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value >> vals[1].value)
        end
        def to_s
            "#{@left.to_s} >> #{@right.to_s}"
        end
    end

    #Relational
    class Relational < Expression
        def typecheck(val1, val2, environment)
            if (val1.instance_of?(IntegerPrimitive) or val1.instance_of?(FloatPrimitive))
                if (val1.class == val2.class)
                    return [val1, val2]
                end
                raise "Incompatible Operands"
            end
            raise "Operands must be Numeric"
        end
    end

    class Equals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value == vals[1].value)
        end
        def to_s
            "#{@left.to_s} == #{@right.to_s}"
        end
    end

    class NotEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value != vals[1].value)
        end
        def to_s
            "#{@left.to_s} != #{@right.to_s}"
        end
    end
    class LessThan < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value < vals[1].value)
        end
        def to_s
            "#{@left.to_s} < #{@right.to_s}"
        end
    end
    class LessEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value <= vals[1].value)
        end
        def to_s
            "#{@left.to_s} <= #{@right.to_s}"
        end
    end
    class GreaterThan < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value < vals[1].value)
        end
        def to_s
            "#{@left.to_s} > #{@right.to_s}"
        end
    end
    class GreaterEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value >= vals[1].value)
        end
        def to_s
            "#{@left.to_s} >= #{@right.to_s}"
        end
    end

    #Cast
    class Cast < Expression
        def initialize(value)
            @value = value
        end
    end
  
    class FloatToInt < Cast
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(FloatPrimitive))
                    return IntegerPrimitive.new(val.value.to_i)
                end
                raise "Operand must be Float"
            end
            raise "Operand must be Expression"
        end
        def to_s
            "(#{@value.to_s}).to_i"
        end
    end
    class IntToFloat < Cast
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(IntegerPrimitive))
                    return FloatPrimitive.new(val.value.to_f)
                end
                raise "Operand must be Integer"
            end
            raise "Operand must be Expression"
        end
        def to_s
            "(#{@value.to_s}).to_f"
        end
    end

    #Statistical
    class Statistical < Expression
        def typecheck(val1, val2, environment)
            if (val1.instance_of?(Address))
                if (val1.class == val2.class)
                    return [val1, val2]
                end
                raise "Incompatible Types"
            end
            raise "Operand must be Address"
        end
    end

    class Max < Statistical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            max = nil
            i = @left.x
            while (i <= @right.x) # row loop
                j = @left.y
                while (j <= @right.y) # col loop
                    curval = CellRValue.new(Address.new(i, j)).evaluate(environment)
                    if (curval != nil) # makes sure the rvalue exists
                        if (max == nil) # set max if nil or replace old value 
                            max = curval
                        elsif (max.evaluate(environment).value < curval.evaluate(environment).value)
                            max = curval
                        end
                    end
                    j += 1
                end
                i += 1
            end
            return max
        end
        def to_s
            "Max(#{@left.to_s}, #{@right.to_s})"
        end
    end
    class Min < Statistical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            min = nil
            i = @left.x
            while (i <= @right.x) # row loop
                j = @left.y
                while (j <= @right.y) # col loop
                    curval = CellRValue.new(Address.new(i, j)).evaluate(environment)
                    if (curval != nil) # makes sure the rvalue exists
                        if (min == nil) 
                            min = curval
                        elsif (min.evaluate(environment).value > curval.evaluate(environment).value)
                            min = curval
                        end
                    end
                    j += 1
                end
                i += 1
            end
            return min
        end
        def to_s
            "Min(#{@left.to_s}, #{@right.to_s})"
        end
    end
    class Mean < Statistical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            sum = 0
            items = 0
            i = @left.x
            while (i <= @right.x)
                j = @left.y
                while (j <= @right.y)
                    curval = CellRValue.new(Address.new(i, j)).evaluate(environment)
                    if (curval != nil)
                        items += 1
                        sum += curval.evaluate(environment).value
                    end
                    j += 1
                end
                i += 1
            end
            return sum/items
        end
        def to_s
            "Mean(#{@left.to_s}, #{@right.to_s})"
        end
    end
    class Sum < Statistical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            sum = 0
            i = @left.x
            while (i <= @right.x)
                j = @left.y
                while (j <= @right.y)
                    curval = CellRValue.new(Address.new(i, j)).evaluate(environment)
                    if (curval != nil)
                        sum += curval.evaluate(environment).value
                    end
                    j += 1
                end
                i += 1
            end
            return sum
        end
        def to_s
            "Sum(#{@left.to_s}, #{@right.to_s})"
        end
    end

    #References
    class Address
        attr_reader :x, :y
        def initialize(x, y)
            @x = x 
            @y = y
        end
        def evaluate(environment)
            if (@x.is_a? Expression or @y.is_a? Expression)
                raise "Operand must be primitive"
            end
            self
        end
        def to_s
            "(#{@x}, #{@y})"
        end
    end

    class CellRValue
        def initialize(address)
            @x = address.x
            @y = address.y
            @value = nil
        end
        def set(value, environment)
            @value = value
            environment.grid.set(Address.new(@x, @y), value)
        end
        def evaluate(environment)
            @value = environment.grid.get(Address.new(@x, @y))
            return @value.evaluate(environment)
        end
        def to_s
            "(#{@x}, #{@y}): #{@value}"
        end
    end
end
