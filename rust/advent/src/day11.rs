
#[derive(Debug)]
struct Pos {
    x: usize,
    y: usize,
}

#[derive(Debug)]
struct Map {
    gals: Vec<Pos>,
    col_metrics: Vec<usize>,
    row_metrics: Vec<usize>,
}

impl Map {
    fn from(lines: Vec<String>, expansion: usize) -> Map {
        let mut gals: Vec<Pos> = Vec::new();
        for (iy, line) in lines.iter().enumerate() {
            for (ix, c) in line.as_bytes().iter().enumerate() {
                match c {
                    b'.' => {},
                    b'#' => { gals.push(Pos{x: ix, y: iy}); },
                    _ => panic!(),
                }
            }
        }
        let xdim = lines[0].as_bytes().len();
        let ydim = lines.len();
        let mut col_counts = Vec::new();
        let mut row_counts = Vec::new();
        col_counts.resize(xdim, 0);
        row_counts.resize(ydim, 0);
        for gal in &gals {
            col_counts[gal.x] += 1;
            row_counts[gal.y] += 1;
        }
        let col_metrics = col_counts.iter()
                         .map(|c| if c == &0 {expansion} else {1})
                         .collect();
        let row_metrics = row_counts.iter()
                         .map(|c| if c == &0 {expansion} else {1})
                         .collect();
        Map{gals, col_metrics, row_metrics}
    }
    fn dim_dist(d1: usize, d2: usize, metrics: &Vec<usize>) -> i64 {
        let mut dist = 0;
        let range = if d1 < d2 { d1..d2 } else { d2..d1 };
        for c in range {
            dist += metrics[c] as i64;
        }
        dist
    }
    fn dist(&self, pos1: &Pos, pos2: &Pos) -> i64 {
        Self::dim_dist(pos1.x, pos2.x, &self.col_metrics) +
        Self::dim_dist(pos1.y, pos2.y, &self.row_metrics)
    }
}

pub fn calc11a(lines: Vec<String>) -> i64 {
    let map = Map::from(lines, 2);
    let mut tot = 0;
    for (i1, g1) in map.gals.iter().enumerate() {
        for (i2, g2) in map.gals.iter().take(i1).enumerate() {
            tot += map.dist(g1, g2);
        }
    }
    tot
}

pub fn calc11b(lines: Vec<String>) -> i64 {
    let map = Map::from(lines, 1000000);
    let mut tot = 0;
    for (i1, g1) in map.gals.iter().enumerate() {
        for (i2, g2) in map.gals.iter().take(i1).enumerate() {
            tot += map.dist(g1, g2);
        }
    }
    tot
}
