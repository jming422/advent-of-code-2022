test = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3"

alias Point = Tuple(Int64, Int64)

def parse(input)
  sensors_to_beacons = Hash(Point, Point).new

  foo = input.lines.map do |line|
    sensor, beacon = line.scan(/x=([^,]+), y=([^:]+)/).map { |match| {match[1].to_i64, match[2].to_i64} }
    sensors_to_beacons[sensor] = beacon
  end

  sensors_to_beacons
end

def taxicab_dist(a : Point, b : Point)
  (a[0] - b[0]).abs + (a[1] - b[1]).abs
end

def compute_sensor_ranges(sensors_to_beacons)
  sensors_to_beacons.map { |k, v| {k, taxicab_dist(k, v)} }.to_h
end

def non_beacon_coords_in_row(sensor_ranges, sensors, beacons, row_y, exclude_other_beacons = true)
  non_beacon_coords = sensors.select { |_x, y| y == row_y }.to_set
  # puts "sensors in row #{non_beacon_coords}"
  sensor_ranges.each do |sensor, range|
    rows_away = taxicab_dist(sensor, {sensor[0], row_y})
    next if rows_away > range
    cells_to_either_side = range - rows_away
    x_coords = (sensor[0] - cells_to_either_side)..(sensor[0] + cells_to_either_side)
    x_coords.each { |x| non_beacon_coords << {x, row_y} }
  end
  # puts "sensor range in row #{non_beacon_coords}"
  beacons_in_row = beacons.select { |_x, y| y == row_y }.to_set
  # puts "beacons in row #{beacons_in_row}"
  if exclude_other_beacons
    non_beacon_coords - beacons_in_row
  else
    non_beacon_coords + beacons_in_row
  end
end

def part_1(input, row)
  sensor_beacons = parse(input)
  sensors = sensor_beacons.keys.to_set
  beacons = sensor_beacons.values.to_set
  sensor_ranges = compute_sensor_ranges(sensor_beacons)
  non_beacon_coords_in_row(sensor_ranges, sensors, beacons, row, true).size
end

def rank_rows(sensor_ranges, min_y, max_search_coord) : Array(Tuple(Int64, Set(Int64)))
  res = Hash(Int64, Set(Int64)).new
  (0i64..(max_search_coord - min_y)).each { |i| res[i] = Set(Int64).new }

  before = Time.monotonic
  sensor_ranges.each do |sensor, range|
    (Math.max(min_y, sensor[1] - range)..Math.min(max_search_coord, sensor[1] + range)).each do |row|
      cells_to_either_side = range - (row - sensor[1]).abs
      x_coords = Math.max(0i64, sensor[0] - cells_to_either_side)..Math.min(max_search_coord, sensor[0] + cells_to_either_side)
      x_coords.each { |x| res[row] << x }
    end
  end
  puts "ranking compute took #{Time.monotonic - before}"

  # sort from least sensor hits to most. we should try the rows with lowest
  # sensor-coverage first
  before = Time.monotonic
  out = res.to_a.unstable_sort_by!(&.[1].size)
  puts "ranking sort took #{Time.monotonic - before}"
  out
end

def part_2(input, max_search_coord)
  before = Time.monotonic
  sensor_beacons = parse(input)
  sensors = sensor_beacons.keys.to_set
  beacons = sensor_beacons.values.to_set
  puts "init took #{Time.monotonic - before}"

  before = Time.monotonic
  sensor_ranges = compute_sensor_ranges(sensor_beacons)
  puts "ranges took #{Time.monotonic - before}"

  search_space = (0i64..max_search_coord).to_set

  before = Time.monotonic
  row_ranking = rank_rows(sensor_ranges, 0i64, max_search_coord)
  puts "ranking took #{Time.monotonic - before}"

  before = Time.monotonic
  the_row, non_cols = row_ranking.find! { |_row, non_beacon_xs| non_beacon_xs.size < search_space.size }
  the_col = (search_space - non_cols).first
  puts "find took #{Time.monotonic - before}"

  puts "coord: #{the_col}, #{the_row}"
  (4000000i64 * the_col) + the_row
end

input = File.read("inputs/day-15.txt").strip

p! part_1(test, 10i64)
# p! part_1(input, 2000000i64)

p! part_2(test, 20i64)
p! part_2(input, 4000000i64)
