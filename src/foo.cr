arr = [1, 2, 3, 4]

i_want = [
  # arr.permutations(0).cartesian_product(arr.permutations(4))
  {[] of Int32, [1, 2, 3, 4]},
  {[] of Int32, [1, 3, 2, 4]},
  {[] of Int32, ["etc..."]},
  {[1, 2, 3, 4], [] of Int32},
  {[1, 3, 2, 4], [] of Int32},
  {["etc"], [] of Int32},

  # arr.permutations(1).cartesian_product(arr.permutations(2))
  {[1], [2, 3, 4]},
  {[1], [3, 2, 4]},
  # ...
  {[1, 2, 4], [3]},
  # ...

  # arr.permutations
  {[1, 2], [3, 4]},
  {[2, 1], [3, 4]},
  {[1, 2], [4, 3]},
  {[2, 1], [4, 3]},

  {[1, 3], [2, 4]},
  {[3, 1], [2, 4]},
  {[1, 3], [4, 2]},
  {[3, 1], [4, 2]},

  {[1, 4], [2, 3]},
  {[4, 1], [2, 3]},
  {[1, 4], [3, 2]},
  {[4, 1], [3, 2]},

  {[2, 3], [1, 4]},
  {[3, 2], [4, 1]},
  {[2, 3], [1, 4]},
  {[3, 2], [4, 1]},
]

res = (0..(arr.size//2)).map do |i|
  j = arr.size - i
end