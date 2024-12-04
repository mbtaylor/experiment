
struct WordSearch <: AbstractMatrix{Char}
   lines::Vector{String}
   pad::Int32
   w0::Int32
   h0::Int32
end
WordSearch(lines, pad) = WordSearch(lines, pad, length(lines[1]), length(lines))

# Implement Abstract Array interface
# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array
Base.size(ws::WordSearch) = (ws.w0 + 2 * ws.pad, ws.h0 + 2 * ws.pad)
Base.getindex(ws::WordSearch, i::Int, j::Int) = begin
   pi = i - ws.pad
   pj = j - ws.pad
   pi > 0 && pi <= ws.w0 && pj > 0 && pj <= ws.h0 ? ws.lines[pj][pi] : ' '
end
positions(ws::WordSearch) = begin
   ((i, j) for i in ws.pad+1:size(ws, 1)-ws.pad,
               j in ws.pad+1:size(ws, 2)-ws.pad)
end

function slices(leng::Int64)
   dirs = collect((dx,dy) for dx in -1:1, dy in -1:1 if dx!=0 || dy!=0)[1:end]
   map(dir->collect((i*dir[1],i*dir[2]) for i in 0:leng-1), dirs)
end

is_ms(c1, c2) = (c1 == 'M' && c2 == 'S') || (c1 == 'S' && c2 == 'M')

function part1(lines)
   leng = 4;
   pad = leng
   grid = WordSearch(lines, pad)
   vecs = slices(leng)
   tot = 0
   for (i, j) in positions(grid)
      for vec in vecs
         word = String(collect(grid[i+vec[k][1], j+vec[k][2]] for k in 1:leng))
         if word == "XMAS"
            tot += 1
         end
      end
   end
   tot
end

function part2(lines)
   pad = 1
   grid = WordSearch(lines, pad)
   tot = 0
   for (i, j) in positions(grid)
      if grid[i, j] == 'A'
         if ( is_ms(grid[i+1,j+1], grid[i-1,j-1]) &&
              is_ms(grid[i-1,j+1], grid[i+1,j-1]) )
             tot += 1
         end
      end
   end
   tot
end

lines = readlines("../../data/advent2024/day04.txt")

println(part1(lines))
println(part2(lines))
 

