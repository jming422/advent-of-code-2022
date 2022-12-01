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

max_elf_calories = 0
elves.each do |inventory|
  calories = inventory.map(&.to_i).sum
  max_elf_calories = calories if calories > max_elf_calories
end

puts max_elf_calories
