test = "    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"

total = 0
# layout, moves = test.split("\n\n").map &.lines
layout, moves = File.read("inputs/day-5.txt").split("\n\n").map &.lines
num_stacks = layout[-1].split.size
# giving the new string array initial capacity of layout.size is not necessary
# but I thought it'd be nice
stacks = Array.new(num_stacks) { |_| Array(String).new(layout.size) }

# p! layout, moves, num_stacks

# initialize stacks' layout
layout[...-1].each do |line|
  stacks.each_index do |i|
    # I guess assume each crate is 3 chars wide for now
    layout_start = i*4
    stack_i_layout = line[layout_start..layout_start + 2]?
    stacks[i].unshift(stack_i_layout) if stack_i_layout && !stack_i_layout.blank?
  end
end

puts "Stacks (before):"
stacks.each do |stack|
  puts stack
end

# perform moves
moves.each do |move|
  count, from, to = move.scan(/\d+/).map &.[0].to_i
  (1..count).each do
    stacks[to - 1].push(stacks[from - 1].pop)
  end
end

puts "Stacks (after):"
stacks.each do |stack|
  puts stack
end

part_1 = stacks.map(&.last.strip("[]")).join
p! part_1
