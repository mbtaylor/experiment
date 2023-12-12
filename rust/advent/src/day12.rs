
struct Arrangement {
    istarts: Vec<usize>,
}

impl Arrangement {
    // need to implement this.  Should be easy.
    fn matches(&self, map: &str) -> bool {
        false
    }
}

pub fn ncr(n: i64, r: i64) -> i64 {
    fact(n) / (fact(r) * fact(n-r))
}

pub fn fact(k: i64) -> i64 {
    let mut f = 1;
    for i in 0..k {
        f *= i+1;
    }
    f
}

// no - the counts arg should be a slice to support recursion.  How?
// also, it would be better if the output was an iterator.  How?
fn possible_arrangements(counts: &Vec<usize>, npos: usize) -> Vec<Arrangement> {
    let arrs = Vec::new();
    // need to implement this - recursively?
    arrs
}

pub fn calc12a(lines: Vec<String>) -> i64 {
    let mut tot = 0;
    for line in lines {
        let mut split = line.split_whitespace();
        let map = split.next().unwrap();
        let npos = map.len();
        let counts: Vec<usize> =
            split.next().unwrap()
           .split(',').map(|x| x.parse().unwrap()).collect();
        let arrs = possible_arrangements(&counts, npos);
        let c = arrs.iter().filter(|x| x.matches(map)).count() as i64;
        tot += c;
    }
    tot
}
