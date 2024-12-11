

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

function part1(line)
   labels = to_labels(line)
   stones = blinks(labels, 25)
   length(stones)
#  stones .|> s->parse(Int64, s)
end

line = readline("../../data/advent2024/day11.txt")
labels = to_labels(line)

println(part1(line))

