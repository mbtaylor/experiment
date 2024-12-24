
const Pair = NTuple{2,String}

function read_pair(line)
   match(r"([a-z][a-z])-([a-z][a-z])", line).captures .|> String |> sort |> Tuple
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

function in_party(pairs::Set{NTuple{2,String}}, party::Set{String},
                  node::String)
   for p in party
      if Tuple(sort([p, node])) ∉ pairs
         return false
      end
   end
   true
end

function extend_party(pairs::Set{NTuple{2,String}}, nodes::Vector{String},
                      party::Set{String})
   iextra = findfirst(n->in_party(pairs, party, n), nodes)
   if iextra == nothing
      party
   else
      party1 = copy(party)
      push!(party1, nodes[iextra])
      extend_party(pairs, nodes, party1)
   end
end

function find_parties(pairs)
   nodes::Vector{String} = []
   for p in pairs
      push!(nodes, p[1])
      push!(nodes, p[2])
   end
   parties::Set{Set{String}} = Set()
   for p in pairs
      party = extend_party(pairs, nodes, Set(p))
      push!(parties, party)
   end
   parties
end


function part1(lines)
   triples = lines |> read_pairs |> find_triples
   length(filter(t -> t[1][1] == 't' || t[2][1] == 't' || t[3][1] == 't',
                 triples))
end

function part2(lines)
   parties = lines |> read_pairs |> Set |> find_parties |> collect
   maxparty = parties[findmax(length, parties)[2]]
   join(sort(collect(maxparty)), ",")
end

lines = readlines("../../data/advent2024/day23.txt")

println(part1(lines))
println(part2(lines))

# display(lines |> read_pairs |> Set |> find_parties)

