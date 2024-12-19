
function read_onsen(lines)
   towels = split(lines[1], ", ")
   patterns = lines[3:end]
   (towels, patterns)
end

function part1(lines)
   (towels, patterns) = read_onsen(lines)
   regex = Regex("^(" * join(towels, "|") * raw")+$")
   count(match(regex, p) != nothing for p in patterns)
end

lines = readlines("../../data/advent2024/day19.txt")
(towels, patterns) = read_onsen(lines)

println(part1(lines))
