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

# Like #find but instead of the element, returns the value returned by the block
def find_of(arr)
end

def part_2(input, max_search_coord)
  sensor_beacons = parse(input)
  sensors = sensor_beacons.keys.to_set
  beacons = sensor_beacons.values.to_set

  sensor_ranges = compute_sensor_ranges(sensor_beacons)

  # hypotheses:
  # 1. we can iterate through every point along the OUTSIDE OF THE edge of every sensor
  # 2a. if the point is touching or within the range of any other sensor, we have not located the beacon
  # 2b. if the point is not touching or within the range of any other sensor, we have located the beacon
  before = Time.monotonic
  result = sensor_ranges.each do |s, r|
    x, y = s
    outer = r + 1
    top_right = (x...(x + outer)).zip(((y + 1)..(y + outer)).reverse_each).to_a
    bot_right = ((x + 1)..(x + outer)).reverse_each.zip(((1 + y - outer)..y).reverse_each).to_a
    bot_left = ((1 + x - outer)..x).reverse_each.zip((y - outer)...y).to_a
    top_left = ((x - outer)...x).zip(y...(y + outer)).to_a

    #     if s == {8, 7}
    #       puts "s #{s} with r #{r} has
    # tr #{top_right}
    # br #{bot_right}
    # bl #{bot_left}
    # tl #{top_left}

    # "
    #     end

    edge_point_adjacent_to_answer = (top_right + bot_right + bot_left + top_left).find do |edge_point|
      # if s == {8, 7} && edge_point == {13, 11}
      #   sensor_ranges.reject(s).each do |s_1, r_1|
      #     dist = taxicab_dist(edge_point, s_1)
      #     p! s_1, r_1, dist, dist <= r_1
      #   end
      # end

      # in our search space and NOT within range of another sensor
      edge_point[0] >= 0 && edge_point[0] <= max_search_coord &&
        edge_point[1] >= 0 && edge_point[1] <= max_search_coord &&
        !sensor_ranges.reject(s).any? { |s_1, r_1| taxicab_dist(edge_point, s_1) <= r_1 }
    end

    break edge_point_adjacent_to_answer if edge_point_adjacent_to_answer
  end
  puts "my thing took #{Time.monotonic - before}"

  result = result.not_nil!

  puts "coord: #{result[0]}, #{result[1]}"
  (4000000i64 * result[0]) + result[1]
end

input = File.read("inputs/day-15.txt").strip

p! part_2(test, 20i64)
p! part_2(input, 4000000i64)
