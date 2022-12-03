test = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"

priorities = ('a'..'z').to_a + ('A'..'Z').to_a
total = 0
File.each_line("inputs/day-3.txt") do |rucksack|
  # test.each_line do |rucksack|
  comp_1 = rucksack[..rucksack.size//2]
  comp_2 = rucksack[rucksack.size//2..]
  common = comp_1.chars & comp_2.chars
  # assume there's only one in common I guess?
  total += 1 + priorities.index! common[0]
end

puts total
