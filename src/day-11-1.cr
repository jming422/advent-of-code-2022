test = "Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1"

class Monkey
  def initialize(@items : Array(Int64), @op : Proc(Int64, Int64), @test : Proc(Int64, Bool), @true_idx : Int64, @false_idx : Int64, @inspects : Int64)
  end

  getter inspects

  def add_item(new_item : Int64)
    @items.push(new_item)
  end

  def do_your_thing(monkeys : Array(Monkey))
    @items.select! do |item|
      @inspects += 1
      new_worry = @op.call(item) // 3
      loc = @test.call(new_worry) ? @true_idx : @false_idx
      monkeys[loc].add_item(new_worry)
      false # we're removing all items from this array after processing them
    end
  end
end

def parse(input) : Array(Monkey)
  input.split("\n\n").map do |monkey_str|
    lines = monkey_str.lines
    items = lines[1][18..].split(',').map &.to_i64
    # ops are binary and one of either + or *
    operand_1, operator, operand_2 = lines[2][19..].partition(/\s*[+*]\s*/)
    op = Proc(Int64, Int64).new do |old|
      op1 = operand_1 == "old" ? old : operand_1.to_i64
      op2 = operand_2 == "old" ? old : operand_2.to_i64
      operator.includes?('*') ? op1 * op2 : op1 + op2
    end
    divisor = lines[3][21..].to_i64
    test = Proc(Int64, Bool).new { |val| (val % divisor) == 0 }
    true_idx = lines[4][29..].to_i64
    false_idx = lines[5][30..].to_i64

    Monkey.new(items, op, test, true_idx, false_idx, 0)
  end
end

def part_1(input)
  monkeys = parse(input)
  20.times do
    monkeys.each &.do_your_thing(monkeys)
  end
  tired, monkey = monkeys.sort_by(&.inspects)[-2..]
  tired.inspects * monkey.inspects
end

# def part_2(input)
#   monkeys = parse(input)
#   20.times do
#     monkeys.each &.do_your_thing_2(monkeys)
#   end
#   tired, monkey = monkeys.sort_by(&.inspects)[-2..]
#   tired.inspects * monkey.inspects
# end

input = File.read("inputs/day-11.txt").strip

p! part_1(test)
p! part_1(input)

# puts part_2(test)
# puts part_2(input)
