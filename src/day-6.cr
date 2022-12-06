tests = [
  {"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7, 19},
  {"bvwbjplbgvbhsrlpgdmjqwftvncz", 5, 23},
  {"nppdvjthqldpwncqszvftbrmjlhg", 6, 23},
  {"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10, 29},
  {"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11, 26},
]

def solve(input, len)
  buf = Deque(Char).new(len)

  input.each_char_with_index do |char, idx|
    char_idx = buf.index(char)
    return idx + 1 if buf.size == len - 1 && !char_idx # footnote [1]
    buf.shift(char_idx + 1) if char_idx                # footnote [2]
    buf.push(char)
  end

  return nil
end

# p! solve(tests[0][0], 4)

# tests.each do |test, expt_1, expt_2|
#   p! test, expt_1, solve(test, 4), expt_2, solve(test, 14)
#   puts
# end

input = File.read("inputs/day-6.txt").strip
part_1 = solve(input, 4)
p! part_1

part_2 = solve(input, 14)
p! part_2

# [1] If our buffer has len-1 chars, and we're about to push a char that wasn't
# found in it, then our position is the solution! (Plus 1 because the prompt
# wants the number of chars, not index)

# [2] Otherwise, we must continue looking. If char is already in the buffer, we
# can delete our buf up until & including the char we found, since nothing
# before the duplicate char can be part of the marker before the duplicate char
# can be part of the marker
