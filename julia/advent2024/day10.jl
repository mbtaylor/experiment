
struct Grid <: AbstractMatrix{Char}
   lines::Vector{String}
   pad::Int32
   w0::Int32
   h0::Int32
end
Grid(lines, pad) = Grid(lines, pad, length(lines[1]), length(lines))
Base.size(g::Grid) = (g.w0 + 2 * g.pad, g.h0 + 2 * g.pad)
Base.getindex(g::Grid, i::Int, j::Int) = begin
   pi = i - g.pad
   pj = j - g.pad
   pi > 0 && pi <= g.w0 && pj > 0 && pj <= g.h0 ? g.lines[pj][pi] : ' '
end
positions(g::Grid) = begin
   ((i, j) for i in g.pad+1:size(g, 1)-g.pad,
               j in g.pad+1:size(g, 2)-g.pad)
end

nvecs = map(p->CartesianIndex(p), ((0,1), (1,0), (0,-1), (-1,0)))

function next_routes(grid::Grid, route::Vector{CartesianIndex{2}})
   k = grid[route[end]]
   nexts::Vector{Vector{CartesianIndex{2}}} = []
   for vec = nvecs
      p = route[end] + vec
      if grid[p] == k + 1
         route1 = copy(route)
         push!(route1, p)
         push!(nexts, route1)
         for nr in next_routes(grid, route1)
            push!(nexts, nr)
         end
      end
   end
   nexts
end

function part1(lines)
   grid = Grid(lines, 1)
   starts = findall(c -> c == '0', grid)
   tot = 0
   for s in starts
      routes = collect(filter(r -> length(r) == 10, next_routes(grid, [s])))
      ends = Set(map(r -> r[end], routes))
      score = length(ends)
      tot += score
   end
   tot
end

function part2(lines)
   grid = Grid(lines, 1)
   starts = findall(c -> c == '0', grid)
   tot = 0
   for s in starts
      routes = collect(filter(r -> length(r) == 10, next_routes(grid, [s])))
      score = length(routes)
      tot += score
   end
   tot
end

lines = readlines("../../data/advent2024/day10.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("What happened to the man who stole an Advent calendar?",
     "Ur tbg 24 qnlf")


