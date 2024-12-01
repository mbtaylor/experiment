
pair_index(i, pair) = parse(Int32, pair[i])
pair_index1(pair) = pair_index(1, pair)
pair_index2(pair) = pair_index(2, pair)

lines = readlines("../../data/advent2025/day01.txt")

sorted1 = sort(pair_index1.(split.(lines)))
sorted2 = sort(pair_index2.(split.(lines)))

println( sum(map(pair -> abs(pair[2]-pair[1]), zip(sorted1, sorted2))) )

