
Base.@kwdef mutable struct Machine
   A::Int64
   B::Int64
   C::Int64
   program::Vector{UInt8}
   pointer::Int64
   output::Vector{UInt8}
end

function combo(m::Machine, operand::UInt8)
   if operand < 4
      operand
   else if operand == 5
      m.A
   else if operand == 6
      m.B
   else if operand == 7
      m.C
   else
      nothing
   end
end

function adv(m::Machine, operand::UInt8)
   m.A = m.A << combo(m, operand)
end

function bxl(m::Machine, operand::UInt8)
   m.B = m.B ⊻ operand
end

function bst(m::Machine, operand::UInt8)
   m.B = combo(m, operand) & 0x7
end

function jnz(m::Machine, operand::UInt8)
   if m.A != 0
      m.pointer = operand
   end
end

function bxc(m::Machine, operand::UInt8)
   m.B = m.B ⊻ m.C
end

function out(m::Machine, operand::UInt8)
   push!(m.output, combo(m, operand))
end

function bdv(m::Machine, operand::UInt8)
   m.B = m.A << combo(m, operand)
end

function cdv(m::Machine, operand::UInt8)
   m.C = m.A << combo(m, operand)
end

opcodes = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]

function read_machine(lines)
   atts::Dict{Symbol,Any} = Dict()
   for line in lines
       rmatch = match(r"Register ([ABC]): ([0-9]+)", line)
       if rmatch != nothing
          rcaps = rmatch.captures
          atts[Meta.parse(rcaps[1])] = parse(Int64, rcaps[2])
       end
       pmatch = match(r"Program: ([0-9,]+)", line)
       if pmatch != nothing
          atts[:program] = split(pmatch.captures[1],",") .|> s->parse(UInt8, s)
       end
   end
   atts[:pointer] = 0
   atts[:output] = []
   Machine(; atts...)
end

function run_machine(machine)
   while m.pointer < length(m.program)
      (instruction, operand) = (m.program[m.pointer], m.program[m.pointer+1])
      m.pointer += 2
      opcodes[instruction-1](m, operand)
   end
end

lines = readlines("../../data/advent2024/test17.txt")

println(read_machine(lines))

