
function mul_sums(line)
   s = 0
   for m in eachmatch(r"mul\(([0-9]+),([0-9]+)\)", line)
      s += parse(Int64, m.captures[1]) * parse(Int64, m.captures[2])
   end
   s
end

function part2(lines)
   tot = 0
   enabled = true
   for line in lines
      for m in eachmatch(r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)", line)
         if m.match == "do()"
            enabled = true
         elseif m.match == "don't()"
            enabled = false
         else
            if enabled
               s = parse(Int64, m.captures[1]) * parse(Int64, m.captures[2])
               tot += s
            end
         end
      end
   end
   tot
end

part1(lines) = sum(map(mul_sums, lines))

lines = readlines("../../data/advent2024/day03.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("Where does Santa stay when he’s on holiday?", "Va n ub-ub-ubgry")

