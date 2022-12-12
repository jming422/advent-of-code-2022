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

# https://en.wikipedia.org/wiki/Trial_division
def trial_division(n : UInt64)
  a = [] of UInt64
  while n % 2 == 0
    a << 2
    n //= 2
  end
  f = 3u64
  while f * f <= n
    if n % f == 0
      a << f
      n //= f
    else
      f += 2
    end
  end
  a << n if n != 1

  return a
end

def make_factorization(n : UInt64)
  h = Hash(UInt64, UInt64).new(0u64)
  trial_division(n).each do |f|
    h[f] += 1
  end
  h
end

def make_factorization(n : UInt64, max_factor : UInt64)
  h = Hash(UInt64, UInt64).new(0u64)
  trial_division(n).each do |f|
    h[f % max_factor] += 1
  end
  h
end

class MonkeyPrime
  def initialize(@items : Array(Hash(UInt64, UInt64)), @op : Tuple(String, String), @prime_divisor : UInt64, @true_idx : UInt64, @false_idx : UInt64, @inspects : UInt64)
  end

  getter inspects
  getter prime_divisor

  def add_item(new_item)
    @items.push(new_item)
  end

  def do_your_thing(monkeys : Array(MonkeyPrime), max_factor : UInt64)
    @items.select! do |item|
      @inspects += 1
      # puts "doing #{item} #{@op}"
      new_worry = if @op[0] == "*"
                    if @op[1] == "old"
                      item.transform_values! &.*(2)
                    else
                      trial_division(@op[1].to_u64).each do |f|
                        item[f % max_factor] = item.fetch(f % max_factor, 0u64) + 1u64
                      end
                    end
                    item
                  elsif @op[1] == "old"
                    item[2] = item.fetch(2, 0u64) + 1u64
                    item
                  else
                    # this is the hard one -- addition of an arbitrary number n = @op[1].to_u64
                    # to a number which we cannot realize in memory because it is too big
                    n_factors = make_factorization(@op[1].to_u64, max_factor)
                    common_factors = item.keys & n_factors.keys
                    common = Hash.zip(common_factors, common_factors.map { |f| Math.min(item[f % max_factor], n_factors[f % max_factor]) })
                    common.each do |k, v|
                      item[k] -= v
                      n_factors[k] -= v
                    end

                    # hopefully these reduced / refactored item & n are small enough to add!
                    reduced_item = item.reduce(1u64) { |acc, kv| acc * (kv[0] ** kv[1]) }
                    reduced_n = n_factors.reduce(1u64) { |acc, kv| acc * (kv[0] ** kv[1]) }
                    reduced = make_factorization(reduced_item + reduced_n, max_factor)

                    common.merge(reduced) { |_k, v1, v2| v1 + v2 }
                  end

      loc = new_worry.fetch(@prime_divisor, 0) > 0 ? @true_idx : @false_idx

      monkeys[loc].add_item(new_worry)
      false # we're removing all items from this array after processing them
    end
  end
end

def parse(input)
  input.split("\n\n").map do |monkey_str|
    lines = monkey_str.lines
    items = lines[1][18..].split(',').map(&.strip.to_u64).map { |i| make_factorization(i) }
    MonkeyPrime.new(
      items,
      lines[2][19..].partition(/[+*]/)[1..].map &.strip,
      lines[3][21..].to_u64,
      lines[4][29..].to_u64,
      lines[5][30..].to_u64,
      0
    )
  end
end

def part_2(input)
  monkeys = parse(input)
  max_factor = (monkeys.map &.prime_divisor).max
  20.times do
    monkeys.each &.do_your_thing(monkeys, max_factor)
  end
  p! monkeys.map &.inspects
  tired, monkey = monkeys.sort_by(&.inspects)[-2..]
  tired.inspects * monkey.inspects
end

# input = File.read("inputs/day-11.txt").strip

p! part_2(test)
# p! part_2(input)
