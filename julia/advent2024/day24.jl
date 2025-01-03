
const Gate = Tuple{String,Function,String,String}
struct Machine
   inits::Vector{Tuple{String,Bool}}
   gates::Vector{Gate}
   nbit::Int
end

function op_translate(opname)
   if opname == "AND"
      (a,b) -> a && b        # why can't I just use '&&' here?
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
   nbit1 = 0
   for (reg, val) in inits
      xym = match(r"[xy]([0-9]+)", reg)
      if xym != nothing
         nbit1 = max(nbit1, parse(Int, xym.captures[1]))
      end
   end
   Machine(inits, gates, nbit1+1)
end

function swap_outputs(machine::Machine, ig1::Int, ig2::Int)
   gates = copy(machine.gates)
   g1 = gates[ig1]
   g2 = gates[ig2]
   gates[ig1] = (g1[1], g1[2], g1[3], g2[4])
   gates[ig2] = (g2[1], g2[2], g2[3], g1[4])
   Machine(machine.inits, gates, machine.nbit)
end

function find_swaps(machine::Machine, ibit::Int)
   ngate = length(machine.gates)
   swaps::Vector{Tuple{Int,Int}} = []
   for ig1 in 1:ngate
      for ig2 = 1:ig1-1
         m = swap_outputs(machine, ig1, ig2)
         if all(ib -> test_adder(m, ib), 1:ibit)
            push!(swaps, (ig1, ig2))
         end
      end
   end
   swaps
end

xs = ["x"*string(i, pad=2) for i in 0:44]
ys = ["y"*string(i, pad=2) for i in 0:44]
zs = ["z"*string(i, pad=2) for i in 0:45]

function test_adder_xy(machine::Machine, nbit::Int, x::Int, y::Int)
   mask = 1 << nbit - 1
   states::Dict{String,Bool} = Dict()
   for ibit in 1:machine.nbit
      states[xs[ibit]] = false
      states[ys[ibit]] = false
   end
   for ibit = 1:nbit
      states[xs[ibit]] = (x & 1 << (ibit-1)) != 0
      states[ys[ibit]] = (y & 1 << (ibit-1)) != 0
   end
   zwires = copy(zs[1:nbit+1])
   gates = Set(machine.gates)
   last_nz = 0
   while true
      for gate in gates
         (w1, op, w2, w3) = gate
         if haskey(states, w1) && haskey(states, w2)
            states[w3] = op(states[w1], states[w2])
            delete!(gates, gate)
         end
      end
      nz = count(w -> haskey(states, w), zwires)
      if nz == last_nz
         return false
      end
      last_nz = nz
      if nz == length(zwires)
         break
      end
   end
   z = 0
   for ibit in 0:nbit
      if states[zs[ibit+1]]
         z = z | 1 << ibit
      end
   end
   correct = (x & mask) + (y & mask) == z
# println("   $(x & mask) + $(y & mask) = $(z)  : $(correct)")
   correct
end

function test_adder(machine::Machine, nbit::Int)
   for x in [0, 0xffffffff]
      for y in [0, 0xffffffff]
         if !test_adder_xy(machine, nbit, x, y)
            return false
         end
      end
   end
   true
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

function part2(lines)
   machine = read_machine(lines)
   gates = machine.gates
   ngate = length(gates)
   machine = swap_outputs(machine, 95, 31)
   machine = swap_outputs(machine, 111, 26)
   for ibit in 1:machine.nbit
 println("bit $(ibit)")
      if ! test_adder(machine, ibit)
         swaps = find_swaps(machine, ibit)
 println(swaps)
 if length(swaps) > 0
         (ig1, ig2) = swaps[1]
         machine = swap_outputs(machine, ig1, ig2)
 end
      end
   end
end

lines = readlines("../../data/advent2024/day24.txt")

println(part1(lines))

println()

machine = read_machine(lines)
machine = swap_outputs(machine, 95, 31)
machine = swap_outputs(machine, 111, 26)
for i in 1:45
   println(i, ": ", test_adder(machine, i))
end

println(part2(lines))

include("advent.jl")
joke("Why did Rudolph have to attend summer school?",
     "Orpnhfr ur jrag qbja va uvfgbel")


# Looks like switches are:
#  95,31 (bit 10)
#  111,26 (bit 16)
