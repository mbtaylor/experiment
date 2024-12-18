
const XY = CartesianIndex{2}

# Zero-based square matrix with out-of-bounds access yielding a supplied value
struct ZMatrix{T} <: AbstractMatrix{T}
   matrix::Matrix{T}
   dim::Int64
   blank::T
end
Base.size(m::ZMatrix) = Base.size(m.matrix)
Base.getindex(m::ZMatrix, i::Int, j::Int) = begin
   i >= 0 && i < m.dim && j >= 0 && j < m.dim ? m.matrix[i+1, j+1] : m.blank
end
Base.setindex!(m::ZMatrix, value, i::Int, j::Int) = begin
   setindex!(m.matrix, value, i+1, j+1)
end
ZMatrix(dim::Int64, el, blank) = begin
   ZMatrix([el for i in 1:dim, j in 1:dim], dim, blank)
end
display(m::ZMatrix{Char}) = begin
   for y in 0:m.dim-1
      for x in 0:m.dim-1
         print(m[x,y])
      end
      println()
   end
end
positions(m::ZMatrix) = (XY(i, j) for i in 0:m.dim-1, j in 0:m.dim-1)

function create_grid(dim)
   grid::ZMatrix{Char} = ZMatrix(dim, '.', ' ')
end

function positions(lines)
   xys::Vector{XY} = []
   for line in lines
      xy = split(line, ",") .|> s->parse(Int64, s)
      push!(xys, XY(xy[1], xy[2]))
   end
   xys
end

function fill(grid::ZMatrix{Char}, xys::Vector{XY})
   for xy in xys
      grid[xy] = '#'
   end
end

function part1(lines, dim)
 println(typeof(lines), "\t", typeof(dim), "\t", dim)
   grid::ZMatrix{Char} = create_grid(dim)
   xys = positions(lines)
   fill(grid, xys[1:1024])
   distances::ZMatrix{Float64} = ZMatrix(dim, Inf, NaN)
   distances[0,0] = 0
   unvisited::Set{XY} = Set(positions(grid))
   end_pos = XY(dim-1, dim-1)
   while end_pos ∈ unvisited
      pos_min = argmin(xy -> distances[xy], unvisited)
      dist_min = distances[pos_min]
      if dist_min == Inf
         break
      end
      for step in [XY(1,0), XY(0,1), XY(-1,0), XY(0,-1)]
         pos = pos_min + step
         if grid[pos] == '.'
            distances[pos] = dist_min + 1
         end
         delete!(unvisited, pos_min)
      end
   end
   Int64(distances[end_pos])
end


(lines, dim) = (readlines("../../data/advent2024/day18.txt"), 71)

println(part1(lines, dim))

