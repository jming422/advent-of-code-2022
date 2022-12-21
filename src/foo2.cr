arr = [1, 2, 3, 4]

res = arr.permutations.flat_map do |perm|
  # include array size!
  (0..perm.size).map do |i|
    {perm[...i], perm[i..]}
  end
end

seen = Set(Tuple(Array(Int32), Array(Int32))).new
res_2 = res.reject do |tup|
  if seen.includes?(tup) || seen.includes?(tup.reverse)
    true
  else
    seen << tup
    false
  end
end

p! res.size
p! res_2.size
p! res_2

res_3 = arr.permutations.flat_map do |perm|
  # inclusive!
  (0..(perm.size//2)).map do |i|
    {perm[...i], perm[i..]}
  end
end

p! res_3.size
p! res_3

res_4 = arr.permutations.flat_map do |perm|
  # inclusive!
  (0..(perm.size//2 - (perm.size.even? ? 1 : 0))).map do |i|
    {perm[...i], perm[i..]}
  end
end

p! res_4.size
p! res_4
