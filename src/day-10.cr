test = "addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop"

def run(input : String, &block)
  cycle = 1
  x = 1
  input.each_line do |line|
    if line == "noop"
      yield 1, cycle, x
      cycle += 1
    elsif line.starts_with? "addx "
      yield 2, cycle, x
      x += line[5..].to_i
      cycle += 2
    end
  end

  yield 1, cycle, x
end

def part_1(input)
  sum = [] of Int32
  check = 20
  run(input) do |instr_cycles, cycle, x|
    if check >= cycle && check < cycle + instr_cycles
      sum << x * check
      check += 40
    end
  end

  sum.sum
end

def part_2(input)
  output = "\n"
  row = 1
  run(input) do |instr_cycles, _cycle, x|
    instr_cycles.times do
      output += row >= x && row <= x + 2 ? '#' : '.'
      if row == 40
        output += '\n'
        row = 1
      else
        row += 1
      end
    end
  end
  output
end

input = File.read("inputs/day-10.txt").strip

p! part_1(test)
p! part_1(input)

puts part_2(test)
puts part_2(input)
