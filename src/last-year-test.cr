# input = "3,4,3,1,2"
input = File.read("inputs/last-year-test.txt")

fishes = input.split(',').map &.to_i

states = [0_u64] * (Math.max(fishes.max, 8) + 1)

fishes.each do |fish|
  states[fish] += 1
end

(1..256).each do
  zeroes = states[0]
  (1...states.size).each do |i|
    states[i - 1] = states[i]
  end
  states[-1] = 0
  states[6] += zeroes
  states[8] += zeroes
end

puts states.sum
