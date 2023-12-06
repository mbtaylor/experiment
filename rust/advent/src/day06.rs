use std::iter::Iterator;

struct Race {
    time: f64,
    dist: f64,
}

fn read_nums(line: &str) -> Vec<f64> {
    line.split_whitespace()
        .skip(1)
        .map(|x| x.parse().unwrap())
        .collect()
}

pub fn calc06a(lines: Vec<String>) -> i64 {
    let mut races = Vec::new();
    for (t, d) in read_nums(&lines[0][..]).iter()
                 .zip(read_nums(&lines[1][..]).iter()) {
        races.push(Race{time: *t, dist: *d});
    }
    let mut calc = 1;
    for race in races {
        let t = race.time;
        let d = race.dist;
        let discrim = (t*t - 4.0 * d).sqrt();
        let tlo = ( t - discrim ) * 0.5;
        let thi = ( t + discrim ) * 0.5;
        let rlo = tlo.ceil() as i64;
        let rhi = thi.floor() as i64;
        let slo = if rlo as f64 == tlo { rlo + 1 } else { rlo };
        let shi = if rhi as f64 == thi { rhi - 1 } else { rhi };
        let c = shi - slo + 1;
        println!("    {} -> {}: {}", rlo, rhi, c);
        calc *= c;
    }
    calc
}
