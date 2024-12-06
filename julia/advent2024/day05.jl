
struct Rule
   lo::Int64
   hi::Int64
end
Base.show(io::IO, rule::Rule) = print(io, "$(rule.lo)|$(rule.hi)")

struct Update
   pages::Vector{Int64}
end
Base.show(io::IO, update::Update) = print(io, update.pages)
middle(update::Update) = update.pages[(length(update.pages)+1)÷2]

function read_proto(lines)
   rules::Vector{Rule} = []
   updates::Vector{Update} = []
   for line in lines
      rm = match(r"([0-9]+)\|([0-9]+)", line)
      if !isnothing(rm)
          push!(rules, Rule(parse(Int64, rm.captures[1]),
                            parse(Int64, rm.captures[2])))
      elseif occursin(r",", line)
          push!(updates,
                Update(collect(map(s -> parse(Int64, s),
                                   split(line, ",")))))
      end
   end
   (rules, updates)
end

function is_ordered(rules::Vector{Rule}, update::Update)
   for rule in rules
      ilo = findfirst(x->x==rule.lo, update.pages)
      ihi = findfirst(x->x==rule.hi, update.pages)
      if ilo !== nothing && ihi !== nothing && ilo > ihi
          return false
      end
   end
   true
end

function page_order(rules::Vector{Rule})
   rules = copy(rules)
   seq::Vector{Int64} = []
   # Look for a number that only appears on the right - it's the highest
   ihi = findfirst(r -> findfirst(q->q.lo==r.hi, rules) == nothing, rules)
   hi = rules[ihi].hi
   while length(rules) > 0
      ilo = findfirst(r -> findfirst(q->q.hi==r.lo, rules) == nothing, rules)
      lo = rules[ilo].lo
      push!(seq, lo)
      filter!(r -> r.lo != lo, rules)
   end
   push!(seq, hi)
   seq
end

function reorder(update::Update, order::Vector{Int64})
   out::Vector{Int64} = []
   for p in order
      if findfirst(r->r==p, update.pages) != nothing
         push!(out, p)
      end
   end
   Update(out)
end

function part1(lines)
   (rules, updates) = read_proto(lines)
   sum(middle(up) for up in updates if is_ordered(rules, up))
end

function part2(lines)
   (rules, updates) = read_proto(lines)
   order = page_order(rules)
#println("order: ", order)
#for up in updates
#  println(reorder(up, order))
#end
   sum(middle(reorder(up, order)) for up in updates if !is_ordered(rules, up))
end

function diag(lines)
   (rules, updates) = read_proto(lines)
   for i in 10:99
     nlo = length(filter(r->r.lo==i, rules))
     nhi = length(filter(r->r.hi==i, rules))
     if nlo != 0 || nhi != 0
        println(i, "\t", nlo, "\t", nhi)
     end
   end
end

lines = readlines("../../data/advent2024/test05.txt")

# diag(lines)

println(part1(lines))

println(part2(lines))



