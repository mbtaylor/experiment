
const XY = CartesianIndex{2}

nesw = ((0,-1), (1,0), (0,1), (-1,0)) .|> XY
dir_char(c::Char) = nesw[findfirst(l->l==c, ('^','>','v','<'))]

function print_map(map::Matrix{Char})
   for iy in 1:size(map)[2]
      println(prod(map[ix,iy] for ix in 1:size(map)[1]))
   end
end

function parse_lines(lines)
   nx = length(lines[1])
   ny = findfirst(l->length(l)==0, lines)-1
   map::Matrix{Char} = Matrix(undef, nx, ny)
   for iy in 1:ny
      for ix = 1:nx
         map[ix,iy] = lines[iy][ix]
      end
   end
   moves::Vector{XY} = Vector()
   for line in lines[ny+1:end]
      for c in line
         push!(moves, dir_char(c))
      end
   end
   (map, moves)
end

function find_robot(map::Matrix{Char})
   findfirst(c->c=='@', map)
end

function apply_move(map::Matrix{Char}, move::XY, p0::XY)
   nbox = 0
   while true
      c1 = map[p0+(nbox + 1)*move]
      if c1 == '#'
         return p0
      elseif c1 == 'O'
         nbox += 1
      elseif c1 == '.'
         p1 = p0+move
         map[p0+move*(nbox+1)] = 'O'
         map[p0] = '.'
         map[p1] = '@'
         return p1
      else
         error("what?")
      end
   end
end

function score_pos(pos::XY)
   (pos[1]-1)+(pos[2]-1)*100
end

function score_map(map::Matrix{Char})
   sum(score_pos(box) for box in findall(c->c=='O', map))
end

function part1(lines)
   (map, moves) = parse_lines(lines)
   pos = find_robot(map)
   for move in moves
      pos = apply_move(map, move, pos)
   end
   score_map(map)
end

lines = readlines("../../data/advent2024/day15.txt")

println(part1(lines))


