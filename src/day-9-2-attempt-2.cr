test = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"

test_2 = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"

alias Point = Tuple(Int32, Int32)

def move_head(dir, old_head)
  case dir
  when "U" then {old_head[0], old_head[1] + 1}
  when "R" then {old_head[0] + 1, old_head[1]}
  when "D" then {old_head[0], old_head[1] - 1}
  when "L" then {old_head[0] - 1, old_head[1]}
  else          raise "you suck"
  end
end

def move_tail(head, old_tail)
  touching = (head[0] - old_tail[0]).abs <= 1 && (head[1] - old_tail[1]).abs <= 1

  dx, dy = if touching
             {0, 0}
           elsif head[1] - old_tail[1] == 0 # same Y coord (in the same row)
             {head[0] > old_tail[0] ? 1 : -1, 0}
           elsif head[0] - old_tail[0] == 0 # same X coord (in the same col)
             {0, head[1] > old_tail[1] ? 1 : -1}
           else
             {head[0] > old_tail[0] ? 1 : -1, head[1] > old_tail[1] ? 1 : -1}
           end

  {old_tail[0] + dx, old_tail[1] + dy}
end

def part_1(input)
  head_pos = tail_pos = {0, 0}
  visited = Set{tail_pos}
  input.each_line do |line|
    dir, count = line.split(' ')
    count.to_i.times do
      head_pos = move_head(dir, head_pos)
      tail_pos = move_tail(head_pos, tail_pos)
      visited.add(tail_pos)
    end
  end
  visited.size
end

def part_2(input)
  # rope[0] is the head, rope[9] is the tail
  rope = [{0, 0}]*10
  visited = Set{rope[9]}
  input.each_line do |line|
    dir, count = line.split(' ')
    count.to_i.times do
      # the accumulate function is wild; somehow very difficult for my brain to
      # follow. but basically what it does is like a fusion of map and reduce.
      # It takes an accumulator (in this case initialized to our new head),
      # _yields the accumulator into the output array_, and then performs your
      # binary operation on the accumulator and the next element in the array to
      # determine the new accumulator. For example:
      #   [3,4,5].accumulate(2) { |x, y| x * y }
      # Returns the array [2, 6, 24, 120], which is: [2, 2*3, 2*3*4, 2*3*4*5]
      rope = rope[1..].accumulate(move_head(dir, rope[0]), &->move_tail(Point, Point))
      visited.add(rope[9])
    end
  end
  visited.size
end

input = File.read("inputs/day-9.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(test_2)
p! part_2(input)
