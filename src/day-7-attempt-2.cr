test = "$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k"

record MyDirectory, value : Hash(String, MyDirectory | Int64) = {} of String => MyDirectory | Int64

def build_dir_tree(input)
  tree = MyDirectory.new
  cwd = Path.posix("/")
  current_dir = tree
  input.each_line do |line|
    case line
    when "$ ls"
      next
    when .starts_with?("$ cd ")
      if line[5..] == "/"
        cwd = Path.posix("/")
        current_dir = tree
      else
        cwd = (cwd / line[5..]).normalize
        # Makes me wish I could splat an array into tree.dig(), but sadly
        # Crystal does not allow this
        current_dir = cwd.parts[1..].reduce(tree) do |dir, ent_name|
          next_dir = dir.value[ent_name]
          if next_dir.is_a?(MyDirectory)
            next_dir
          else
            raise "Can't cd to a regular file"
          end
        end
      end
    when .starts_with?("dir ")
      # update the cwd's entry to have a record for this new directory
      current_dir.value[line[4..]] = MyDirectory.new
    else
      # add a file to the cwd
      size, name = line.split
      current_dir.value[name] = size.to_i
    end
  end

  tree
end

def compute_dir_sizes(dir : MyDirectory, worry_level = 0)
  size = 0
  subdirs = [] of Int64
  dir.value.each_value do |entry|
    if entry.is_a?(Int)
      size += entry
    elsif worry_level < 50
      subsubdirs = compute_dir_sizes(entry, worry_level + 1)
      size += subsubdirs[-1]
      subdirs.concat(subsubdirs)
    else
      raise "We're 50+ dirs deep, something is probably wrong"
    end
  end

  subdirs.push(size)
end

def part_1(input)
  compute_dir_sizes(build_dir_tree(input)).select(&.<=(100000)).sum
end

def part_2(input, total_size, reqd_size)
  tree = build_dir_tree(input)
  dirs = compute_dir_sizes(tree)
  unused_space = total_size - dirs[-1]
  to_delete = reqd_size - unused_space

  dirs.select(&.>=(to_delete)).min
end

input = File.read("inputs/day-7.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test, 70000000, 30000000)
p! part_2(input, 70000000, 30000000)
