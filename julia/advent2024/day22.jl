

mix(a, b) = a ⊻ b
prune(a) = mod(a, 16777216)

function next_secret(n)
   n = prune(mix(n << 6, n))
   n = prune(mix(n >> 5, n))
   n = prune(mix(n << 11, n))
end

function nth_secret(k, count)
   for i in 1:count
      k = next_secret(k)
   end
   k
end

function part1(lines)
   tot = 0
   for line in lines
      tot += nth_secret(parse(Int64, line), 2000)
   end
   tot
end

lines = readlines("../../data/advent2024/day22.txt")

println(part1(lines))

