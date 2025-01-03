
mix(a, b) = a ⊻ b
prune(a) = mod(a, 16777216)

function next_secret(n)
   n = prune(mix(n << 6, n))
   n = prune(mix(n >> 5, n))
   n = prune(mix(n << 11, n))
end

# I bet there's a more idiomatic way to write this
function nth_secret(k, count)
   for i in 1:count
      k = next_secret(k)
   end
   k
end

function calc_prices(seed::Int64, count::Int)
   k = seed
   digits::Vector{Int} = []
   for i in 1:count
      push!(digits, mod(k, 10))
      k = next_secret(k)
   end
   digits
end

function calc_diffs(prices::Vector{Int})
   [prices[i] - (i > 1 ? prices[i-1] : -9999) for i in 1:length(prices)]
end

function trigger_index(diffs::Vector{Int}, trigger::NTuple{4, Int})
   for itrig in 1:length(diffs)-3
      if (diffs[itrig+0] == trigger[1] &&
          diffs[itrig+1] == trigger[2] &&
          diffs[itrig+2] == trigger[3] &&
          diffs[itrig+3] == trigger[4])
         return itrig+3
      end
   end
   nothing
end

function read_seeds(lines)
   [parse(Int64, line) for line in lines]
end

function part1(lines)
   tot = 0
   for line in lines
      tot += nth_secret(parse(Int64, line), 2000)
   end
   tot
end

function part2(lines)
   price_vecs = [calc_prices(s, 2000) for s in read_seeds(lines)]
   diff_vecs = [calc_diffs(prices) for prices in price_vecs]
   best_score = 0
   best_trigger = (0, 0, 0, 0)
   for i in -9:9
      for j in -9:9
         for k in -9:9
            for l in -9:9
               trigger = (i, j, k, l)
               score = 0
               for (iseed, diffs) in enumerate(diff_vecs)
                  itrig = trigger_index(diffs, trigger)
                  if itrig != nothing
                     score += price_vecs[iseed][itrig]
                  end
               end
               if score > best_score
                  (best_score, best_trigger) = (score, trigger)
               end
            end
         end
      end
   end
   best_score
end

lines = readlines("../../data/advent2024/day22.txt")

println(part1(lines))

# bit slow, takes about 10 minutes
println(part2(lines))

include("advent.jl")
joke("What was the obnoxious reindeer called?", "Ehqr-bycu")


