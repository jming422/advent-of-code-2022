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

optimal = ["D", "open",
           "C", "B", "open",
           "A", "I", "J", "open",
           "I", "A", "D", "E", "F", "G", "H", "open",
           "G", "F", "E", "open",
           "D", "C", "open",
           "idle"]

# start at A, max distance is H at 5 hops away
# heuristic is:
#   {
#     # hops+1@prev + (1+max_hops-hops)@locrate
#     H => 6min@0 + 1min@22 = 22
#     J => 3min@0 + 4min@21 = 84
#     D => 2min@0 + 5min@20 = 100 ***
#     B => 2min@0 + 5min@13 = 65
#     E => 3min@0 + 4min@3  = 12
#     C => 3min@0 + 4min@2  = 8
#   }
# but it might be:
#   {
#     # hops+1@prev + (max_hops-hops)@locrate
#     H => 6min@0 + 0min@22 = 0
#     J => 3min@0 + 3min@21 = 63
#     D => 2min@0 + 4min@20 = 80 ***
#     B => 2min@0 + 4min@13 = 52
#     E => 3min@0 + 3min@3  = 9
#     C => 3min@0 + 3min@2  = 6
#   }
#
# I think it will work
#
# now at D, flow rate is 20, max distance is still H, but now at 4 hops away
#   {
#     H => 5min@20 + 1min@42 = 100 + 42 = 142
#     J => 4min@20 + 2min@41 = 80 + 82 = 162 *** WRONG, should be B
#     B => 3min@20 + 3min@33 = 60 + 99 = 159
#     E => 2min@20 + 4min@23 = 40 + 97 = 137
#     C => 2min@20 + 4min@22 = 40 + 88 = 128
#   }
# what about alternate?
#   {
#     H => 5min@20 + 0min@42 = 100 + 0 = 100
#     J => 4min@20 + 1min@41 = 80 + 41 = 121
#     B => 3min@20 + 2min@33 = 60 + 66 = 126 *** I think this may be it!
#     E => 2min@20 + 3min@23 = 40 + 69 = 109
#     C => 2min@20 + 3min@22 = 40 + 66 = 106
#   }
#
# okay now we're at B, max distance is definately H at 6 hops away, flow rate is 20 + 13 = 33
#   {
#     H => 7min@33 + 0min@55 = 231 + 0   = 231
#     J => 4min@33 + 3min@54 = 132 + 162 = 294 *** we got it bb
#     E => 4min@33 + 3min@36 = 132 + 108 = 240
#     C => 2min@33 + 5min@34 = 66 + 170  = 236
#   }
#
# at J, max is still H at 7 hops, flow rate is 20+13+21=54
#   {
#     H => 8min@54 + 0min@76 = 432 + 0   = 432
#     E => 5min@54 + 3min@57 = 270 + 171 = 441 *** OH NO
#     C => 5min@54 + 3min@56 = 270 + 168 = 438
#   }
#
# what if we're right?
# we'd end up starting at whatever flow we were when we opened J, and then we'd end up with:
# 54 * 5 min while we open E = 270
# 57 * 4 min while we open H = 270 + 228 = 498
# 79 * 6 min while we open C = 270 + 228 + 395 = 972
# = 972 over 15 minutes, leaving 7 minutes left @ 81
#
# if we did it their way we'd have done:
# 54 * 8 min while we open H = 432
# 76 * 4 min while we open E = 432 + 304 = 736
# 79 * 3 min while we open C = 432 + 304 + 237 = 973
# = 973 over 15 minutes, leaving 7 minutes left @ 81
#
# we're not right
#
# okay so then we have to take the future more into account it seems
#
# for J, flow rate 54:
#             J to X      X to Y    => next
#   H to E => 54 * 8min + 76 * 4min => 79
#             432         304 (736)
#   H to C => 54 * 8min + 76 * 6min => 78
#             432         456 (888)
#   E to H => 54 * 5min + 57 * 4min => 79
#             270         228 (498)
#   E to C => 54 * 5min + 57 * 3min => 59
#             270         171 (441)
#   C to H => 54 * 5min + 56 * 6min => 78
#             270         336 (606)
#   C to E => 54 * 5min + 56 * 3min => 59
#             270         168 (438)
#
# okay simplify by only counting minutes after shortest path
# make sure everybody checks the same # of minutes
# we must spend at least 2 minutes at each time, 1 for move, 1 for open
#   H to E => 54 * 8-5min + 76 * 2min => 79
#             162           152 (314)
#   H to C => 54 * 8-5min + 76 * 2min => 78
#             162           152 (314)
#   E to H => 54 * 5-5min + 57 * 3+2min => 79
#             0             285 (285)
#   E to C => 54 * 5-5min + 57 * 3+2min => 59
#             0             285 (285)
#   C to H => 54 * 5-5min + 56 * 3+2min => 78
#             0             280 (280)
#   C to E => 54 * 5-5min + 56 * 3+2min => 59
#             0             280 (280)
#
# NOICE we can go back to only checking one forward, our new formula is:
#   prev_rate*(loc_time-min_time) + new_rate*(2+max_time-loc_time)
# equivalently, in Crystal,
#   score = current_rate * (time_to_open - min(times_to_open)) + (current_rate + loc_rate) * (2 + max(times_to_open) - time_to_open)
#
# okay verifying backwards:
# we're at H with a rate of 76 now:
#   E => 76*(4-4) + 79*(2+6-4) = 316 *** correct
#   C => 76*(6-4) + 78*(2+6-6) = 308
# for J, flow rate 54:
#   H => 54*(8-5) + 76*(2+8-8) = 314
#   E => 54*(5-5) + 57*(2+8-5) = 285 *** correct
#   C => 54*(5-5) + 56*(2+8-5) = 280
# okay now we're at B, max distance is definately H at 6 hops away, flow rate is 20 + 13 = 33
#   H => 33*(7min-2) + 55*(2+7-7) = 275
#   J => 33*(4min-2) + 54*(2+7-4) = 336 *** correct
#   E => 33*(4min-2) + 36*(2+7-4) = 246
#   C => 33*(2min-2) + 35*(2+7-2) = 245
# now at D, flow rate is 20, max distance is still H, but now at 4 hops away
#   H => 20*(5min-2) + 42*(2+5-5) = 144
#   J => 20*(4min-2) + 41*(2+5-4) = 163 *** WRONG
#   B => 20*(3min-2) + 33*(2+5-3) = 152
#   E => 20*(2min-2) + 23*(2+5-2) = 115
#   C => 20*(2min-2) + 22*(2+5-2) = 110
# start at A, max distance is H at 5 hops away
#   H => 0*(6min-2) + 22*(2+6-6) = 44
#   J => 0*(3min-2) + 21*(2+6-3) = 105
#   D => 0*(2min-2) + 20*(2+6-2) = 120 *** correct
#   B => 0*(2min-2) + 13*(2+6-2) = 78
#   E => 0*(3min-2) + 3*(2+6-3)  = 15
#   C => 0*(3min-2) + 2*(2+6-3)  = 10
#
# BAH FINE how about
#   (prev_rate*loc_time + new_rate*2)/(2+loc_time)
# we're at H with a rate of 76 now:
#   E => (76*4 + 79*2)/(2+4) = 77 *** correct
#   C => (76*6 + 78*2)/(2+6) = 76.5
# for J, flow rate 54:
#   H => (54*8 + 76*2)/(2+8) = 58.4 *** correct
#   E => (54*5 + 57*2)/(2+5) = 54.857
#   C => (54*5 + 56*2)/(2+5) = 54.571
# okay now we're at B, max distance is definately H at 6 hops away, flow rate is 20 + 13 = 33
#   H => (33*7 + 55*2)/(2+7) = 37.889
#   J => (33*4 + 54*2)/(2+4) = 40 *** correct
#   E => (33*4 + 36*2)/(2+4) = 34
#   C => (33*2 + 35*2)/(2+2) = 34
# now at D, flow rate is 20, max distance is still H, but now at 4 hops away
#   H => (20*5 + 42*2)/(2+5) = 26.286
#   J => (20*4 + 41*2)/(2+4) = 27 *** NOOOOOO
#   B => (20*3 + 33*2)/(2+3) = 25.2
#   E => (20*2 + 23*2)/(2+2) = 21.5
#   C => (20*2 + 22*2)/(2+2) = 21
# start at A, max distance is H at 5 hops away
#   H => (0 + 22*2)/(2+6) = 5.5
#   J => (0 + 21*2)/(2+3) = 8.4
#   D => (0 + 20*2)/(2+2) = 10 *** correct
#   B => (0 + 13*2)/(2+2) = 6.5
#   E => (0 + 3*2)/(2+3) = 1.2
#   C => (0 + 2*2)/(2+3) = 0.8

def parse(input)
  [] of Int64
end

def thing(stuff)
  false
end

def part_1(input)
  stuff = parse(input)
  result = thing(stuff)
  result
end

def part_2(input)
  stuff = parse(input)
  result = thing(stuff)
  result
end

input = File.read("inputs/day-16.txt").strip

p! part_1(test)
# p! part_1(input)
# p! part_2(test)
# p! part_2(input)
