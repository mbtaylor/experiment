
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

nesw = ((0,1), (1,0), (0,-1), (-1,0))

function neighbours(pos::XYPos)
   map(p -> pos + XYPos(p), nesw)
end

function neighbour_regions(field::Vector{Region}, type::Char, pos::XYPos)
   regions::Set{Region} = Set()
   for region in filter(r->r.type == type, field)
      for n in neighbours(pos)
         if n in region.members
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

function area(region::Region)
   length(region.members)
end

function perimeter(region::Region)
   perimeter = 0
   for m in region.members
      nin = length(findall(n -> n in region.members, neighbours(m)))
      perimeter += 4-nin
   end
   perimeter
end

function count_edges(region::Region)
   members = region.members
   nedge = 0
   for dir in nesw
      segs::Vector{XYPos} = collect(filter(m -> m+XYPos(dir) ∉ members,
                                    members))
      isX = dir[1] == 0
      nedge += count_runs(segs, isX)
   end
   return nedge
end

function count_runs(segs::Vector{XYPos}, isX::Bool)
   runs::Vector{Set{XYPos}} = Vector()
   order = isX ? p->p[1] : p->p[2]
   rundir = isX ? XYPos(1, 0) : XYPos(0, 1)
   for seg in sort(collect(segs), by=order)
      irun = findfirst(r -> seg+rundir in r || seg-rundir in r, runs)
      if irun == nothing
         run::Set{XYPos} = Set()
         push!(runs, run)
      else
         run = runs[irun]
      end
      push!(run, seg)
   end
   length(runs)
end

function score1(region::Region)
   area(region) * perimeter(region)
end

function score2(region::Region)
   area(region) * count_edges(region)
end

function part1(lines)
   grid = Grid(lines, 1)
   field = segment(grid)
   sum(map(score1, field))
end

function part2(lines)
   grid = Grid(lines, 1)
   field = segment(grid)
   sum(map(score2, field))
end


lines = readlines("../../data/advent2024/day12.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("What looks like half a Christmas tree?", "Gur bgure unys")


