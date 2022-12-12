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

def parse(input)
  input.split("\n\n").map do |monkey_str|
    lines = monkey_str.lines
    items = lines[1][18..].split(',').map(&.strip.to_u64)
    {
      items:     items,
      op:        lines[2][19..].partition(/[+*]/)[1..].map &.strip,
      divisor:   lines[3][21..].to_u64,
      true_idx:  lines[4][29..].to_u64,
      false_idx: lines[5][30..].to_u64,
    }
  end
end

def part_2(input)
  monkeys = parse(input)
  divisors = monkeys.map(&.[:divisor]).uniq

  modulo_monkeys = monkeys.map do |monkey|
    monkey.merge({
      items: monkey[:items].map do |num|
        h = Hash(UInt64, UInt64).new
        divisors.each { |div| h[div] = num % div }
        h
      end,
    })
  end

  monkey_inspections = Array(UInt64).new(modulo_monkeys.size, 0)
  10000.times do
    modulo_monkeys.each_with_index do |monkey, i|
      monkey[:items].select! do |item|
        monkey_inspections[i] += 1
        if monkey[:op][0] == "*"
          item.each do |k, v|
            n = monkey[:op][1] == "old" ? v : monkey[:op][1].to_u64
            item[k] = (v * n) % k
          end
        else
          item.each do |k, v|
            n = monkey[:op][1] == "old" ? v : monkey[:op][1].to_u64
            item[k] = (v + n) % k
          end
        end

        loc = item[monkey[:divisor]] == 0 ? monkey[:true_idx] : monkey[:false_idx]
        modulo_monkeys[loc][:items].push(item)

        false
      end
    end
  end
  p! monkey_inspections
  tiredest_monkeys = monkey_inspections.sort[-2..]
  p! tiredest_monkeys
  tiredest_monkeys.product
end

input = File.read("inputs/day-11.txt").strip

p! part_2(test)
p! part_2(input)
