
struct Grid <: AbstractMatrix{Char}
   lines::Vector{String}
   pad::Int32
   w0::Int32
   h0::Int32
end
Grid(lines, pad) = Grid(lines, pad, length(lines[1]), length(lines))


# Implement Abstract Array interface
# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array
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

struct Dir <: AbstractChar
   c::Char
   dx::Int64
   dy::Int64
end
Base.codepoint(d::Dir) = codepoint(d.c)
next_direction(d::Dir) = directions[1+((findfirst(d1 ->d1==d, directions)) % 4)]

N = Dir('^',  0, -1)
E = Dir('>', +1,  0)
S = Dir('v',  0, +1)
W = Dir('<', -1,  0)

directions = [N, E, S, W]

function part1(lines)
   grid = Grid(lines, 1)
   pos::CartesianIndex = findfirst(c -> c in directions, grid)
   dir = directions[findfirst(d -> d == grid[pos], directions)]
   visited::Set{CartesianIndex} = Set()
   while grid[pos] != ' '
      pos1 = pos + CartesianIndex(dir.dx, dir.dy)
      if grid[pos1] == '#'
         dir = next_direction(dir)
      else
         push!(visited, pos)
         pos = pos1
      end
   end
   return length(visited)
end

lines = readlines("../../data/advent2024/day06.txt")

println(part1(lines))

