test = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"

# Given a NEW head and OLD tail pos, return the new tail pos if the head moved up
def up(head_pos, tail_pos)
  if head_pos[1] <= tail_pos[1] + 1
    # if before the move they were horizontally adjacent, overlapping, or if the
    # head was beneath the tail, moving up does not move the tail
    tail_pos
  else
    # in all other cases the tail moves to where the head used to be
    {head_pos[0], head_pos[1] - 1}
  end
end

# Given a NEW head and tail pos, return the new tail pos if the head moved right
def right(head_pos, tail_pos)
  if head_pos[0] <= tail_pos[0] + 1
    # if before the move they were vertically adjacent, overlapping, or if the
    # head was left of the tail, moving up does not move the tail
    tail_pos
  else
    # in all other cases the tail moves to where the head used to be
    {head_pos[0] - 1, head_pos[1]}
  end
end

# You get the idea
def down(head_pos, tail_pos)
  if head_pos[1] >= tail_pos[1] - 1
    tail_pos
  else
    {head_pos[0], head_pos[1] + 1}
  end
end

def left(head_pos, tail_pos)
  if head_pos[0] >= tail_pos[0] - 1
    tail_pos
  else
    {head_pos[0] + 1, head_pos[1]}
  end
end

def part_1(input)
  head_pos = tail_pos = {0, 0}
  visited = Set{tail_pos}
  input.each_line do |line|
    dir, count = line.split(' ')
    count.to_i.times do
      case dir
      when "U"
        head_pos = {head_pos[0], head_pos[1] + 1}
        tail_pos = up(head_pos, tail_pos)
      when "R"
        head_pos = {head_pos[0] + 1, head_pos[1]}
        tail_pos = right(head_pos, tail_pos)
      when "D"
        head_pos = {head_pos[0], head_pos[1] - 1}
        tail_pos = down(head_pos, tail_pos)
      when "L"
        head_pos = {head_pos[0] - 1, head_pos[1]}
        tail_pos = left(head_pos, tail_pos)
      end
      visited.add(tail_pos)
    end
  end
  visited.size
end

input = File.read("inputs/day-9.txt").strip

p! part_1(test)
p! part_1(input)
