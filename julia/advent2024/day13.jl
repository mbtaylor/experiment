
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
   m = map(Rational, [game.A.x game.B.x; game.A.y game.B.y])
   p = map(Rational, [game.P.x; game.P.y])
   (ra, rb) = inv(m) * p
   (denominator(ra) == 1 && denominator(rb) == 1 ? (Int64(ra), Int64(rb)) 
                                                 : nothing)
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

include("advent.jl")
joke("I like decorating the Christmas tree, but taking it down confuses me...",
     "Vg'f ernyyl qvfbeanzragvat")


