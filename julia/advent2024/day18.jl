
const XY = CartesianIndex{2}

struct Grid <: AbstractMatrix{Char}
   matrix::Matrix{Char}
   dim::Int64
end
Base.size(g::Grid) = Base.size(g.matrix)
Base.getindex(g::Grid, i::Int, j::Int) = begin
   i >= 0 && i < g.dim && j >= 0 && j < g.dim ? g.matrix[i+1, j+1] : ' '
end
Base.setindex!(g::Grid, value::Char, i::Int, j::Int) = begin
   setindex!(g.matrix, value, i+1, j+1)
end
Grid(dim) = Grid(['.' for i in 1:dim, j in 1:dim], dim)
display(g::Grid) = begin
   for y in 0:g.dim-1
      for x in 0:g.dim-1
         print(g[x,y])
      end
      println()
   end
end

function create_grid(dim)
   grid::Grid = Grid(dim)
end

function positions(lines)
   xys::Vector{XY} = []
   for line in lines
      xy = split(line, ",") .|> s->parse(Int64, s)
      push!(xys, XY(xy[1], xy[2]))
   end
   xys
end

function fill(grid::Grid, xys::Vector{XY})
   for xy in xys
      grid[xy] = '#'
   end
end


(lines, dim) = (readlines("../../data/advent2024/test18.txt"), 7)
grid = create_grid(dim)
xys = positions(lines)
fill(grid, xys[1:12])
display(grid)

println("cell: ", grid[3,4], " - ", grid.matrix[3,4])
