
function mul_sums(line)
   s = 0
   for m in eachmatch(r"mul\(([0-9]+),([0-9]+)\)", line)
      s += parse(Int32, m.captures[1]) * parse(Int32, m.captures[2])
   end
   s
end

function part1(lines)
   sum(map(mul_sums, lines))
end

lines = readlines("../../data/advent2025/day03.txt")

println(part1(lines))
