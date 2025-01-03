
struct Robot
   x0::Int64
   y0::Int64
   dx::Int64
   dy::Int64
end

struct XY
   x::Int64
   y::Int64
end

function read_robots(lines)
   robots::Vector{Robot} = Vector()
   for line in lines
      m = match(r"p=([-?0-9]+),([-?0-9]+) v=([-?0-9]+),([-?0-9]+)", line)
      cm = m.captures
      push!(robots, Robot(parse(Int64, cm[1]), parse(Int64, cm[2]),
                          parse(Int64, cm[3]), parse(Int64, cm[4])))
   end
   robots
end

mod(x, m) = ((x % m) + m) % m

function robot_position(robot, nt)
   x = mod(robot.x0 + nt * robot.dx, dims[1])
   y = mod(robot.y0 + nt * robot.dy, dims[2])
   XY(x, y)
end

function move_robots(lines)
   read_robots(lines) .|> r -> robot_position(r, 100)
end

function izone(pos::XY)
   i = pos.x - (dims[1]) ÷ 2
   j = pos.y - (dims[2]) ÷ 2
   return ((i == 0 || j == 0) ? nothing
                              : ( i>0 ? 0 : 1 ) + ( j>0 ? 0 : 2))
end

function count_map(rps::Vector{XY})
   map = zeros(Int64, dims[1], dims[2])
   for p in rps
      map[p.x+1, p.y+1] += 1
   end
   map
end

function part1(lines)
   rps = read_robots(lines) .|> r -> robot_position(r, 100)
   rzs = rps .|> izone
   #println(display(collect(zip(rps,rzs))))
   zcounts = collect((count(x->x==i, rzs) for i in 0:3))
   prod(zcounts)
end

function plot_robots(rps::Vector{XY})
   xs = map(p -> p.x, rps)
   ys = map(p -> p.y, rps)
   scatter(xs, ys)
end

function count_full_blocks(xys::Vector{XY})
   m = zeros(dims[1], dims[2])
   for xy in xys
      m[xy.x+1, xy.y+1] += 1
   end
   siz = 4
   nblank = 0
   nz = 0
   nf = 0
   for x in 1:dims[1]-siz
      for y in 1:dims[2]-siz
         s = sum(m[i+x,j+y] for i in 1:siz, j in 1:siz)
         if s == 0
            nz += 1
         elseif s == siz * siz
            nf += 1
         end
      end
   end
   nf
end

function part2(lines)
   robots = read_robots(lines)
   i = 0
   while true
      rps = robots .|> r -> robot_position(r, i)
      cb = count_full_blocks(rps)
      if cb > 10
         return i
      end
      i += 1
   end
end

function plot_robots_at(robots, t)
   plot_robots(robots .|> r -> robot_position(r, t))
end

dims = (101, 103)
lines = readlines("../../data/advent2024/day14.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("How do snowmen make phone calls?", "Ba n fabjzbovyr")

