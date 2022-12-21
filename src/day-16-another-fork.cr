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

"
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

# optimal = ["D", "open",
#            "C", "B", "open",
#            "A", "I", "J", "open",
#            "I", "A", "D", "E", "F", "G", "H", "open",
#            "G", "F", "E", "open",
#            "D", "C", "open",
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
    shortest_dist(graph, graph[next_source], dest, visited + Set{next_source})
  end
  distances_left.reject!(-1)
  return distances_left.empty? ? -1 : (1 + distances_left.min)
end

def compute_distances(graph) : Hash(String, Hash(String, Int32))
  # construct a Hash with one key for every node
  graph.transform_values do |node|
    # where each value is another Hash of every node => the distance to that node
    graph.transform_values { |other_node| shortest_dist(graph, node, other_node, Set(String).new) }
  end
end

def time_until_that_valve_opens(distances : Hash(String, Hash(String, Int32)), current_name : String, valve_name : String)
  distances[current_name][valve_name] + 1
end

def part_1_recursive(graph, distances, max_time, time_elapsed, pressure_released, current_flow, current_valve_name, unopened_valves, path_taken)
  # if time_elapsed exceeds max_time, then the current flow will be negative, that's what we want
  return pressure_released + current_flow * (max_time - time_elapsed) if time_elapsed >= max_time || unopened_valves.empty?
  return unopened_valves.max_of do |unopened_valve_name|
    delay = time_until_that_valve_opens(distances, current_valve_name, unopened_valve_name)
    new_unopened_valves = unopened_valves.dup
    new_unopened_valves.delete(unopened_valve_name)

    part_1_recursive(
      graph,
      distances,
      max_time,
      time_elapsed: time_elapsed + delay,
      pressure_released: delay * current_flow + pressure_released,
      current_flow: current_flow + graph[unopened_valve_name][:flow_rate],
      current_valve_name: unopened_valve_name,
      unopened_valves: new_unopened_valves,
      path_taken: path_taken.dup.push(unopened_valve_name)
    )
  end
end

def part_1(input)
  graph = parse(input)
  distances = nil
  dist_elapsed = Time.measure do
    distances = compute_distances(graph)
  end
  p! dist_elapsed

  result = nil
  elapsed = Time.measure do
    result = part_1_recursive(
      graph,
      distances.not_nil!,
      max_time: 30,
      time_elapsed: 0,
      pressure_released: 0,
      current_flow: 0,
      current_valve_name: "AA",
      unopened_valves: graph.select { |_k, v| v[:flow_rate] > 0 }.keys.to_set,
      path_taken: [] of String
    )
  end
  p! elapsed
  result
end

def compute_all_path_pairs(node_names) : Iterator(Tuple(Array(String), Array(String)))
  node_names.each_permutation.flat_map do |perm|
    (0..(1 + perm.size//2)).each.map do |i|
      {perm[...i], perm[i..]}
    end
  end
end

def do_part_2(graph, distances, max_time, path_to_follow)
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

def part_2(input)
  graph = parse(input)
  distances = nil
  dist_elapsed = Time.measure do
    distances = compute_distances(graph)
  end
  p! dist_elapsed

  before = Time.monotonic
  useful_node_names = graph.select { |_k, v| v[:flow_rate] > 0 }.keys
  puts Time.monotonic - before

  all_possible_path_pairs = nil
  perm_elapsed = Time.measure do
    all_possible_path_pairs = compute_all_path_pairs(useful_node_names)
  end
  p! perm_elapsed

  result = nil
  elapsed = Time.measure do
    result = all_possible_path_pairs.not_nil!.max_of do |my_path, elephant_path|
      my_score = do_part_2(graph, distances.not_nil!, max_time: 26, path_to_follow: my_path)
      elephant_score = do_part_2(graph, distances.not_nil!, max_time: 26, path_to_follow: elephant_path)
      my_score + elephant_score
    end
  end
  p! elapsed
  result
end

input = File.read("inputs/day-16.txt").strip

p! part_1(test)
# p! part_1(input)

p! part_2(test)
p! part_2(input)
