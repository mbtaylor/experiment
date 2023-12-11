
struct Lagrange {
    n: usize,
    xs: Vec<i64>,
    ys: Vec<i64>,
}

impl Lagrange {
    fn from(xs: Vec<i64>, ys: Vec<i64>) -> Lagrange {
        Lagrange{n: xs.len(), xs, ys}
    }
    fn calc(&self, x: i64) -> i64 {
        let mut sum: i64 = 0;
        for j in 0..self.n {
            let mut l: f64 = 1.;
            for m in 0..self.n {
                if m != j {
                    l *= ((x - self.xs[m]) as f64)
                        /((self.xs[j] - self.xs[m]) as f64);
                }
            }
            sum += self.ys[j] * l.round() as i64;
        }
        sum
    }
}

pub fn calc09a(lines: Vec<String>) -> i64 {
    let mut tot = 0;
    for line in lines {
        let ys: Vec<i64> =
            line.split_whitespace().map(|x| x.parse().unwrap()).collect();
        let n = ys.len();
        let mut xs: Vec<i64> = Vec::with_capacity(n);
        for i in 0..n {
            xs.push(i as i64);
        }
        let lag = Lagrange::from(xs, ys);
        let next = lag.calc(n as i64);
        tot += next;
    }
    tot
}
