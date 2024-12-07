
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

function is_possible(sum::Sum)
   nop = length(sum.operands)
   for i in 0:(1<<(nop-1))
      if calculate(sum.operands, i) == sum.answer
         return true
      end
   end
   return false
end

function part1(sums)
   sum(s.answer for s in sums if is_possible(s))
end

lines = readlines("../../data/advent2024/day07.txt")
sums = collect(map(l -> Sum(l), lines))

println(part1(sums))

