
const XY = CartesianIndex{2}

nesw = ((0,-1), (1,0), (0,1), (-1,0)) .|> XY
dir_char(c::Char) = nesw[findfirst(l->l==c, ('^','>','v','<'))]

function print_grid(grid::Matrix{Char})
   for iy in 1:size(grid)[2]
      println(prod(grid[ix,iy] for ix in 1:size(grid)[1]))
   end
end

function parse_lines(lines)
   nx = length(lines[1])
   ny = findfirst(l->length(l)==0, lines)-1
   grid::Matrix{Char} = Matrix(undef, nx, ny)
   for iy in 1:ny
      for ix = 1:nx
         grid[ix,iy] = lines[iy][ix]
      end
   end
   moves::Vector{XY} = Vector()
   for line in lines[ny+1:end]
      for c in line
         push!(moves, dir_char(c))
      end
   end
   (grid, moves)
end

function find_robot(grid::Matrix{Char})
   findfirst(c->c=='@', grid)
end

function apply_move(grid::Matrix{Char}, move::XY, p0::XY)
   nbox = 0
   while true
      c1 = grid[p0+(nbox + 1)*move]
      if c1 == '#'
         return p0
      elseif c1 == 'O'
         nbox += 1
      elseif c1 == '.'
         p1 = p0+move
         grid[p0+move*(nbox+1)] = 'O'
         grid[p0] = '.'
         grid[p1] = '@'
         return p1
      else
         error("what?")
      end
   end
end

function apply_move2(grid::Matrix{Char}, move::XY, p0::XY)
   if move[2] == 0
      nbc = 0
      while true
         c1 = grid[p0+(nbc+1)*move]
         if c1 == '#'
            return p0
         elseif c1 == '[' || c1 == ']'
            nbc += 1
         elseif c1 == '.'
            p1 = p0 + move
            grid[p0] = '.'
            grid[p1] = '@'
            for ib in 1:nbc÷2
               grid[p0+(ib*2+0)*move] = move[1] == -1 ? ']' : '['
               grid[p0+(ib*2+1)*move] = move[1] == -1 ? '[' : ']'
            end
            return p1
         else
            error("what?")
         end
      end
   else
      pushrows::Vector{Set{XY}} = []
      push!(pushrows, Set([p0]))
      while true
         pushlocs = collect(p + move for p in pushrows[end])
         pushcells = collect(grid[p] for p in pushlocs)
         if findfirst(x->x=='#', pushcells) != nothing
            return p0
         elseif findfirst(x->x!='.', pushcells) == nothing
            for row in pushrows[end:-1:1]
               for cell in row
                  (grid[cell], grid[cell+move]) = ('.', grid[cell])
               end
            end
            return p0+move
         else
            nextrow::Set{XY} = Set()
            for loc in pushlocs
               c = grid[loc]
               if c == '['
                  push!(nextrow, loc)
                  push!(nextrow, loc+XY(1,0))
               elseif c == ']'
                  push!(nextrow, loc)
                  push!(nextrow, loc+XY(-1,0))
               end
            end
            push!(pushrows, nextrow)
         end
      end
   end
end

function score_pos(pos::XY)
   (pos[1]-1)+(pos[2]-1)*100
end

function score_grid(grid::Matrix{Char})
   sum(score_pos(box) for box in findall(c->c=='O', grid))
end

function score_grid2(grid::Matrix{Char})
   sum(score_pos(box) for box in findall(c->c=='[', grid))
end
 
function wide_grid(grid::Matrix{Char})
   nx = size(grid)[1]
   ny = size(grid)[2]
   grid2::Matrix{Char} = Matrix(undef, nx*2, ny)
   for ix in 1:nx
      for iy in 1:ny
         c1 = grid[ix, iy]
         if c1 == 'O'
            c2 = ('[', ']')
         elseif c1 == '@'
            c2 = ('@', '.')
         else
            c2 = (c1, c1)
         end
         (grid2[2ix-1, iy], grid2[2ix+0, iy]) = (c2[1], c2[2])
      end
   end
   grid2
end

function part1(lines)
   (grid, moves) = parse_lines(lines)
   pos = find_robot(grid)
   for move in moves
      pos = apply_move(grid, move, pos)
   end
   score_grid(grid)
end

function part2(lines)
   (grid, moves) = parse_lines(lines)
   grid2 = wide_grid(grid)
   pos = find_robot(grid2)
   for move in moves
      pos = apply_move2(grid2, move, pos)
   end
   score_grid2(grid2)
end

lines = readlines("../../data/advent2024/day15.txt")

println(part1(lines))
println(part2(lines))

include("advent.jl")
joke("Why was the snowman rummaging in a bag of carrots?",
     "Ur jnf cvpxvat uvf abfr")



