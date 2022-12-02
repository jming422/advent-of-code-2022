test = "A Y
B X
C Z"

def our_shape_score(them : Char, instr : Char)
  ((them.ord + instr.ord - 1) % 3) + 1
end

def instruction_score(instr : Char)
  (instr.ord - 88) * 3
end

total_score = 0
File.each_line("inputs/day-2.txt") do |round|
  # test.each_line do |round|
  them, _, instruction = round.chars

  total_score += our_shape_score(them, instruction) + instruction_score(instruction)
end

puts total_score
