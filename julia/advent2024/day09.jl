
mutable struct Chunk
   const inode::Union{Nothing, Int64}
   count::Int64
end

function read_chunks(line)
   chunks::Vector{Chunk} = []
   inode = 0
   for m in eachmatch(r"([0-9])([0-9]?)", line)
      (d1, d2) = m.captures
      push!(chunks, Chunk(inode, parse(Int64, d1)))
      if d2 != ""
         push!(chunks, Chunk(nothing, parse(Int64, d2)))
      end
      inode += 1
   end
   chunks
end

function checksum(chunks::Vector{Chunk})
   ipos = 0
   sum = 0
   for c in chunks
      for i in 1:c.count
         if c.inode != nothing
            sum += ipos * c.inode
         end
         ipos += 1
      end
   end
   sum
end

function part1(line)
   input = read_chunks(line)
   output::Vector{Chunk} = []
   last = 
   for cin in input
      if cin.inode != nothing
         push!(output, cin)
      else
         for i in 1:cin.count
            while input[end].inode == nothing || input[end].count == 0
               pop!(input)
            end
            inode = input[end].inode
            input[end].count -= 1
            if output[end].inode == inode
               output[end].count += 1
            else
               push!(output, Chunk(inode, 1))
            end
         end
      end
   end
   checksum(output)
end

function part2(line)
   chunks = read_chunks(line)
   i = length(chunks)
   while i > 0
      if chunks[i].inode != nothing
         ichunk = chunks[i]
         for j in 1:i
            if chunks[j].inode == nothing && chunks[j].count >= ichunk.count
               chunks[j].count -= ichunk.count
               chunks[i] = Chunk(nothing, ichunk.count)
               insert!(chunks, j, ichunk)
               break
            end
         end
      end
      i -= 1
   end
   checksum(chunks)
end


function print_chunks(chunks::Vector{Chunk})
   for c in chunks
      print((c.inode == nothing ? "." : repr(c.inode))^c.count)
   end
   println()
end

line = readline("../../data/advent2024/day09.txt")

println(part1(line))
println(part2(line))

include("advent.jl")
joke("How many letters are there in the Christmas alphabet?",
     "Gjragl svir - gurer'f ab Y")


