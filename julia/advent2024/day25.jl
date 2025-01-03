
function parse_lines(lines)
   locks::Vector{Vector{Int}} = []
   keys::Vector{Vector{Int}} = []
   nblock = (length(lines)+1) ÷ 8
   for ib in 1:nblock
      block = [lines[(ib-1)*8+i] for i in 1:7]
      if block[1][1] == '#'
         push!(locks,
               [findfirst('.', String([block[i][j] for i in 1:7])) - 2
                for j in 1:5])
      elseif block[7][1] == '#'
         push!(keys,
               [findfirst('.', String([block[i][j] for i in 7:-1:1])) - 2
                for j in 1:5])
      end
   end
   (locks, keys)
end

function can_open(lock, key)
   for i in 1:5
      if lock[i] + key[i] > 5
         return false
      end
   end
   return true
end

function part1(lines)
   (locks, keys) = parse_lines(lines)
   n = 0
   for lock in locks
      for key in keys
         if can_open(lock, key)
            n += 1
         end
      end
   end
   n
end

lines = readlines("../../data/advent2024/day25.txt")

println(part1(lines))

include("advent.jl")
joke("Why are Christmas trees so fond of the past?",
     "Orpnhfr gur cerfrag'f orarngu gurz")


