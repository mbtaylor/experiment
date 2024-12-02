

intify(words) = collect(parse(Int32, i) for i in words)

function is_safe(levels)
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

function part1(lines)
    count(is_safe.(intify.(split.(lines))))
end

lines = readlines("../../data/advent2025/day02.txt")

println(part1(lines))
