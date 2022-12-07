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

alias Entry = Int64 | Nil
alias Entries = Hash(Path, Entry)
alias Directories = Hash(Path, Entries)

# It's too flat to be a tree so I'm calling my data structure a mushroom
def build_dir_mushroom(input)
  # the problem is ultimately asking about directories, so because recursive
  # data structures in Crystal are not something I can figure out quickly, I'm
  # gonna just make a flat hash of directories for now. Each list item is a hash
  # of its contents' names and sizes. Directories have nil sizes, and their
  # paths correspond to other entries in the directories list.
  cwd = Path.posix("/")
  directories = {cwd => Entries.new}
  input.each_line do |line|
    case line
    when "$ ls"
      next
    when .starts_with?("$ cd ")
      if line[5..] == "/"
        cwd = Path.posix("/")
      else
        cwd = (cwd / line[5..]).normalize
      end
    when .starts_with?("dir ")
      new_dir = cwd / line[4..]
      # update the cwd's entry to have a record for this new directory
      directories[cwd][new_dir] = nil
      # add a new entry for this directory
      directories[new_dir] = {} of Path => Int64 | Nil
    else
      # file
      size, name = line.split
      directories[cwd][cwd / name] = size.to_i
    end
  end

  directories
end

def compute_dir_size(mushroom : Directories, contents : Entries, worry_level = 0)
  size = 0
  contents.each do |path, entry|
    if entry.is_a?(Int)
      size += entry
    elsif worry_level < 50
      size += compute_dir_size(mushroom, mushroom[path], worry_level + 1)
    else
      raise "We're 50+ dirs deep, something is probably wrong"
    end
  end

  size
end

# Remember mushroom is { dir_path => { entry_path => size for files | nil for
# subdirs, whose entry_path is in mushroom }}
def compute_all_dir_sizes(mushroom)
  mushroom.transform_values { |dir_entries| compute_dir_size(mushroom, dir_entries) }
end

def part_1(input)
  compute_all_dir_sizes(build_dir_mushroom(input)).values.select(&.<=(100000)).sum
end

def part_2(input, total_size, reqd_size)
  dirs = compute_all_dir_sizes(build_dir_mushroom(input))
  unused_space = total_size - dirs[Path.posix("/")]
  to_delete = reqd_size - unused_space

  dirs.values.select(&.>=(to_delete)).min
end

input = File.read("inputs/day-7.txt").strip

p! part_1(test)
p! part_1(input)

p! part_2(test, 70000000, 30000000)
p! part_2(input, 70000000, 30000000)
