
struct Grid <: AbstractMatrix{Char}
   lines::Vector{String}
   pad::Int64
   w0::Int64
   h0::Int64
end
Grid(lines, pad) = Grid(lines, pad, length(lines[1]), length(lines))
Base.size(g::Grid) = (g.w0 + 2 * g.pad, g.h0 + 2 * g.pad)
Base.getindex(g::Grid, i::Int, j::Int) = begin
   pi = i - g.pad
   pj = j - g.pad
   pi > 0 && pi <= g.w0 && pj > 0 && pj <= g.h0 ? g.lines[pj][pi] : ' '
end
positions(g::Grid) = begin
   (CartesianIndex(i, j) for i in g.pad+1:size(g, 1)-g.pad,
                             j in g.pad+1:size(g, 2)-g.pad)
end

struct Node
   x::Int64
   y::Int64
   idir::Int8
end
function forward(node::Node)
   Node(node.x+enws[node.idir][1], node.y+enws[node.idir][2], node.idir)
end
function left(node::Node)
   Node(node.x, node.y, mod1(4, node.idir+1))
end
function right(node::Node)
   Node(node.x, node.y, mod1(4, node.idir-1))
end
function xypos(node::Node)
   CartesianIndex(node.x, node.y)
end

# I hate 1-based arrays
mod1(n,i) = ((i-1+n)%n)+1

enws = ((+1,0), (0,-1), (-1,0), (0,+1))
ndir = length(enws)

function find_paths(tree::Dict{Node,Vector{Node}}, nodes::Vector{Node})
   paths::Set{Node} = Set()
   for n0 in nodes
      push!(paths, n0)
      for n1 in find_paths(tree, tree[n0])
         push!(paths, n1)
      end
   end
   paths
end

function display_paths(grid::Grid, paths::Set{CartesianIndex{2}})
   for (y, line) in enumerate(grid.lines)
      for (x, c) in enumerate(line)
         print(CartesianIndex(x,y) in paths ? 'O' : c)
      end
      println()
   end
end

function part1(lines)
   grid = Grid(lines, 0)
   xy_start = findfirst(c->c=='S', grid)
   xy_end = findfirst(c->c=='E', grid)
   # Dijskstra's algorithm.  Thanks wikipedia!
   nodes = [Node(p[1], p[2], idir) for idir in 1:4,
                                   p in positions(grid) if grid[p] != '#']
   # A 3d array would be faster
   distances::Dict{Node,Float64} = Dict(n => Inf for n in nodes)
   distances[Node(xy_start[1], xy_start[2], 1)] = 0
   unvisited = Set(nodes)
   end_nodes = [Node(xy_end[1], xy_end[2], idir) for idir in 1:4]
   while !isempty(intersect(unvisited, end_nodes))
      node_min = argmin(n->distances[n], unvisited)
      dist_min = distances[node_min]
      if dist_min == Inf
         break
      end
      node_fwd = forward(node_min)
      node_left = left(node_min)
      node_right = right(node_min)
      if haskey(distances, node_fwd)
         distances[node_fwd] = min(distances[node_fwd], dist_min + 1)
      end
      distances[node_left] = min(distances[node_left], dist_min + 1000)
      distances[node_right] = min(distances[node_right], dist_min + 1000)
      delete!(unvisited, node_min)
   end
   Int64(minimum(distances[n] for n in end_nodes))
end

function part2(lines)
   grid = Grid(lines, 0)
   xy_start = findfirst(c->c=='S', grid)
   xy_end = findfirst(c->c=='E', grid)
   nodes = [Node(p[1], p[2], idir) for idir in 1:4,
                                   p in positions(grid) if grid[p] != '#']
   distances::Dict{Node,Float64} = Dict(n => Inf for n in nodes)
   distances[Node(xy_start[1], xy_start[2], 1)] = 0
   unvisited = Set(nodes)
   end_nodes = [Node(xy_end[1], xy_end[2], idir) for idir in 1:4]
   predecessors::Dict{Node,Vector{Node}} = Dict(n => [] for n in nodes)
   while !isempty(intersect(unvisited, end_nodes))
      node_min = argmin(n->distances[n], unvisited)
      dist_min = distances[node_min]
      if dist_min == Inf
         break
      end
      for (node_next, score) in [(forward(node_min), dist_min + 1),
                                 (left(node_min), dist_min + 1000),
                                 (right(node_min), dist_min + 1000)]
         if haskey(distances, node_next)
            if score <= distances[node_next]
               if score < distances[node_next]
                  predecessors[node_next] = []
                  distances[node_next] = score
               end
               push!(predecessors[node_next], node_min)
            end
         end
      end
      delete!(unvisited, node_min)
   end
   best_score = minimum(distances[n] for n in end_nodes)
   win_end_nodes = filter(n -> distances[n] == best_score, end_nodes)
   winner_nodes::Set{Node} = find_paths(predecessors, win_end_nodes)
   winner_cells::Set{CartesianIndex{2}} = Set()
   for node in winner_nodes
       push!(winner_cells, xypos(node))
   end
   # display_paths(grid, winner_cells)
   length(winner_cells)
end

lines = readlines("../../data/advent2024/day16.txt")

println("slow ... takes a minute or two")
println(part1(lines))
println(part2(lines))
