test = "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"

subset_pairs = 0
# test.lines.map(&.split(",")).each do |pair|
File.read_lines("inputs/day-4.txt").map(&.split(",")).each do |pair|
  elf1, elf2 = pair.map do |elf|
    first, last = elf.split("-").map(&.to_i)
    Range.new(first, last).to_set
  end
  subset_pairs += 1 if elf1.subset_of?(elf2) || elf2.subset_of?(elf1)
end

puts subset_pairs
