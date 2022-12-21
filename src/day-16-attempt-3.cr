test = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II"

foo = "
00 AA
00 FF
00 GG
00 II
02 CC 6th, 2 hops
03 EE 5th, 3 hops
13 BB 2nd, 2 hops
20 DD 1st, 1 hop
21 JJ 3rd, 3 hops
22 HH 4th, 7 hops
"

# optimal = ["D", "open",  ele1
#            "C", "B", "open", me2
#            "A", "I", "J", "open", me1
#            "I", "A", "D", "E", "F", "G", "H", "open", ele2
#            "G", "F", "E", "open", ele3
#            "D", "C", "open", me3
#            "idle"]

alias Node = NamedTuple(name: String, flow_rate: Int32, connects_to: Array(String))
alias Graph = Hash(String, Node) # this Hash's keys will be the same as their Node[:name]'s

def parse(input)
  graph = Graph.new
  input.each_line do |line|
    words = line.split
    name = words[1]
    flow_rate = words[4][5..].chomp(';').to_i
    connects_to = words[9..].map &.chomp(',')
    graph[name] = {name: name, flow_rate: flow_rate, connects_to: connects_to}
  end
  graph
end

def shortest_dist(graph : Graph, source : Node, dest : Node, visited : Set(String)) : Int32
  return 0 if source == dest
  return 1 if source[:connects_to].includes? dest[:name]
  distances_left = source[:connects_to].reject(visited).map do |next_source|
    new_visited = visited.dup
    new_visited << next_source
    shortest_dist(graph, graph[next_source], dest, new_visited)
  end
  distances_left.reject!(-1)
  return distances_left.empty? ? -1 : (1 + distances_left.min)
end

def compute_distances(graph) : Hash(String, Int32)
  # construct a Hash with one key for every node pair
  res = Hash(String, Int32).new
  graph.keys.each_combination(2, true) do |combo|
    key = combo.unstable_sort.join('|')
    res[key] = shortest_dist(graph, graph[combo[0]], graph[combo[1]], Set(String).new)
  end
  res
end

def distance_between(distances, someplace, someplace_else)
  return 0 if someplace == someplace_else
  ltr = someplace < someplace_else
  distances[ltr ? "#{someplace}|#{someplace_else}" : "#{someplace_else}|#{someplace}"]
end

def time_until_that_valve_opens(distances : Hash(String, Int32), current_name : String, valve_name : String)
  distance_between(distances, current_name, valve_name) + 1
end

def part_1_recursive(graph, distances, max_time, time_elapsed, pressure_released, current_flow, current_valve_name, unopened_valves, path_taken)
  # if time_elapsed exceeds max_time, then the current flow will be negative, that's what we want
  return {pressure_released + current_flow * (max_time - time_elapsed), path_taken} if time_elapsed >= max_time || unopened_valves.empty?
  score_step_pairs = unopened_valves.map do |unopened_valve_name|
    delay = time_until_that_valve_opens(distances, current_valve_name, unopened_valve_name)
    new_unopened_valves = unopened_valves.dup
    new_unopened_valves.delete(unopened_valve_name)
    new_path = path_taken.dup.push(unopened_valve_name)

    part_1_recursive(
      graph,
      distances,
      max_time,
      time_elapsed: time_elapsed + delay,
      pressure_released: delay * current_flow + pressure_released,
      current_flow: current_flow + graph[unopened_valve_name][:flow_rate],
      current_valve_name: unopened_valve_name,
      unopened_valves: new_unopened_valves,
      path_taken: new_path
    )
  end
  score_step_pairs.max_by &.[0]
end

def part_1(input)
  graph = parse(input)
  distances = nil
  dist_elapsed = Time.measure do
    distances = compute_distances(graph)
  end
  p! dist_elapsed

  useful_node_names = graph.select { |_k, v| v[:flow_rate] > 0 }.keys.to_set

  result = nil
  path_taken = nil
  elapsed = Time.measure do
    result, path_taken = part_1_recursive(
      graph,
      distances.not_nil!,
      max_time: 30,
      time_elapsed: 0,
      pressure_released: 0,
      current_flow: 0,
      current_valve_name: "AA",
      unopened_valves: useful_node_names,
      path_taken: [] of String
    )
    p! path_taken
  end
  p! elapsed

  {
    graph:      graph,
    distances:  distances.not_nil!,
    result:     result.not_nil!,
    path_taken: path_taken.not_nil!,
  }
end

def score_a_path(graph, distances, max_time, path_to_follow)
  time_elapsed = 0
  pressure_released = 0
  current_flow = 0
  last_location = "AA"
  while time_elapsed < max_time
    next_node = path_to_follow.shift?
    if next_node
      # go to next_node and open it, taking time:
      time_taken_to_open = time_until_that_valve_opens(distances, last_location, next_node)
      time_elapsed += time_taken_to_open
      pressure_released += current_flow * time_taken_to_open
      # node is open now
      current_flow += graph[next_node][:flow_rate]
      last_location = next_node
    else
      # no more nodes in path, just sit here and wait for the rest of the time
      pressure_released += current_flow * (max_time - time_elapsed)
      break
    end
  end

  return pressure_released
end

def best_loc(graph, distances, options, my_loc, my_time, other_loc, other_time)
  options.map { |loc| {loc, graph[loc][:flow_rate] + (distance_between(distances, other_loc, loc) + other_time) - (2*distance_between(distances, my_loc, loc) + my_time)} }.max_by? &.[1]
end

def compute_paths(graph, distances, one_person_path, max_time)
  options = graph.keys.to_set

  my_path = [] of String
  elephant_path = [] of String

  my_loc = elephant_loc = "AA"
  my_time = elephant_time = 0

  # until one_person_path.empty?
  #   next_loc = one_person_path.shift

  #   my_best = best_loc(graph, distances, one_person_path, my_loc, my_time, elephant_loc, elephant_time)
  #   elephant_best = best_loc(graph, distances, one_person_path, elephant_loc, elephant_time, my_loc, my_time)

  #   if !my_best || !elephant_best
  #     # reached end of list
  #     if distance_between(distances, my_loc, next_loc) < distance_between(distances, elephant_loc, next_loc)
  #       my_time += distance_between(distances, my_loc, next_loc) + 1
  #       my_loc = next_loc
  #       my_path << my_loc
  #       options.delete(my_loc)
  #     else
  #       elephant_time += distance_between(distances, elephant_loc, next_loc) + 1
  #       elephant_loc = next_loc
  #       elephant_path << elephant_loc
  #       options.delete(elephant_loc)
  #     end
  #     break
  #   end

  #   if next_loc != my_best[0] && next_loc != elephant_best[0]
  #     if my_best[1] < elephant_best[1]
  #       my_best = {next_loc, 0}
  #       one_person_path.delete(elephant_best[0])
  #     else
  #       elephant_best = {next_loc, 0}
  #       one_person_path.delete(my_best[0])
  #     end
  #   end

  #   my_time += distance_between(distances, my_loc, my_best[0]) + 1
  #   my_loc = my_best[0]
  #   my_path << my_loc
  #   options.delete(my_loc)
  #   elephant_time += distance_between(distances, elephant_loc, elephant_best[0]) + 1
  #   elephant_loc = elephant_best[0]
  #   elephant_path << elephant_loc
  #   options.delete(elephant_loc)
  # end

  loop do
    my_options = options.each.select { |opt| distance_between(distances, my_loc, opt) + 1 < max_time - my_time }
    my_best = (my_options.map do |loc|
      eleph_dist = distance_between(distances, elephant_loc, loc)
      eleph_weight = eleph_dist + 1 < max_time ? eleph_dist + elephant_time : 0
      score = graph[loc][:flow_rate] + eleph_weight - (2.5 * distance_between(distances, my_loc, loc) + my_time)
      {loc, score}
    end).max_by? &.[1]

    break if !my_best

    my_time += distance_between(distances, my_loc, my_best[0]) + 1
    my_loc = my_best[0]
    my_path << my_loc
    options.delete(my_loc)

    elephant_options = options.each.select { |opt| distance_between(distances, elephant_loc, opt) + 1 < max_time - elephant_time }
    elephant_best = (elephant_options.map do |loc|
      my_dist = distance_between(distances, my_loc, loc)
      my_weight = my_dist + 1 < max_time ? my_dist + my_time : 0
      score = graph[loc][:flow_rate] + my_weight - (2.5 * distance_between(distances, elephant_loc, loc) + elephant_time)
      {loc, score}
    end).max_by? &.[1]

    break if !elephant_best

    elephant_time += distance_between(distances, elephant_loc, elephant_best[0]) + 1
    elephant_loc = elephant_best[0]
    elephant_path << elephant_loc
    options.delete(elephant_loc)
  end

  {my_path, elephant_path}
end

def part_2(part_1_answer, max_time)
  graph = part_1_answer[:graph]
  distances = part_1_answer[:distances]
  one_person_path = part_1_answer[:path_taken]

  result = nil
  elapsed = Time.measure do
    my_path, elephant_path = compute_paths(graph, distances, one_person_path, max_time)
    p! my_path, elephant_path
    result = score_a_path(graph, distances, max_time, my_path) + score_a_path(graph, distances, max_time, elephant_path)
  end
  p! elapsed
  result
end

input = File.read("inputs/day-16.txt").strip

p1_test_ans = part_1(test)
p! p1_test_ans[:result]
p1_ans = part_1(input)
p! p1_ans[:result]

p! part_2(p1_test_ans, 26)
p! part_2(p1_ans, 26)
