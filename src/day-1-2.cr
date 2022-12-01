# input = "1000
# 2000
# 3000

# 4000

# 5000
# 6000

# 7000
# 8000
# 9000

# 10000
# "
input = File.read("inputs/day-1.txt")

elves = input.strip.split("\n\n").map &.split('\n')

max_elves = [0, 0, 0]
elves.each do |inventory|
  calories = inventory.map(&.to_i).sum
  max_elves = max_elves.push(calories).unstable_sort![1..]
end

puts max_elves.sum
