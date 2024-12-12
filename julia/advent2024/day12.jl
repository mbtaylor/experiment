
const XYPos = CartesianIndex{2}

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
   (XYPos(i, j) for i in g.pad+1:size(g, 1)-g.pad,
                    j in g.pad+1:size(g, 2)-g.pad)
end

struct Region
   type::Char
   members::Set{XYPos}
end
Region(type::Char) = Region(type, Set())
function Base.show(io::IO, region::Region)
  print(io, region.type, " -> ", map(p->" ($(p[1]), $(p[2]))",
        sort!(collect(region.members))))
end

function neighbour_regions(field::Vector{Region}, type::Char, pos::XYPos)
   regions::Set{Region} = Set()
   for region in filter(r->r.type == type, field)
      for vec in map(XYPos, ((0,1), (1,0), (0,-1), (-1,0)))
         if (pos + vec) in region.members
            push!(regions, region)
         end
      end
   end
   regions
end


function segment(grid)
   field::Vector{Region} = Vector();
   for pos in positions(grid)
      type::Char = grid[pos]
      regions = collect(neighbour_regions(field, type, pos))
      nr = length(regions)
      if length(regions) == 0
         region = Region(type)
         push!(field, region)
      else
         region = regions[1]
         for r in collect(regions[2:end])
            union!(region.members, r.members)
            filter!(e->e!==r, field)
         end
      end
      push!(region.members, pos)
   end
   field
end

function part1(lines)
   grid = Grid(lines, 1)
end


lines = readlines("../../data/advent2024/test12.txt")
grid = Grid(lines, 1)
field = segment(grid)
println(length(field))
for r in field
   println(r)
end


