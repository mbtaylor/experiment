

const Pair = NTuple{2,String}

function read_pair(line)
   m = match(r"([a-z][a-z])-([a-z][a-z])", line)
   Tuple(sort(m.captures))
end

function read_pairs(lines)
   lines .|> read_pair
end

function find_triples(pairs)
   triples::Vector{NTuple{3, String}} = []
   for pair1 in pairs
      (c1, c2) = pair1
      for pair2 in pairs
         if pair2[1] == c2
            c3 = pair2[2]
            for pair3 in pairs
               if pair3[2] == c3 && pair3[1] == c1
                  push!(triples, (c1, c2, c3))
               end
            end
         end
      end
   end
   triples
end

function part1(lines)
   triples = lines |> read_pairs |> find_triples
   length(filter(t -> t[1][1] == 't' || t[2][1] == 't' || t[3][1] == 't',
                 triples))
end

lines = readlines("../../data/advent2024/day23.txt")

println(part1(lines))

