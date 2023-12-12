
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

pub fn calc12a(lines: Vec<String>) -> i64 {
    for line in lines {
        let mut split = line.split_whitespace();
        let map = split.next().unwrap();
        let counts = split.next().unwrap();
        let counts: Vec<i64> =
            counts.split(',').map(|x| x.parse().unwrap()).collect();
    }
    ncr(5,3)
}
