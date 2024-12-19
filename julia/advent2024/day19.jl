
function read_onsen(lines)
   towels = split(lines[1], ", ")
   patterns = lines[3:end]
   (towels, patterns)
end

function count_combos(towels, pattern)
   lp = length(pattern)
   if lp == 0
      return 1
   else
      tot = 0
      for t in towels
         lt = length(t)
         if lp >= lt && pattern[1:lt] == t
            tot += count_combos(towels, pattern[lt+1:end])
         end
      end
      return tot
   end
end

function part1(lines)
   (towels, patterns) = read_onsen(lines)
   regex = Regex("^(" * join(towels, "|") * raw")+$")
   count(match(regex, p) != nothing for p in patterns)
end

function part2(lines)
   (towels, patterns) = read_onsen(lines)
   tot = 0
   for p in patterns
      c = count_combos(towels, p)
      tot += c
   end
   return tot
end

lines = readlines("../../data/advent2024/test19.txt")
(towels, patterns) = read_onsen(lines)

println(part1(lines))

# println(count_combos(towels, patterns[1]))
println(part2(lines))
