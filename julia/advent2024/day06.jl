
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

struct BlockedGrid <: AbstractMatrix{Char}
   grid::Grid
   bx::Int32
   by::Int32
end
Base.size(g::BlockedGrid) = Base.size(g.grid)
Base.getindex(g::BlockedGrid, i::Int, j::Int) = begin
   i == g.bx && j == g.by ? '#' : Base.getindex(g.grid, i, j)
end
positions(g::BlockedGrid) = positions(g.grid)


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

function is_loop(grid)
   pos::CartesianIndex = findfirst(c -> c in directions, grid)
   dir = directions[findfirst(d -> d == grid[pos], directions)]
   states::Set{Tuple{CartesianIndex, Dir}} = Set()
   while true
      if grid[pos] == ' '
         return false
      elseif (pos, dir) in states
         return true
      else
         push!(states, (pos, dir))
      end
      pos1 = pos + CartesianIndex(dir.dx, dir.dy)
      if grid[pos1] == '#'
         dir = next_direction(dir)
      else
         pos = pos1
      end
   end
end

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

function part2(lines)
   grid = Grid(lines, 1)
   tot = 0
   for (i, j) in positions(grid)
      if grid[i, j] == '.'
         bgrid = BlockedGrid(grid, i, j)
         if is_loop(bgrid)
            tot += 1
         end
      end
   end
   tot
end

lines = readlines("../../data/advent2024/day06.txt")

println(part1(lines))
println(part2(lines))


