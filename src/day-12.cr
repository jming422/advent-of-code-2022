test = "Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi"

# https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
def dj_dijkstra_in_the_house(heightmap, source, target)
  return 0 if source == target

  dist = Array.new(heightmap.size) { |_| Array.new(heightmap[0].size, Int64::MAX) }
  prev = Array(Array(Tuple(Int64, Int64) | Nil)).new(heightmap.size) { |_| Array(Tuple(Int64, Int64) | Nil).new(heightmap[0].size, nil) }
  unvisited = (
    Range.new(0i64, heightmap.size.to_i64, true).flat_map do |row|
      Range.new(0i64, heightmap[0].size.to_i64, true).map { |col| {row, col} }
    end
  ).to_set

  dist[source[0]][source[1]] = 0i64

  until unvisited.empty?
    next_to_visit = unvisited.min_by { |v| dist.dig(*v) }
    break if next_to_visit == target
    unvisited.delete(next_to_visit)

    elevation = heightmap.dig(*next_to_visit)
    row, col = next_to_visit

    neighbors = [
      {row - 1, col},
      {row, col + 1},
      {row + 1, col},
      {row, col - 1},
    ].select { |loc| unvisited.includes?(loc) && heightmap.dig?(*loc).try &.<=(elevation + 1) }

    current_dist = dist.dig(*next_to_visit)
    # this might happen if the target is unreachable from this position given
    # our elevation climbing rules
    return Int64::MAX if current_dist == Int64::MAX

    neighbors.each do |neighbor|
      alt = current_dist + 1
      if alt < dist.dig(*neighbor)
        dist[neighbor[0]][neighbor[1]] = alt
        prev[neighbor[0]][neighbor[1]] = next_to_visit
      end
    end
  end

  return Int64::MAX if prev.dig?(*target).nil?

  shortest_path = [] of Tuple(Int64, Int64)
  u = target
  while u
    shortest_path.push(u)
    u = prev.dig?(*u)
  end

  shortest_path.size - 1 # sub 1 since the puzzle doesn't count the source as a step
end

def parse(input)
  lines = input.lines
  source = lines.each_with_index do |line, i|
    maybe = line.index('S')
    break {i.to_i64, maybe.to_i64} if maybe
  end

  target = lines.each_with_index do |line, i|
    maybe = line.index('E')
    break {i.to_i64, maybe.to_i64} if maybe
  end

  {
    input.sub('S', 'a').sub('E', 'z').lines.map &.chars,
    source.not_nil!,
    target.not_nil!,
  }
end

def part_1(input)
  parsed = parse(input)
  dj_dijkstra_in_the_house(*parsed)
end

def part_2(input)
  heightmap, _, target = parse(input)

  sources = [] of Tuple(Int64, Int64)
  heightmap.each_with_index do |row_arr, row|
    row_arr.each_with_index do |col_val, col|
      sources.push({row.to_i64, col.to_i64}) if col_val == 'a'
    end
  end

  sources.min_of { |source| dj_dijkstra_in_the_house(heightmap, source, target) }
end

input = File.read("inputs/day-12.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test)
p! part_2(input)
