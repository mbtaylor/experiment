
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

function antinodes(a::CartesianIndex{2}, b::CartesianIndex{2})
   (2b-a, 2a-b)
end

function part1(lines)
   grid = Grid(lines, 1+max(length(lines[1]), length(lines)))
   freqs = Set(grid[CartesianIndex(i)] for i in positions(grid))
   delete!(freqs, '.')
   anodes::Set{CartesianIndex{2}} = Set()
   for f in freqs
      points = collect(findall(c -> c==f, grid))
      np = length(points)
      for i in 1:np
          for j in 1:i-1
             for anode in antinodes(points[i], points[j])
                 if grid[anode] != ' '
                    push!(anodes, anode)
                 end
             end
          end
      end
   end
   length(anodes)
end

lines = readlines("../../data/advent2024/day08.txt")

println(part1(lines))


