test = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"

priorities = ('a'..'z').to_a + ('A'..'Z').to_a
total = 0
# test.lines.in_groups_of(3).each do |group|
File.read_lines("inputs/day-3.txt").in_groups_of(3).each do |group|
  common = group.select(String).map(&.chars.to_set).reduce { |acc, s| acc & s }
  total += 1 + priorities.index! common.first
end

puts total
