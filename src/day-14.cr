test = "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9"

enum Cell
  Air
  Rock
  Sand
end

def parse(input)
  input.lines.map do |line|
    line.split(" -> ").map do |point|
      x, y = point.split(',').map &.to_i
      {x, y}
    end
  end
end

def make_grid(all_lines)
  points = all_lines.flatten
  min_x, max_x = points.map(&.[0]).minmax
  max_y = points.map(&.[1]).max

  # seems like they might not be using the first 500 cols... at least not in the
  # test data
  num_cols = 1 + max_x - min_x

  grid = Array.new(1 + max_y) { |_i| Array.new(num_cols, Cell::Air) }
  adjusted_lines = all_lines.map &.map { |x, y| {x - min_x, y} }

  {grid, adjusted_lines, min_x}
end

def draw_rocks(grid, lines)
  lines.each do |line|
    line.each_cons_pair do |from, to|
      vertical = from[0] == to[0]
      idx = vertical ? 1 : 0
      rng = from[idx] > to[idx] ? to[idx]..from[idx] : from[idx]..to[idx]
      rng.each do |i|
        if vertical
          grid[i][from[0]] = Cell::Rock
        else
          grid[from[1]][i] = Cell::Rock
        end
      end
    end
  end

  grid
end

# Returns true if the sand comes to rest, false if the sand pours into the void
def pour_sand_from(grid, init_row, init_col)
  row = init_row
  col = init_col
  loop do
    next_row = grid[row]?
    return :void if next_row.nil? || next_row[col]?.nil?

    if next_row[col] == Cell::Air
      row += 1
      next
    elsif next_row[col - 1]?.nil?
      return :void
    elsif next_row[col - 1] == Cell::Air
      row += 1
      col -= 1
      next
    elsif next_row[col + 1]?.nil?
      return :void
    elsif next_row[col + 1] == Cell::Air
      row += 1
      col += 1
      next
    else
      # if we've stopped up the source, return false
      return :stopped if row - 1 == init_row && col == init_col
      # otherwise the sand comes to rest
      grid[row - 1][col] = Cell::Sand
      return :rested
    end
  end
end

def make_grid_2(all_lines)
  points = all_lines.flatten
  max_x = points.map(&.[0]).max
  max_y = points.map(&.[1]).max + 2

  # not sure how big this is gonna get, but this should be big enough
  num_cols = max_x * 2

  grid = Array.new(1 + max_y) { |i| Array.new(num_cols, i == max_y ? Cell::Rock : Cell::Air) }

  # no more adjusting x's down, we're gonna keep all that space now
  {grid, all_lines}
end

def part_1(input)
  lines = parse(input)
  grid, lines, col_offset = make_grid(lines)
  grid = draw_rocks(grid, lines)

  count = 0
  while pour_sand_from(grid, 0, 500 - col_offset) == :rested
    count += 1
  end

  count
end

def part_2(input)
  lines = parse(input)
  grid, lines = make_grid_2(lines)
  grid = draw_rocks(grid, lines)

  count = 0
  last = pour_sand_from(grid, 0, 500)
  while last == :rested
    count += 1
    last = pour_sand_from(grid, 0, 500)
  end
  count += 1 if last == :stopped

  count
end

input = File.read("inputs/day-14.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(input)
