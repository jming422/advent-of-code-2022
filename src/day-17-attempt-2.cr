test = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

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

def comes_to_rest?(rows, shape, left_x, bot_y)
  return true if bot_y == 0         # rest if we hit bottom
  return false if rows.size < bot_y # fall if there's space between us and the existing rows
  case shape
  in .horizontal?
    rows[bot_y - 1] & (0b1111u8 << (3 - left_x)) != 0
  in .plus?
    # columns[left_x] == bot_y + 1 || columns[left_x + 1] == bot_y || columns[left_x + 2] == bot_y + 1
    rows[bot_y - 1] & (1u8 << (5 - left_x)) != 0 ||
      (rows.size > bot_y && rows[bot_y] & (0b111u8 << (4 - left_x)) != 0)
  in .l?
    rows[bot_y - 1] & (0b111u8 << (4 - left_x)) != 0
  in .vertical?
    rows[bot_y - 1] & (1u8 << (6 - left_x)) != 0
  in .square?
    rows[bot_y - 1] & (0b11u8 << (5 - left_x)) != 0
  end
end

def shape_would_overlap?(rows, shape, left_x, bot_y)
  case shape
  in .horizontal?
    shape_bits = 0b1111u8 << (3 - left_x)
    rows[bot_y]?.try { |row| row & shape_bits != 0 }
  in .plus?
    center_bit = 1u8 << (5 - left_x)
    rows[bot_y]?.try { |row| row & center_bit != 0 } ||
      rows[bot_y + 1]?.try { |row| row & (0b111u8 << (4 - left_x)) != 0 } ||
      rows[bot_y + 2]?.try { |row| row & center_bit != 0 }
  in .l?
    right_bit = 1u8 << (4 - left_x)
    rows[bot_y]?.try { |row| row & (0b111u8 << (4 - left_x)) != 0 } ||
      rows[bot_y + 1]?.try { |row| row & right_bit != 0 } ||
      rows[bot_y + 2]?.try { |row| row & right_bit != 0 }
  in .vertical?
    shape_bits = 1u8 << (6 - left_x)
    rows[bot_y..(bot_y + 3)]?.try &.any? { |row| row & shape_bits != 0 }
  in .square?
    shape_bits = 0b11u8 << (5 - left_x)
    rows[bot_y]?.try { |row| row & shape_bits != 0 } ||
      rows[bot_y + 1]?.try { |row| row & shape_bits != 0 }
  end
end

def draw_shape(rows, shape, left_x, bot_y)
  case shape
  in .horizontal?
    shape_bits = 0b1111u8 << (3 - left_x) # (7 - width - x) zeros to the right of four 1s
    if rows.size == bot_y
      rows.push shape_bits
    else
      rows[bot_y] |= shape_bits
    end
  in .plus?
    (bot_y + 3 - rows.size).clamp(0..).times { rows.push 0u8 }
    # would shift left 7-width=4 times when left_x=0, except we shift left one
    # additional time (4+1=5) since this number needs an addl 0 to line it up in
    # the middle beneath the row of 111 above it
    rows[bot_y] |= 1u8 << (5 - left_x)
    rows[bot_y + 1] |= 0b111u8 << (4 - left_x)
    rows[bot_y + 2] |= 1u8 << (5 - left_x)
  in .l?
    (bot_y + 3 - rows.size).clamp(0..).times { rows.push 0u8 }
    rows[bot_y] |= 0b111u8 << (4 - left_x)
    # these ones don't get shifted any differently from their longer counterpart
    # since they're all right-aligned
    rows[bot_y + 1] |= 1u8 << (4 - left_x)
    rows[bot_y + 2] |= 1u8 << (4 - left_x)
  in .vertical?
    shape_bits = 1u8 << (6 - left_x)
    4.times do |i|
      row = bot_y + i
      if row < rows.size
        rows[row] |= shape_bits
      else
        rows.push shape_bits
      end
    end
  in .square?
    shape_bits = 0b11u8 << (5 - left_x)
    2.times do |i|
      row = bot_y + i
      if row < rows.size
        rows[row] |= shape_bits
      else
        rows.push shape_bits
      end
    end
  end
end

def part_1(input, n = 2022)
  jets = input.chars.cycle
  # each row is a bitmask where ones are rocks
  rows = Array(UInt8).new

  n.times do |i|
    # p! i
    # puts rows.reverse.map(&.to_s(2).rjust(7, '0')).join('\n')
    # puts
    # break if i == 5
    shape = get_next_shape(i)
    left_x = 2
    bot_y = 3 + rows.size
    falling = false
    until falling && comes_to_rest?(rows, shape, left_x, bot_y)
      if falling
        bot_y -= 1
        falling = false
      else
        dir = jets.next
        new_x = (left_x + (dir == '<' ? -1 : 1)).clamp(0, 7 - shape_width(shape))
        left_x = new_x unless shape_would_overlap?(rows, shape, new_x, bot_y)
        falling = true
      end
    end

    # at rest, now update rows
    draw_shape(rows, shape, left_x, bot_y)
  end

  rows.size
end

def part_2(input)
  # TODO
end

input = File.read("inputs/day-17.txt").strip

p! part_1(test)
puts(Time.measure do
  p! part_1(input)
end)

puts(Time.measure { p! part_1(input, 1) })
puts
puts(Time.measure { p! part_1(input, 5) })
puts
puts(Time.measure { p! part_1(input, 10) })
puts
puts(Time.measure { p! part_1(input, 50) })
puts
puts(Time.measure { p! part_1(input, 100) })
puts
puts(Time.measure { p! part_1(input, 1000) })
puts
puts(Time.measure { p! part_1(input, 2000) })
puts
puts(Time.measure { p! part_1(input, 2022) })
puts
puts(Time.measure { p! part_1(input, 5000) })
puts
puts(Time.measure { p! part_1(input, 10000) })
puts
puts(Time.measure { p! part_1(input, 100000) })
puts
puts(Time.measure { p! part_1(input, 1_000_000) })
puts

# p! part_2(test)
# p! part_2(input)
