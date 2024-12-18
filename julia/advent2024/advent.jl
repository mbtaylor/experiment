
function joke(q, a13)
   println("Q: $(q)")
   println("A: $(rot13(a13))")
   println()
end

function rot13(txt)
   prod(c>='a'&&c<='z'||c>='A'&&c<='Z' ? c+(Int32(c)&0x1f<=13 ? +13 : -13) : c
        for c in txt)
end

joke("What's orange and could beat you in a fight?", "N fngfhzn jerfgyre")
joke("How does Darth Vader know what Luke got him for Christmas?",
     "Ur sryg uvf cerfrapr")
joke("Where does Santa stay when he’s on holiday?", "Va n ub-ub-ubgry")
joke("Why does Santa have three gardens?", "Fb ur pna ubr, ubr, ubr")
joke("What do you call Santa's little helpers?", "Fhobeqvangr pynhfrf")
joke("Daughter: Can I have a pony for Christmas?",
     "Qnq: Gur bira’f bayl ovt rabhtu sbe n ghexrl!")
joke("What did Adam say on the day before Christmas?",
     "Vg'f Puevfgznf, Rir")
joke("Why is it getting harder to buy Advent calendars?",
     "Gurve qnlf ner ahzorerq")
joke("How many letters are there in the Christmas alphabet?",
     "Gjragl svir - gurer'f ab Y")
joke("What happened to the man who stole an Advent calendar?",
     "Ur tbg 24 qnlf")
joke("Why are Christmas trees rubbish at knitting?",
     "Gurl nyjnlf qebc gurve arrqyrf!")
joke("What looks like half a Christmas tree?", "Gur bgure unys")
joke("I like decorating the Christmas tree, but taking it down confuses me...",
     "Vg'f ernyyl qvfbeanzragvat")
joke("How do snowmen make phone calls?", "Ba n fabjzbovyr")
joke("Why was the snowman rummaging in a bag of carrots?",
     "Ur jnf cvpxvat uvf abfr")
joke("Knock, knock! Who's there? Mary. Mary who?", "Znel Puevfgznf")
joke("Knock, knock! Who's there? Abbie. Abbie who?", "Noovr Arj Lrne")
joke("Why did nobody bid for Donner and Blitzen on eBay?",
     "Gurl jrer gjb qrre")
joke("What is Santa's favourite type of music?", "Jenc")
joke("How much does Santa have to pay to park his sleigh?",
     "Abguvat, vg'f ba gur ubhfr")
joke("What was the obnoxious reindeer called?", "Ehqr-bycu")
joke("How did Scrooge win the football game?",
     "Gur tubfg bs Puevfgznf cnffrq")
joke("Why did Rudolph have to attend summer school?",
     "Orpnhfr ur jrag qbja va uvfgbel")
joke("Why are Christmas trees so fond of the past?",
     "Orpnhfr gur cerfrag'f orarngu gurz")

