require_relative "Interpreter.rb"
include Interpreter
require_relative "Model.rb"
include Model

def test_runner(tests, griddy)
    def tester (grid, env, input, expected)
        lex = Lexer.new()
        tokens = lex.lexer(input)
        parsr = Parser.new(tokens, env)
        result = parsr.parse
        puts "[#{input}] -> [#{result}] -> [#{result.evaluate(env)}] -> [#{expected}]"
    end

    def grid_test(grid)
        x = 0
        y = 0
        while y < 10 do  
            grid.set(Address.new(x, y, 0, 0), IntegerPrimitive.new(rand(100), 0, 0))
            y += 1
        end
        array = []
        for x in grid.array[0]
            if x == nil
                break
            end
            array.push(x.value)
        end
        print "Grid : #{array}\n"
        puts  "Max  : #{array.max}"
        puts  "Min  : #{array.min}"
        puts  "Sum  : #{array.sum}"
        puts  "Mean  : #{array.sum / array.size}"
    end

    grid = Grid.new()
    env = Environment.new(grid)

    if griddy
        grid_test(grid)
    end
    
    puts "Input -> Expression -> Result -> Expected"
    for test in tests do
        tester(grid, env, test[:test], test[:expected])
    end
end

arith_tests = [
    {test: "5 + 4", expected: "9"},
    {test: "10 - 3", expected: "7"},
    {test: "4 * 3", expected: "12"},
    {test: "8 / 4", expected: "2"},
    {test: "4 ** 2", expected: "16"},
    {test: "7 % 3", expected: "1"}
]

logic_tests = [
    {test: "!true", expected: "false"},
    {test: "true && false", expected: "false"},
    {test: "true || false", expected: "true"},
    {test: "(true || false) && false", expected: "false"}
]

bitwise_tests = [
    {test: "~0", expected: "-1"},
    {test: "~0", expected: "-1"},
    {test: "8 & 4", expected: "0"},
    {test: "8 | 4", expected: "12"},
    {test: "11 ^ 3", expected: "8"},
    {test: "2 << 1", expected: "4"},
    {test: "8 >> 1", expected: "4"}
]

relational_tests = [
    {test: "5 > 4", expected: "true"},
    {test: "5 < 4", expected: "false"},
    {test: "5 >= 4", expected: "true"},
    {test: "5 <= 4", expected: "false"},
    {test: "5 >= 5", expected: "true"},
    {test: "5 <= 5", expected: "true"},
    {test: "5 != 4", expected: "true"}
]

cast_tests = [
    {test: "(5.0).to_i", expected: "5"},
    {test: "(1).to_f", expected: "1.0"}
]

grid_tests = [{test: "Max (0, 0) (0, 9)", expected: "check post"},
    {test: "Min (0, 0) (0, 9)", expected: "check post"},
    {test: "Sum (0, 0) (0, 9)", expected: "check post"},
    {test: "Mean (0, 0) (0, 9)", expected: "check post"}
]

fail_tests = [
    # {test: "(5", expected: "error"}
    # {test: "Max(0, 0)", expected: "error"}
    # {test: "Max(0 0)", expected: "error"}
    # {test: "5 > true", expected: "error"}
    # {test: "~1.0", expected: "error"}
]



puts "Arithmetic Tests"
test_runner(arith_tests, false)
puts "Logic Tests"
test_runner(logic_tests, false)
puts "Bitwise Tests"
test_runner(bitwise_tests, false)
puts "Relational Tests"
test_runner(relational_tests, false)
puts "Cast Tests"
test_runner(cast_tests, false)
puts "Statistic Tests"
test_runner(grid_tests, true)
# puts "Fail Tests"
# test_runner(fail_tests, true)
