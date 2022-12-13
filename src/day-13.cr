require "json"

test = "[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]"

# give nicer, more meaningful names to the output of <=>
INCORRECT =  1
UNKNOWN   =  0
CORRECT   = -1

def our_cmp(left : JSON::Any, right : JSON::Any)
  if left.as_i? && right.as_i?
    left.as_i <=> right.as_i
  elsif left.as_a? && right.as_a?
    left_a = left.as_a
    right_a = right.as_a
    left_a.zip?(right_a) do |l, r|
      return INCORRECT if r.nil? # right array has fewer items than l
      item_cmp = our_cmp(l, r)
      return item_cmp unless item_cmp == UNKNOWN
      # else continue checking
    end
    # if we get here, all elements are equal and right does not have fewer items
    # than left but we still need to see if left has fewer items
    left_a.size < right_a.size ? CORRECT : UNKNOWN
  else # only one is an array, need to convert & retry
    our_cmp(left.as_a? ? left : JSON::Any.new([left]), right.as_a? ? right : JSON::Any.new([right]))
  end
end

def parse(input)
  input.split("\n\n").map do |packet_pair|
    packet_1, packet_2 = packet_pair.split('\n')
    [JSON.parse(packet_1), JSON.parse(packet_2)]
  end
end

def part_1(input)
  packet_pairs = parse(input)
  packet_pairs.map_with_index { |pair, i| our_cmp(pair[0], pair[1]) == CORRECT ? i + 1 : nil }.compact.sum
end

def part_2(input)
  # ew
  divider_1 = JSON::Any.new([JSON::Any.new([JSON::Any.new(2i64)])])
  divider_2 = JSON::Any.new([JSON::Any.new([JSON::Any.new(6i64)])])

  results = parse(input).flatten.flatten.push(divider_1, divider_2).sort &->our_cmp(JSON::Any, JSON::Any)

  (1 + results.index!(divider_1)) * (1 + results.index!(divider_2))
end

input = File.read("inputs/day-13.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(input)
