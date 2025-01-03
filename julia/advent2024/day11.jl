

to_numbers = line -> line |> split .|> s->parse(Int64, s)
to_labels = line -> line |> split .|> String
strip_zeros = s -> replace(s, r"^0+([0-9]+)" => s"\1")

function blink(ins::Vector{String})
   outs::Vector{String} = []
   for n in ins
      if n == "0"
         push!(outs, "1")
      elseif length(n) %2 == 0
         nc = length(n) ÷ 2
         push!(outs, strip_zeros(n[1:nc]))
         push!(outs, strip_zeros(n[nc+1:end]))
      else
         push!(outs, repr(parse(Int64, n)*2024))
      end
   end
   outs
end

function blinks(labels::Vector{String}, count::Int64)
   for i in 1:count
      labels = blink(labels)
   end
   labels
end

function count_stones(db::Dict{Tuple{String,Int64}, Int64},
                      stone::String, nblink::Int64)
   key = (stone, nblink)
   if nblink == 0
      return 1
   elseif haskey(db, key)
      return db[key]
   else
      if stone == "0"
         value = count_stones(db, "1", nblink-1)
      elseif (length(stone) % 2 == 0)
         nc = length(stone) ÷ 2
         value = (count_stones(db, strip_zeros(stone[1:nc]), nblink-1) +
                  count_stones(db, strip_zeros(stone[nc+1:end]), nblink-1))
      else
         value = count_stones(db, repr(parse(Int64, stone)*2024), nblink-1)
      end
      db[key] = value
      return value
   end
end

function slow_count(line::String, nblink::Int)
   labels = to_labels(line)
   stones = blinks(labels, nblink)
   length(stones)
end

function fast_count(line::String, nblink::Int)
   labels = to_labels(line)
   db::Dict{Tuple{String,Int64}, Int64} = Dict()
   sum(map(s->count_stones(db, s, nblink), labels))
end

part1(line) = fast_count(line, 25)
part2(line) = fast_count(line, 75)

line = readline("../../data/advent2024/day11.txt")
labels = to_labels(line)

println(part1(line))
println(part2(line))

include("advent.jl")
joke("Why are Christmas trees rubbish at knitting?",
     "Gurl nyjnlf qebc gurve arrqyrf!")


