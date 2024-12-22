
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

function code_sequence(pad::Matrix{Char}, pos0::Vector{Int}, code::String)
   if length(code) > 0
      c1 = code[1]
      seqs = []
      for xf in (true, false)
         pos1 = copy(pos0)
         bs = butt_sequence(pad, pos1, c1, xf)
         if bs != nothing
            push!(seqs, bs * code_sequence(pad, pos1, code[2:end]))
         end
      end
      return argmin(length, seqs)
   else
      return ""
   end
end

function part1(lines)
   tot = 0
   for line in lines
      num = parse(Int, match(r"([0-9]+)", line).captures[1])
      seq1 = code_sequence(npad, findkey('A', npad), line)
      seq2 = code_sequence(dpad, findkey('A', dpad), seq1)
      seq3 = code_sequence(dpad, findkey('A', dpad), seq2)
      tot += length(seq3) * num
   end
   tot
end

lines = readlines("../../data/advent2024/day21.txt")

println(part1(lines))

