
function read_onsen(lines)
   towels = split(lines[1], ", ") .|> String
   patterns = lines[3:end]
   (towels, patterns)
end

function count_combos(towels::Vector{String}, pattern::String,
                      memos::Dict{String,Int64})
   lp = length(pattern)
   if lp == 0
      return 1
   else
      tot = 0
      for t in towels
         lt = length(t)
         if lp >= lt && pattern[1:lt] == t
            pat1 = pattern[lt+1:end]
            if !haskey(memos, pat1)
                memos[pat1] = count_combos(towels, pat1, memos)
            end
            tot += memos[pat1]
         end
      end
      return tot
   end
end

function part1(lines)
   (towels, patterns) = read_onsen(lines)
   regex = Regex("^(" * join(towels, "|") * raw")+$")
   count(match(regex, p) != nothing for p in patterns)
end

function part2(lines)
   (towels, patterns) = read_onsen(lines)
   tot = 0
   memos::Dict{String,Int64} = Dict()
   for p in patterns
      c = count_combos(towels, p, memos)
      tot += c
   end
   return tot
end

lines = readlines("../../data/advent2024/day19.txt")
(towels, patterns) = read_onsen(lines)

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("What is Santa's favourite type of music?", "Jenc")

