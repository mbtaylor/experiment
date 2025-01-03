
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
in_grid(g::Grid, p::CartesianIndex{2}) = begin
   p[1] > g.pad && p[1] <= g.w0+g.pad && p[2] > g.pad && p[2] <=g.h0+g.pad
end

function get_freqs(grid::Grid)
   freqs = Set(grid[CartesianIndex(i)] for i in positions(grid))
   delete!(freqs, '.')
   freqs
end

function minimal_vector(v::CartesianIndex{2})
   v # I was expecting to have to do more work here
end

function count_antinodes(grid, antinodes_func)
   freqs = get_freqs(grid)
   anodes::Set{CartesianIndex{2}} = Set()
   for f in freqs
      points = collect(findall(c -> c==f, grid))
      np = length(points)
      for i in 1:np
          for j in 1:i-1
             for anode in antinodes_func(points[i], points[j])
                 if grid[anode] != ' '
                    push!(anodes, anode)
                 end
             end
          end
      end
   end
   length(anodes)
end

function part1(lines)
   grid = Grid(lines, 1+max(length(lines[1]), length(lines)))
   antinoder(a::CartesianIndex{2}, b::CartesianIndex{2}) = (2b-a, 2a-b)
   count_antinodes(grid, antinoder)
end

function part2(lines)
   grid = Grid(lines, 0)
   dim = max(length(lines[1]), length(lines))
   function antinoder(a::CartesianIndex{2}, b::CartesianIndex{2}) 
      v = minimal_vector(a-b)
      filter(p -> in_grid(grid, p), collect(a+i*v for i in -dim:dim))
   end
   count_antinodes(grid, antinoder)
end

lines = readlines("../../data/advent2024/day08.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("Why is it getting harder to buy Advent calendars?",
     "Gurve qnlf ner ahzorerq")


