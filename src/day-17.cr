test = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

shape_order = "####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##"

enum Shape
  Horizontal
  Plus
  L
  Vertical
  Square
end

def get_next_shape(idx)
  case idx % 5
  when 0 then Shape::Horizontal
  when 1 then Shape::Plus
  when 2 then Shape::L
  when 3 then Shape::Vertical
  when 4 then Shape::Square
  else        raise "impossible"
  end
end

def shape_width(shape)
  case shape
  in .horizontal? then 4
  in .plus?       then 3
  in .l?          then 3
  in .vertical?   then 1
  in .square?     then 2
  end
end

def comes_to_rest?(columns, shape, left_x, bot_y)
  return true if bot_y == 0
  case shape
  in .horizontal?
    columns[left_x..(left_x + 3)].any? &.==(bot_y)
  in .plus?
    columns[left_x] == bot_y + 1 || columns[left_x + 1] == bot_y || columns[left_x + 2] == bot_y + 1
  in .l?
    columns[left_x..(left_x + 2)].any? &.==(bot_y)
  in .vertical?
    columns[left_x] == bot_y
  in .square?
    columns[left_x..(left_x + 1)].any? &.==(bot_y)
  end
end

def shape_would_overlap?(columns, shape, left_x, bot_y)
  case shape
  in .horizontal?
    columns[left_x..(left_x + 3)].any? &.>=(bot_y)
  in .plus?
    columns[left_x] > bot_y + 1 || columns[left_x + 1] > bot_y || columns[left_x + 2] > bot_y + 1
    # OH f**k this isn't gonna work unless I save the actual shapes instead of
    # full columns, because they could interleave the shapes using jets. Dammit
    # now I have to make another attempt... probably gonna try a bitmask or
    # something stupid like that.
  in .l?
    columns[left_x..(left_x + 2)].any? &.==(bot_y)
  in .vertical?
    columns[left_x] == bot_y
  in .square?
    columns[left_x..(left_x + 1)].any? &.==(bot_y)
  end
end

def part_1(input, width = 7)
  jets = input.chars.cycle
  # each column contains its tallest height where a rock has come to rest in it
  columns = Array(Int32).new(width, 0)

  2022.times do |i|
    puts columns
    break if i == 5
    shape = get_next_shape(i)
    left_x = 2
    bot_y = 3 + columns.max
    falling = false
    until falling && comes_to_rest?(columns, shape, left_x, bot_y)
      if falling
        bot_y -= 1
        falling = false
      else
        dir = jets.next
        new_x = (left_x + (dir == '<' ? -1 : 1)).clamp(0, columns.size - shape_width(shape))
        left_x = new_x unless shape_would_overlap?(columns, shape, new_x, bot_y)
        falling = true
      end
    end

    # at rest, now update columns
    case shape
    in .horizontal?
      (left_x..(left_x + 3)).each { |x| columns[x] = bot_y + 1 }
    in .plus?
      columns[left_x] = bot_y + 2
      columns[left_x + 1] = bot_y + 3
      columns[left_x + 2] = bot_y + 2
    in .l?
      columns[left_x] = bot_y + 1
      columns[left_x + 1] = bot_y + 1
      columns[left_x + 2] = bot_y + 3
    in .vertical?
      columns[left_x] = bot_y + 4
    in .square?
      columns[left_x] = bot_y + 2
      columns[left_x + 1] = bot_y + 2
    end
  end

  columns.max
end

def part_2(input)
  # TODO
end

input = File.read("inputs/day-17.txt").strip

p! part_1(test)
# p! part_1(input)
# p! part_2(test)
# p! part_2(input)
