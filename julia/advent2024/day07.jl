
struct Sum
   answer::Int64
   operands::Vector{Int64}
end

function Sum(line::String)
   m = match(r"([0-9]+): ([0-9 ]+)", line)
   answer = parse(Int64, m.captures[1])
   operands = map(s -> parse(Int64, s), split(m.captures[2]))
   Sum(answer, operands)
end
Base.show(io::IO, sum::Sum) = print(io, sum.answer, ": ", sum.operands)

function calculate(ops, flagint)
   nop = length(ops)
   s = ops[1]
   for i = 0:(nop-2)
      op = ops[i+2]
      s = ((flagint >> i & 1) == 0) ? s * op : s + op
   end
   s
end

function calculate3(ops, opflags3)
   nop = length(ops)
   s = ops[1]
   for i = 0:(nop-2)
      op = ops[i+2]
      optype = (opflags3÷(3^i))%3
      if optype == 0
         s = s + op
      elseif optype == 1
         s = s * op
      elseif optype == 2
         s = parse(Int64, "$(s)$(op)")
      else
         error("Uh-oh")
      end
   end
   s
end

function is_possible(sum::Sum)
   nop = length(sum.operands)
   for i in 0:(1<<(nop-1))
      if calculate(sum.operands, i) == sum.answer
         return true
      end
   end
   false
end

function is_possible3(sum::Sum)
   nop = length(sum.operands)
   for i in 0:3^(nop-1)
      if calculate3(sum.operands, i) == sum.answer
         return true
      end
   end
   false
end

function part1(sums)
   sum(s.answer for s in sums if is_possible(s))
end

function part2(sums)
   sum(s.answer for s in sums if is_possible3(s))
end

lines = readlines("../../data/advent2024/day07.txt")
sums = collect(map(l -> Sum(l), lines))

println(part1(sums))
println(part2(sums))

include("advent.jl")
joke("What did Adam say on the day before Christmas?",
     "Vg'f Puevfgznf, Rir")

