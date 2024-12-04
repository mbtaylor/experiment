pair_index(i, pair) = parse(Int32, pair[i])
pair_index1(pair) = pair_index(1, pair)
pair_index2(pair) = pair_index(2, pair)

function part1(lines)
   sorted1 = sort(pair_index1.(split.(lines)))
   sorted2 = sort(pair_index2.(split.(lines)))
   sum(map(pair -> abs(pair[2]-pair[1]), zip(sorted1, sorted2)))
end

function part2(lines)
   list1 = pair_index1.(split.(lines))
   list2 = pair_index2.(split.(lines))
   counts2 = Dict{Int32,Int32}()
   for k in list2
      counts2[k] = get(counts2, k, 0) + 1
   end
   sum(map(k -> k*get(counts2, k, 0), list1))
end

lines = readlines("../../data/advent2024/day01.txt")
println(part1(lines))
println(part2(lines))



