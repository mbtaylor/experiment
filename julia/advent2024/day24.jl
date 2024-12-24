
struct Machine
   inits::Vector{Tuple{String,Bool}}
   gates::Vector{Tuple{String,Function,String,String}}
end

function op_translate(opname)
   if opname == "AND"
      (a,b) -> a && b        # why can't I just use '&& here?
   elseif opname == "OR"
      (a,b) -> a || b
   elseif opname == "XOR"
      ⊻
   else
      error("unsupported operation: $(opname)")
   end
end

function read_machine(lines)
   inits::Vector{Tuple{String,Bool}} = []
   gates::Vector{Tuple{String,Function,String,String}} = []
   r_wire = "([a-z0-9]+)"
   for line in lines
      m_init = match(Regex("$(r_wire): ([01])"), line)
      if m_init != nothing
         caps = m_init.captures
         push!(inits, (caps[1], caps[2]=="1"))
      end
      m_gate = match(Regex("$(r_wire) (OR|AND|XOR) $(r_wire) -> $(r_wire)"),
                     line)
      if m_gate != nothing
         caps = m_gate.captures
         push!(gates, (caps[1], op_translate(caps[2]), caps[3], caps[4]))
      end
   end
   Machine(inits, gates)
end

function part1(lines)
   machine = read_machine(lines)
   states::Dict{String,Bool} = Dict()
   zwires_set::Set{String} = Set()
   for (wire, state) in machine.inits
      states[wire] = state
      if wire[1] == 'z'
         push!(zwires_set, wire)
      end
   end
   gates = Set(machine.gates)
   for (w1, op, w2, w3) in gates
      for w in (w1, w2, w3)
         if w[1] == 'z'
            push!(zwires_set, w)
         end
      end
   end
   zwires = zwires_set |> collect |> sort
   while !all(w -> haskey(states, w), zwires)
      for gate in gates
         (w1, op, w2, w3) = gate
         if haskey(states, w1) && haskey(states, w2)
            states[w3] = op(states[w1], states[w2])
            delete!(gates, gate)
         end
      end
   end
   result = 0
   for w in reverse(zwires)
      result = result << 1
      if states[w]
         result = result | 1
      end
   end
   result
end

lines = readlines("../../data/advent2024/day24.txt")

println(part1(lines))

