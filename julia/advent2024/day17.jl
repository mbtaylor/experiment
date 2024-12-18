
Base.@kwdef mutable struct Machine
   A::Int64
   B::Int64
   C::Int64
   program::Vector{UInt8}
   pointer::Int64
   output::Vector{UInt8}
end

function Base.copy(m::Machine)
   Machine(m.A, m.B, m.C, copy(m.program), m.pointer, copy(m.output))
end

function combo(m::Machine, operand::UInt8)
   if operand < 4
      operand
   elseif operand == 4
      m.A
   elseif operand == 5
      m.B
   elseif operand == 6
      m.C
   else
      nothing
   end
end

function adv(m::Machine, operand::UInt8)
   m.A = m.A >> combo(m, operand)
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
   push!(m.output, combo(m, operand) & 0x7)
end

function bdv(m::Machine, operand::UInt8)
   m.B = m.A >> combo(m, operand)
end

function cdv(m::Machine, operand::UInt8)
   m.C = m.A >> combo(m, operand)
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

function run_machine(m::Machine)
   while m.pointer < length(m.program)
      (instruction, operand) = (m.program[m.pointer+1], m.program[m.pointer+2])
      m.pointer += 2
      opcodes[instruction+1](m, operand)
   end
end

function test_machine(m::Machine)
   while m.pointer < length(m.program)
      (instruction, operand) = (m.program[m.pointer+1], m.program[m.pointer+2])
      m.pointer += 2
      opcodes[instruction+1](m, operand)
      nout = length(m.output)
      if nout > 0 && m.output[nout] != m.program[nout]
         return nout - 1
      end
   end
   return length(m.program)
end

function part1(lines)
   machine = read_machine(lines)
   run_machine(machine)
   join(machine.output, ",")
end

function part2_bruteforce(lines)
   m0 = read_machine(lines)
   m = copy(m0)
   nprog = length(m.program)
   for a in 8^(nprog-1):8^nprog
      m = copy(m0)
      m.A = a
      n = test_machine(m)
      if n >= 8
         println(n, "\t", string(a, base=16))
      end
      if n == nprog
         return a
      end
      a += 1
   end
end

function part2_bad2(lines)
   m0 = read_machine(lines)
   nprog = length(m.program)
   tails = [
      0x88f01, 0x80f01, 0x88f09, 0x80f09, 0x8899a, 0x8099a, 0x8699a, 0x8f309, 0x8089b,
      0x98f01, 0x90f01, 0x98f09, 0x90f09, 0x9899a, 0x9099a, 0x9699a, 0x9f309, 0x9089b,
   ]

   Threads.@threads for tail in tails
   # for tail in tails
      for head in ((8^(nprog-1))>>20):((8^nprog)>>20)
         a = head << 20 | tail
         m = copy(m0)
         m.A = a
         n = test_machine(m)
         if n >= 14
            println(n, "\t", string(a, base=16))
         end
         if n == nprog
            println("Yes: " + a)
            return a
         end
      end
   end
end

lines = readlines("../../data/advent2024/day17.txt")

println(part1(lines))

# Terrible solution, but it got there in a few hours.
part2_bad2(lines)

# This is a right answer; but not the lowest
# 0x632713b8f309
# m.A = 109019485762313
# This one's smaller
# 0x63271329089b
m.A = 109019476330651
m = read_machine(lines)
run_machine(m)
println(m)

