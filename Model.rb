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
            if (!check(address.x.value, address.y.value))
                return nil
            end
            return @array[address.x.value][address.y.value]
        end

        def set (address, rvalue)
            if (address.x >= @array.length() or address.y >= @array[address.x].length())
                resize(address.x, address.y)
            end
            @array[address.x][address.y] = rvalue
        end

        def check(x, y)
            if (x >= @array.length() or y >= @array[x].length())
                return false
            elsif @array[x][y] == nil
                return false
            end
            true
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
        attr_accessor :loc_y, :loc_x
        def initialize(left, right, loc_x, loc_y)
            @left = left
            @right = right
            @loc_x = loc_x
            @loc_y = loc_y
        end
        def loc_to_s
            "(#{loc_x}, #{loc_y})"
        end
    end
    
    #Primitive
    class Primitive < Expression
        attr_reader :value, :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value
            @loc_x = loc_x
            @loc_y = loc_y
        end
        def evaluate(environment)
            if (@value.is_a?(Expression)) 
                raise "Invalid input, must be primitive: #{@value} #{@value.loc_to_s}"
            end
            self
        end
        def to_s
            "#{@value}"
        end
    end
    
    class IntegerPrimitive < Primitive
        attr_reader :value, :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value.to_i
            @loc_x = loc_x
            @loc_y = loc_y
        end
    end

    class FloatPrimitive < Primitive
        attr_reader :value, :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value.to_f
            @loc_x = loc_x
            @loc_y = loc_y
        end
    end

    class StringPrimitive < Primitive
    end

    class BooleanPrimitive < Primitive
        def evaluate(environment)
            if (@value.instance_of? Expression)
                raise "Invalid input, must be primitive: #{@value} #{@value.loc_to_s}" 
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
                raise "Incompatible Operands:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
            end
            raise "Operands must be numeric:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
        end
    end
    
    class Add < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value + vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} + #{@right.to_s}"
        end  
    end

    class Subtract < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value - vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} - #{@right.to_s}"
        end   
    end
    
    class Multiply < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value * vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} * #{@right.to_s}"
        end  
    end
    
    class Divide < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value / vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} / #{@right.to_s}"
        end  
    end
    
    class Modulo < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value % vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} % #{@right.to_s}"
        end  
    end
    
    class Exponentiate < Arithmetic
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            vals[0].class.new(vals[0].value ** vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} ** #{@right.to_s}"
        end 
    end

    #Logical
    class Logical < Expression
        def typecheck(val1, val2, environment)
            if (val1.instance_of?(BooleanPrimitive))
                if (val1.class == val2.class)
                    return [val1, val2]
                end
                raise "Incompatible Operands:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
            end
            raise "Operands must be boolean:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
        end
    end

    class AndLogical < Logical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value && vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} && #{@right.to_s}"
        end 
    end

    class OrLogical < Logical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value || vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} || #{@right.to_s}"
        end 
    end

    class NotLogical < Logical
        attr_accessor :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value
            @loc_x = loc_x
            @loc_y = loc_y
        end
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression || val.instance_of?(BooleanPrimitive))
                if (val.instance_of?(BooleanPrimitive))
                    return BooleanPrimitive.new(!val.value, val.loc_x, val.loc_y)
                end
                raise "Operand must be Boolean\n#{val.class} #{val} #{val.loc_to_s}"
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
                    raise "Incompatible Operands:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
                end
                raise "Operands must be integers:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
            end
            raise "Operand must be Expression: #{val1}, #{val2}"
        end
    end

    class AndBitwise < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            
            IntegerPrimitive.new(vals[0].value & vals[1].value, @left.loc_x, @right.loc_y)
        end

        def to_s
            "#{@left.to_s} & #{@right.to_s}"
        end 
    end

    class OrBitwise < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value | vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} | #{@right.to_s}"
        end
    end

    class NotBitwise < Bitwise
        attr_accessor :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value
            @loc_x = loc_x
            @loc_y = loc_y
        end
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(IntegerPrimitive))
                    return IntegerPrimitive.new(~(val.value), val.loc_x, val.loc_y)
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
            IntegerPrimitive.new(vals[0].value ^ vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} ^ #{@right.to_s}"
        end
    end

    class LeftShift < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value << vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} << #{@right.to_s}"
        end
    end

    class RightShift < Bitwise
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            IntegerPrimitive.new(vals[0].value >> vals[1].value, @left.loc_x, @right.loc_y)
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
                raise "Incompatible Operands:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
            end
            raise "Operands must be numeric:\n#{val1.class} #{val1} #{val1.loc_to_s}\n#{val2.class} #{val2} #{val2.loc_to_s}"
        end
    end

    class Equals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value == vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} == #{@right.to_s}"
        end
    end

    class NotEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value != vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} != #{@right.to_s}"
        end
    end
    class LessThan < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value < vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} < #{@right.to_s}"
        end
    end
    class LessEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value <= vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} <= #{@right.to_s}"
        end
    end
    class GreaterThan < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value > vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} > #{@right.to_s}"
        end
    end
    class GreaterEquals < Relational
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            BooleanPrimitive.new(vals[0].value >= vals[1].value, @left.loc_x, @right.loc_y)
        end
        def to_s
            "#{@left.to_s} >= #{@right.to_s}"
        end
    end

    #Cast
    class Cast < Expression
        attr_accessor :loc_y, :loc_x
        def initialize(value, loc_x, loc_y)
            @value = value
            @loc_x = loc_x
            @loc_y = loc_y
        end
    end
  
    class FloatToInt < Cast
        def evaluate(environment)
            val = @value.evaluate(environment)
            if (val.is_a? Expression)
                if (val.instance_of?(FloatPrimitive))
                    return IntegerPrimitive.new(val.value.to_i, val.loc_x, val.loc_y)
                end
                raise "Operand must be Float: #{val.class} #{val} #{val.loc_to_s}"
            end
            raise "Operand must be Expression: #{val}"
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
                    return FloatPrimitive.new(val.value.to_f, val.loc_x, val.loc_y)
                end
                raise "Operand must be Integer: #{val.class} #{val} #{val.loc_to_s}"
            end
            raise "Operand must be Expression: #{val} #{val.loc_to_s}"
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
                raise "Incompatible Types:\n#{val1.class} #{val1} #{val1.loc_to_s}\n #{val2.class} #{val2} #{val2.loc_to_s}"
            end
            raise "Operand must be Address: #{val1} #{val1.loc_to_s}, #{val2} #{val2.loc_to_s}"
        end
    end

    class Max < Statistical
        def evaluate(environment)
            vals = typecheck(@left.evaluate(environment), @right.evaluate(environment), environment)
            max = nil

            r_x = @right.x.evaluate(environment).value
            r_y = @right.y.evaluate(environment).value

            i = @left.x.evaluate(environment).value
            while (i <= r_x) # row loop
                j = @left.y.evaluate(environment).value
                while (j <= r_y) # col loop
                    curval = CellRValue.new(IntegerPrimitive.new(i, 0, 0), IntegerPrimitive.new(j, 0, 0), 0, 0)
                    if (curval != nil && curval.evaluate(environment) != nil) # makes sure the rvalue exists
                        if (max == nil) # set max if nil or replace old value 
                            max = curval.evaluate(environment)
                        elsif (max.evaluate(environment).value < curval.evaluate(environment).value)
                            max = curval.evaluate(environment)
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

            r_x = @right.x.evaluate(environment).value
            r_y = @right.y.evaluate(environment).value

            i = @left.x.evaluate(environment).value
            while (i <= r_x) # row loop
                j = @left.y.evaluate(environment).value
                while (j <= r_y) # col loop
                    curval = CellRValue.new(IntegerPrimitive.new(i, 0, 0), IntegerPrimitive.new(j, 0, 0), 0, 0)
                    if (curval != nil && curval.evaluate(environment) != nil) # makes sure the rvalue exists
                        if (min == nil) 
                            min = curval.evaluate(environment)
                        elsif (min.evaluate(environment).value > curval.evaluate(environment).value)
                            min = curval.evaluate(environment)
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

            r_x = @right.x.evaluate(environment).value
            r_y = @right.y.evaluate(environment).value

            i = @left.x.evaluate(environment).value
            while (i <= r_x) # row loop
                j = @left.y.evaluate(environment).value
                while (j <= r_y) # col loop
                    curval = CellRValue.new(IntegerPrimitive.new(i, 0, 0), IntegerPrimitive.new(j, 0, 0), 0, 0)
                    if (curval != nil && curval.evaluate(environment) != nil)
                        items += 1
                        sum += curval.evaluate(environment).value
                    end
                    j += 1
                end
                i += 1
            end
            if items == 0
                return 0
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

            r_x = @right.x.evaluate(environment).value
            r_y = @right.y.evaluate(environment).value

            i = @left.x.evaluate(environment).value
            while (i <= r_x) # row loop
                j = @left.y.evaluate(environment).value
                while (j <= r_y) # col loop
                    curval = CellRValue.new(IntegerPrimitive.new(i, 0, 0), IntegerPrimitive.new(j, 0, 0), 0, 0)
                    if (curval != nil && curval.evaluate(environment) != nil)
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
        attr_reader :x, :y, :loc_y, :loc_x
        def initialize(x, y, loc_x, loc_y)
            @x = x 
            @y = y
            @loc_x = loc_x
            @loc_y = loc_y
        end
        def evaluate(environment)
            if (!@x.is_a? IntegerPrimitive)
                raise "Operand must be primitive"
            end
            self
        end
        def to_s
            "(#{@x}, #{@y})"
        end
    end

    class CellRValue
        attr_accessor :x, :y, :address, :value, :loc_y, :loc_x
        def initialize(x, y, loc_x, loc_y)
            @x = x
            @y = y
            @loc_x = loc_x
            @loc_y = loc_y
            @address = Address.new(@x, @y, @loc_x, @loc_y)
            @value = nil
        end 
        def set(val, environment)
            @value = val
            environment.grid.set(@address, @value)
        end
        def get(environment)
            @value = environment.grid.get(@address)
        end
        def evaluate(environment)
            self.get(environment)
            ret = nil
            if @value != nil
                ret = @value.evaluate(environment)
            end
        end
        def to_s
            "#{@address}: #{@value}"
        end
    end
end