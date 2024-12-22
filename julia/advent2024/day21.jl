
npad = ['7' '8' '9'
        '4' '5' '6'
        '1' '2' '3'
        ' ' '0' 'A']

dpad = [' ' '^' 'A'
        '<' 'v' '>']

# 7 8 9
# 4 5 6
# 1 2 3
#   0 A

#   ^ A
# < v >

function findkey(c::Char, pad::Matrix{Char})
   pos = findfirst(c0->c0==c, pad)
   [pos[2], pos[1]]
end

function xmove(pad::Matrix{Char}, pos::Vector{Int}, xoff::Int)
   seq::Vector{Char} = Vector()
   while xoff > 0
      push!(seq, '>')
      xoff -= 1
      pos[1] += 1
   end
   while xoff < 0
      push!(seq, '<')
      xoff += 1
      pos[1] -= 1
   end
   seq
end

function ymove(pad::Matrix{Char}, pos::Vector{Int}, yoff::Int)
   seq::Vector{Char} = Vector()
   while yoff > 0
      push!(seq, 'v')
      yoff -= 1
      pos[2] += 1
   end
   while yoff < 0
      push!(seq, '^')
      yoff += 1
      pos[2] -= 1
   end
   seq
end

function butt_sequence(pad::Matrix{Char}, pos::Vector{Int}, c::Char,
                       xfirst::Bool)
   (xoff, yoff) = findkey(c, pad) - pos
   seq::Vector{Char} = []
   if xfirst
      append!(seq, xmove(pad, pos, xoff))
      if pad[pos[2],pos[1]] == ' '
         return nothing
      end
      append!(seq, ymove(pad, pos, yoff))
   else
      append!(seq, ymove(pad, pos, yoff))
      if pad[pos[2],pos[1]] == ' '
         return nothing
      end
      append!(seq, xmove(pad, pos, xoff))
   end
   push!(seq, 'A')
   join(seq)
end

function code_sequence_recursive(pad::Matrix{Char}, pos0::Vector{Int},
                                 code::String,
                                 memo::Dict{Tuple{Vector{Int},String},String})
   if length(code) > 0
      key = (copy(pos0), code)
      if !haskey(memo, key)
         c1 = code[1]
         seqs = []
         # this could be replaced with something faster
         for xf in (true, false)
            pos1 = copy(pos0)
            bs = butt_sequence(pad, pos1, c1, xf)
            if bs != nothing
               push!(seqs, bs * code_sequence_recursive(pad, pos1, code[2:end],
                                                        memo))
            end
         end
         seq = argmin(length, seqs)
         memo[key] = seq
      end
      return memo[key]
   else
      return ""
   end
end

# wrong answer
function code_sequence_iterative(pad::Matrix{Char}, pos0::Vector{Int},
                                 code::String,
                                 memo::Dict{Tuple{Vector{Int},String},String})
   key = (copy(pos0), code)
   if !haskey(memo, key)
      seq::Vector{Char} = []
      for c in code
         seqs = []
         for xf in (true, false)
            pos1 = copy(pos0)
            bs = butt_sequence(pad, pos1, c, xf)
            if bs != nothing
               push!(seqs, bs)
            end
         end
         append!(seq, k for k in argmin(length, seqs))
      end
      memo[key] = join(seq)
   end
   memo[key]
end

function chain_of_robots(lines, ndpad,
                         dmemo::Dict{Tuple{Vector{Int},String},String})
   tot = 0
   csfunc = code_sequence_recursive
   # csfunc = code_sequence_iterative
   nmemo::Dict{Tuple{Vector{Int},String},String} = Dict()
   for line in lines
      num = parse(Int, match(r"([0-9]+)", line).captures[1])
      seq = csfunc(npad, findkey('A', npad), line, nmemo)
      for i in 1:ndpad
         seq = csfunc(dpad, findkey('A', dpad), seq, dmemo)
      end
      tot += length(seq) * num
   end
   tot
end


function part1(lines)
   dmemo::Dict{Tuple{Vector{Int},String},String} = Dict()
   chain_of_robots(lines, 2, dmemo)
end

# Recursion depth is far too large - StackOverflowErrors
# I think I need to calculate the length of these sequences
# without calculating the sequences themselves.  But I don't know how.
function part2(lines)
   dmemo::Dict{Tuple{Vector{Int},String},String} = Dict()
   for i in 1:25
      println(i, "\t", chain_of_robots(lines, i, dmemo))
   end
end

lines = readlines("../../data/advent2024/day21.txt")

println(part1(lines))
println(part2(lines))

