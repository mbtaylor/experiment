
function joke(q, a13)
   println("Q: $(q)")
   println("A: $(rot13(a13))")
   println()
end

function rot13(txt)
   prod(c>='a'&&c<='z'||c>='A'&&c<='Z' ? c+(Int32(c)&0x1f<=13 ? +13 : -13) : c
        for c in txt)
end

