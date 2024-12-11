

to_numbers = line -> line |> split .|> s->parse(Int64, s)
to_labels = line -> line |> split .|> String
strip_zeros = s -> replace(s, r"^0+([0-9]+)" => s"\1")

mutable struct BlinkSeq
   counts::Vector{Int64}
   stones::Vector{String}
end
BlinkSeq(stone::String) = BlinkSeq([1], [stone])

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

function add_blink(seq::BlinkSeq)
   seq.stones = blink(seq.stones)
   push!(seq.counts, length(seq.stones))
end

function count_stones(db::Dict{String, BlinkSeq}, stone::String, nblink::Int64)
   if !haskey(db, stone)
      db[stone] = BlinkSeq(stone)
   end
   seq = get(db, stone, nothing)
   while length(seq.counts) <= nblink
      add_blink(seq)
   end
   seq.counts[nblink+1]
end

function part1(line::String, nblink::Int)
   labels = to_labels(line)
   stones = blinks(labels, nblink)
   length(stones)
end

function part2(line::String, nblink::Int)
   labels = to_labels(line)
   db::Dict{String, BlinkSeq} = Dict()
   sum(map(s->count_stones(db, s, nblink), labels))
end

line = readline("../../data/advent2024/day11.txt")
labels = to_labels(line)

println(part1(line, 25))
println(part2(line, 25))

