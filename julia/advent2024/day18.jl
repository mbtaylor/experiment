
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
ZMatrix(dim, el, blank) = begin
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


(lines, dim) = (readlines("../../data/advent2024/test18.txt"), 7)
grid = create_grid(dim)
xys = positions(lines)
fill(grid, xys[1:12])
display(grid)

