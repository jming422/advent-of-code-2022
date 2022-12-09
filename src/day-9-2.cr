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

def move_both(dir, old_head, old_tail)
  head = move_head(dir, old_head)
  tail = move_tail(head, old_tail)
  {head, tail}
end

def part_1(input)
  head_pos = tail_pos = {0, 0}
  visited = Set{tail_pos}
  input.each_line do |line|
    dir, count = line.split(' ')
    count.to_i.times do
      head_pos, tail_pos = move_both(dir, head_pos, tail_pos)
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
      # debugger
      new_rope = [move_head(dir, rope[0])]
      i = 0
      rope[1..].each do |old_tail|
        new_head = new_rope[i]
        new_tail = move_tail(new_head, old_tail)
        new_rope.push(new_tail)
        i += 1
      end
      rope = new_rope
      visited.add(rope[9])
    end
  end
  # p! visited
  visited.size
end

input = File.read("inputs/day-9.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(test_2)
p! part_2(input)
