test = "A Y
B X
C Z"

def shape_score(shape : Char)
  shape.ord - 87
end

def win_score(them : Char, us : Char)
  (((us - them) + 2) % 3) * 3
end

total_score = 0
File.each_line("inputs/day-2.txt") do |round|
# test.each_line do |round|
  them, _, us = round.chars
  total_score += shape_score(us) + win_score(them, us)
end

puts total_score
