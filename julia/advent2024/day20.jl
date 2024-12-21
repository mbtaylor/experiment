
const XY = CartesianIndex{2}

struct Grid <: AbstractMatrix{Char}
   lines::Vector{String}
   w::Int
   h::Int
end
Grid(lines) = Grid(lines, length(lines[1]), length(lines))
Base.size(g::Grid) = (g.w, g.h)
Base.getindex(g::Grid, i::Int, j::Int) = begin
   i > 0 && i <= g.w && j > 0 && j <= g.h ? g.lines[j][i] : ' '
end
positions(g::Grid) = (CartesianIndex(i, j) for i in 1:g.w, j in 1:g.h)

struct Cheat
   offset::XY
   nstep::Int
end

function list_cheats(max)
   [Cheat(XY(i, j), abs(i)+abs(j)) for i in -max:max, j in -max:max
                                   if abs(i)+abs(j) <= max]
end

function calc_distances(grid::Grid)
   start_pos = findfirst(c->c=='S', grid)
   end_pos = findfirst(c->c=='E', grid)
   distances::Matrix{Float64} = [Inf for i in 1:grid.w, j in 1:grid.h]
   distances[start_pos] = 0
   unvisited::Set{XY} = Set(positions(grid))
   while !isempty(unvisited)
      pos_min = argmin(xy -> distances[xy], unvisited)
      dist_min = distances[pos_min]
      if dist_min == Inf
         break
      end
      for step in [XY(1,0), XY(0,1), XY(-1,0), XY(0,-1)]
         pos = pos_min + step
         if grid[pos] != '#' && pos in unvisited
            distances[pos] = dist_min + 1
         end
         delete!(unvisited, pos_min)
      end
   end
   distances
end

is_track(c) = c == '.' || c == 'S' || c == 'E'

function part1(lines)
   grid = Grid(lines)
   dists = calc_distances(grid)
   diffs::Vector{Int} = Vector()
   for xy in positions(grid)
      for dir in [XY(0,1), XY(1,0)]
         p1 = xy + dir
         p2 = xy - dir
         if is_track(grid[p1]) && is_track(grid[p2]) && grid[xy] == '#'
            diff = abs(dists[p1] - dists[p2]) - 2
            if diff > 0
               push!(diffs, diff)
            end
         end
      end
   end
   length(filter(d->d>=100, diffs))
end

function part2(lines)
   grid = Grid(lines)
   dists = calc_distances(grid)
   cheats = list_cheats(20)
   diffs::Vector{Int} = Vector()
   for p0 in positions(grid)
      if is_track(grid[p0])
         for cheat in cheats
            p1 = p0 + cheat.offset
            if is_track(grid[p1])
               diff = dists[p1] - dists[p0] - cheat.nstep
               if diff > 0
                  push!(diffs, diff)
               end
            end
         end
      end
   end
   # sort([(i, count(==(i), diffs)) for i in unique(diffs)], by=x->x[1])
   length(filter(d->d >= 100, diffs))
end

lines = readlines("../../data/advent2024/day20.txt")

grid = Grid(lines)

# display(map(d->d==Inf ? -1 : Int(d), transpose(calc_distances(grid))))

println(part1(lines))
println(part2(lines))


