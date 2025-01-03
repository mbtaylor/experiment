

intify(words) = collect(parse(Int32, i) for i in words)

function is_safe1(levels)
   diffs = collect((levels[i] - levels[i-1]) for i in 2:length(levels))
   max = maximum(diffs)
   min = minimum(diffs)
   amin = abs(min)
   amax = abs(max)
   if amin > amax
      (amin, amax) = (amax, amin)
   end
   min * max > 0 && amin>0 && amax<4
end

function is_safe2(levels)
   if is_safe1(levels)
      return true
   end
   nl = length(levels)
   for i in 1:nl
      if is_safe1(collect(levels[j] for j in 1:nl if j!=i))
         return true
      end
   end
   false
end

function part1(lines)
   count(is_safe1.(intify.(split.(lines))))
end

function part2(lines)
   count(is_safe2.(intify.(split.(lines))))
end

lines = readlines("../../data/advent2024/day02.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("How does Darth Vader know what Luke got him for Christmas?",
     "Ur sryg uvf cerfrapr")

