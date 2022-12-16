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

def part_2(input, max_search_coord)
  sensor_beacons = parse(input)
  sensors = sensor_beacons.keys.to_set
  beacons = sensor_beacons.values.to_set

  sensor_ranges = compute_sensor_ranges(sensor_beacons)

  # hypothesis: for every useless sensor s with position (x, y) and range r,
  # there exist overlapping groups of sensors s_i with ranges r_i such that
  # taxicab_dist(s, s_i) <= r + r_i and that:
  #  - s_1's have x_1 >= x and y_1 >= y, unless x >= max_search_coord and y >=
  #    max_search_coord, in which case no s_1 exists
  #  - s_2's have x_2 >= x and y_2 <= y, unless x >= max_search_coord and y <=
  #    0, in which case no s_2 exists
  #  - s_3's have x_3 <= x and y_3 >= y, unless x <= 0 and y >= max_search_coord,
  #    in which case no s_3 exists
  #  - s_4's have x_4 <= x and y_4 <= y, unless x <= 0 and y <= 0, in which case
  #    no s_4 exists
  # and that for each group s_i which exists, the group must overlap the whole
  # side of s's range facing it. don't know how to formalize that one yet.
  #
  # the amount that an s_1 overlaps s's top-right edge will be:
  # 1234567
  # 8     @
  # 7    @@@ s_1 is at 6,7 with r_1 = 1
  # 6   %%@
  # 5  %%%%%
  # 4 %%%%%%% s is at 5,4 with r = 3
  # 3  %%%%%
  # 2   %%%
  # 1    %
  #
  #  s's vertices are: (x, y+r), (x+r, y), (x, y-r), (x-r, y)
  #                    (5, 7), (8, 4), (5, 1), (2, 4)
  #  s_1's are: (6, 8), (7, 7), (6, 6), (5, 7)
  #
  #  for top-right,
  #  take the vertex of s_1 which has the closest to s by taxicab, breaking ties by closest y.
  #  this is either (5, 7) or (6, 6), each with d = 3, so break the tie and pick (6, 6)
  #  so we now have (6, 6) from s_1.
  #  now take the vertex of s which is closest to s_1, also breaking ties with y.
  #  this is (5, 7), which is only 1 away.
  #
  #  NOW! For s, do x-y: 7 - 5 = 2
  #     For s_1, do x-y: 6 - 6 = 0
  #                              and 2 + 0 is our overlap
  #
  #  s_1 overlaps s by 2. s's edges are 4 long. s_1's edges are 2 long.
  #
  # overlap = 2
  # taxi, (r-r1) = 4, 2
  #
  # 12345678
  # 0     @
  # 9    @@@
  # 8   @@@@@
  # 7    @@@ s_1 is at 6,8 with r_1 = 2, edges 3 long
  # 6   %%@  if it were at 7,7 though, it would overlap by 3
  # 5  %%%%%
  # 4 %%%%%%% s is at 5,4 with r = 3, edges 4 long
  # 3  %%%%%
  # 2   %%%
  # 1    %
  #
  # at 6,8, overlap is 2, at 7,7 it is 3
  #
  # s_1 = (6, 8) with r_1 = 2, has vertices: (6, 10), (8, 8), (6, 6), (4, 8)
  # s here has vertices (5, 7), (8, 4), (5, 1), (2, 4)
  #
  # closest s_1 vertex to s is (6, 6)
  # closest s vertex to s_1 is (5, 7)
  # abs(6 - 6) + abs(5 - 7) = 2
  #
  #
  #       $
  #      $$$
  #     $$$$$
  #    $$$$$$$ M
  #   $$$$$$$$BMM
  #  $$$$$x$$BBXMM        an x with r = 5 has edges 6 long
  #   $$$$$$$$BMM         this m overlaps by 2 on each edge, has r = 2, and is on the edge
  #    $$$$$$$ M
  #     $$$$$
  #      $$$
  #       $
  #
  #  s = (0, 0), r=5
  #  s_1 = (5, 0), r_1=2
  #
  # closest s vertex is (5, 0)
  # cloesest s_1 is (3, 0)
  #
  # corollary: at least 4 sensors in sensor_ranges will fail to meet this
  # hypothesis. these sensors will all be adjacent to the uncovered point.
  before = Time.monotonic
  # can I verify this hypothesis?
  sensor_ranges.each do |s, r|
    x, y = s
    others = Array(Hash(Point, Int64) | Nil).new(4, nil)

    if x >= max_search_coord && y >= max_search_coord
      others[0] = nil
    else
      others[0] = sensor_ranges.select do |s_1, r_1|
        x_1, y_1 = s_1
        taxicab_dist(s, s_1) <= r + r_1 && x_1 >= x && y_1 >= y
      end
    end

    if x >= max_search_coord && y <= 0
      others[1] = nil
    else
      others[1] = sensor_ranges.select do |s_2, r_2|
        x_2, y_2 = s_2
        taxicab_dist(s, s_2) <= r + r_2 && x_2 >= x && y_2 <= y
      end
    end

    if x <= 0 && y >= max_search_coord
      others[2] = nil
    else
      others[2] = sensor_ranges.select do |s_3, r_3|
        x_3, y_3 = s_3
        taxicab_dist(s, s_3) <= r + r_3 && x_3 <= x && y_3 >= y
      end
    end

    if x <= 0 && y <= 0
      others[3] = nil
    else
      others[3] = sensor_ranges.select do |s_4, r_4|
        x_4, y_4 = s_4
        taxicab_dist(s, s_4) <= r + r_4 && x_4 <= x && y_4 <= y
      end
    end
  end
  puts "my thing took #{Time.monotonic - before}"

  # puts "coord: #{the_col}, #{the_row}"
  # (4000000i64 * the_col) + the_row
end

input = File.read("inputs/day-15.txt").strip

p! part_2(test, 20i64)
# p! part_2(input, 4000000i64)
# p! part_2(input, 4000000i64)
