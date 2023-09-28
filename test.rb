require_relative "Model.rb"
include Model

def arithmetic_test(environment)
    a = IntegerPrimitive.new(9)
    b = IntegerPrimitive.new(2)
    puts "Arithmetic test"
    puts "a: #{a.to_s}, b: #{b.to_s}"
    c = Add.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Subtract.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Multiply.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Divide.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Exponentiate.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"

    a = FloatPrimitive.new(4.5)
    b = FloatPrimitive.new(2.7)
    c = Add.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"

    #arithmetic_fail("expression", environment)
    #arithmetic_fail("numeric", environment)
    #arithmetic_fail("incompatible", environment)
end

def arithmetic_fail(val, environment)
    if (val == "expression")
        a = 9
        b = 6
        c = Add.new(a,b)
        c.evaluate(environment)
    elsif (val == "numeric")
        a = BooleanPrimitive.new(true)
        b = IntegerPrimitive.new(6)
        c = Add.new(a,b)
        c.evaluate(environment)
    elsif (val == "incompatible")
        a = FloatPrimitive.new(5)
        b = IntegerPrimitive.new(6)
        c = Add.new(a,b)
        c.evaluate(environment)
    end
end

def logical_test(environment)
    a = BooleanPrimitive.new(true)
    b = BooleanPrimitive.new(false)
    puts "Logical test"
    puts "a: #{a.to_s}, b: #{b.to_s}"
    c = AndLogical.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = AndLogical.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = OrLogical.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = OrLogical.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = NotLogical.new(a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = NotLogical.new(b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    #logical_fail("expression", environment)
    #logical_fail("boolean", environment)
    #logical_fail("incompatible", environment)
    puts("\n")
end

def logical_fail(val, environment)
    if (val == "expression")
        a = 9
        b = 6
        c = AndLogical.new(a,b)
        c.evaluate(environment)
    elsif (val == "boolean")
        a = BooleanPrimitive.new(true)
        b = IntegerPrimitive.new(6)
        c = AndLogical.new(b,a)
        c.evaluate(environment)
    elsif (val == "incompatible")
        a = FloatPrimitive.new(5)
        b = IntegerPrimitive.new(6)
        c = Add.new(a,b)
        c.evaluate(environment)
    end
end

def bitwise_test(environment)
    a = IntegerPrimitive.new(8)
    b = IntegerPrimitive.new(2)
    puts "Bitwise test"
    puts "a: #{a.to_s}, b: #{b.to_s}"
    c = AndBitwise.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = OrBitwise.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = NotBitwise.new(a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Xor.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LeftShift.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = RightShift.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}\n"
    #bitwise_fail("expression", environment)
    #bitwise_fail("boolean", environment)
    #bitwise_fail("incompatible", environment)
    puts("\n")
end

def bitwise_fail(val, environment)
    if (val == "expression")
        a = 9
        b = 6
        c = AndLogical.new(a,b)
        c.evaluate(environment)
    elsif (val == "boolean")
        a = BooleanPrimitive.new(true)
        b = IntegerPrimitive.new(6)
        c = AndLogical.new(b,a)
        c.evaluate(environment)
    elsif (val == "incompatible")
        a = FloatPrimitive.new(5)
        b = IntegerPrimitive.new(6)
        c = Add.new(a,b)
        c.evaluate(environment)
    end
end

def relational_test(environment)
    a = IntegerPrimitive.new(8)
    b = IntegerPrimitive.new(2)
    d = IntegerPrimitive.new(10)
    puts "Relational test"
    puts "a: #{a.to_s}, b: #{b.to_s}, d: #{d.to_s}"
    c = Equals.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Equals.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = NotEquals.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = NotEquals.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LessThan.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LessThan.new(b,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LessEquals.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LessEquals.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = LessEquals.new(a,d)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = GreaterThan.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = GreaterThan.new(b,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = GreaterEquals.new(a,b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = GreaterEquals.new(a,a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = GreaterEquals.new(a,d)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    puts("\n")
end

def cast_test(environment)
    puts "Cast test"
    a = FloatPrimitive.new(5.0)
    b = IntegerPrimitive.new(4)
    puts "a: #{a.to_s}(Float), b: #{b.to_s}(Integer)"
    c = IntToFloat.new(b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = FloatToInt.new(a)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    puts("\n")
end

def statistical_test(environment)
    test_grid = environment.grid
    i = 0
    while (i < 2)
        j = 0
        while (j < 10) 
            address = Address.new(i, j)
            rval = CellRValue.new(address)
            rval.set(IntegerPrimitive.new(j), environment)
            j += 1
        end
        i += 1
    end
    puts "Statistical test"
    a = Address.new(0,0)
    b = Address.new(1,9)
    puts "a: #{a.to_s}, b: #{b.to_s}"
    c = Max.new(a, b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Min.new(a, b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Mean.new(a, b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"
    c = Sum.new(a, b)
    puts "#{c.to_s} = #{c.evaluate(environment)}"

    e = Address.new(0, 1)
    d = CellRValue.new(e)
    d.evaluate(environment)
    puts "#{d.to_s}"
    puts("\n")

    # e = Address.new(99, 99)
    # e.evaluate(environment)
    # f = CellRValue.new(e)
    # f.evaluate(environment)
end


grid = Grid.new()
env = Environment.new(grid)
arithmetic_test(env)
puts("\n")
logical_test(env)
bitwise_test(env)
relational_test(env)
cast_test(env)
statistical_test(env)
