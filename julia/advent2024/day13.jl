
struct XY
   x::Int64
   y::Int64
end
struct Game
   A::XY
   B::XY
   P::XY
end

function read_xy(regex2::Regex, txt::String)
   m = match(regex2, txt)
   XY(parse(Int64, m.captures[1]),
      parse(Int64, m.captures[2]))
end

function to_games1(lines)
   games::Vector{Game} = Vector()
   for i in 1:4:length(lines)
      A = read_xy(r"Button A: X[+]([0-9]+), Y[+]([0-9]+)", lines[i+0])
      B = read_xy(r"Button B: X[+]([0-9]+), Y[+]([0-9]+)", lines[i+1])
      P = read_xy(r"Prize: X=([0-9]+), Y=([0-9]+)", lines[i+2])
      push!(games, Game(A, B, P))
   end
   games
end

offset2 = 10000000000000
game2(game) = Game(game.A, game.B, XY(game.P.x+offset2, game.P.y+offset2))

function to_games2(lines)
   to_games1(lines) .|> game2
end

function solve(game)
   m = [game.A.x game.B.x; game.A.y game.B.y]
   p = [game.P.x; game.P.y]
   (da, db) = inv(m) * p
   # I bet I should be using Rational here
   (na, nb) = (da, db) .|> round .|> Int64
   m * [na; nb] == p ? (na, nb) : nothing
end

function cost(solution)
   solution[1] * 3 + solution[2] * 1
end

function part1(lines)
   games = to_games1(lines)
   solutions = filter(s -> s!=nothing, solve.(games))
   sum(cost, solutions)
end

function part2(lines)
   games = to_games2(lines)
   solutions = filter(s -> s!=nothing, solve.(games))
   sum(cost, solutions)
end

lines = readlines("../../data/advent2024/day13.txt")

println(part1(lines))
println(part2(lines))

