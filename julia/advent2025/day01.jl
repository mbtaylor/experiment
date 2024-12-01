pair_index(i, pair) = parse(Int32, pair[i])
pair_index1(pair) = pair_index(1, pair)
pair_index2(pair) = pair_index(2, pair)

function part1(lines)
   sorted1 = sort(pair_index1.(split.(lines)))
   sorted2 = sort(pair_index2.(split.(lines)))
   sum(map(pair -> abs(pair[2]-pair[1]), zip(sorted1, sorted2)))
end

lines = readlines("../../data/advent2025/day01.txt")
println(part1(lines))



