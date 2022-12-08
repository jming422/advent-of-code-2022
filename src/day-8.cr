test = "30373
25512
65332
33549
35390"

part_1_expt = [{1, 1}, {1, 2}, {2, 1}, {2, 3}, {3, 2}].to_set

def line_visible(is_row, idx, line_of_trees) : Set(Tuple(Int32, Int32))
  tallest_left = line_of_trees[0]
  visible = Set(Tuple(Int32, Int32)).new
  line_of_trees[1...-1].map_with_index do |tree, iter_idx|
    real_iter_idx = iter_idx + 1
    if tree > tallest_left
      tallest_left = tree
      visible.add(is_row ? {idx, real_iter_idx} : {real_iter_idx, idx})
    elsif tree > line_of_trees[(real_iter_idx + 1)..].max
      visible.add(is_row ? {idx, real_iter_idx} : {real_iter_idx, idx})
    end
  end

  visible
end

def scenic_count(tree_height, others)
  count = 0
  others.each do |other_tree|
    count += 1
    break unless other_tree < tree_height
  end
  count
end

def scenic_score(grid : Array(Array(Int32)), row : Int32, col : Int32)
  tree = grid[row][col]
  top = scenic_count(tree, grid[...row].reverse.map &.[col])
  right = scenic_count(tree, grid[row][(col + 1)..])
  bottom = scenic_count(tree, grid[(row + 1)..].map &.[col])
  left = scenic_count(tree, grid[row][...col].reverse)
  top * right * bottom * left
end

def parse_grid(s) : Array(Array(Int32))
  s.lines.map &.chars.map &.to_i
end

def part_1(input)
  grid = parse_grid(input)
  horiz_visible = grid[1...-1].map_with_index { |row, i| line_visible(true, i + 1, row) }
  vert_visible = grid.transpose[1...-1].map_with_index { |col, i| line_visible(false, i + 1, col) }
  visible_trees = (horiz_visible + vert_visible).reduce { |acc, x| acc | x }
  visible_trees.size + (grid.size * 2) + (grid[0].size * 2) - 4
end

def part_2(input)
  grid = parse_grid(input)
  # this is very brute force but whatever, maybe I'll try to think of something fancier later
  tree_scores = grid.map_with_index { |row, row_i| (0...row.size).map { |col_i| scenic_score(grid, row_i, col_i) } }
  tree_scores.flatten.max
end

input = File.read("inputs/day-8.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(input)
