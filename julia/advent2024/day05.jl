
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

function part1(lines)
   (rules, updates) = read_proto(lines)
   sum(middle(up) for up in updates if is_ordered(rules, up))
end

lines = readlines("../../data/advent2024/day05.txt")

println(part1(lines))


