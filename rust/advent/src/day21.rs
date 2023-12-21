use std::collections::HashMap;
use std::collections::HashSet;

struct Field {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

#[derive(Eq,PartialEq,Hash,Clone,Copy)]
struct Point {
    x: usize,
    y: usize,
}

#[derive(Eq,PartialEq,Hash,Clone,Copy)]
struct PointStep {
    point: Point,
    nstep: usize,
}

impl Field {
    fn from(lines: Vec<String>) -> Field {
        let mut rows: Vec<Vec<u8>> = Vec::new();
        for line in lines {
            let row = line.bytes().collect();
            rows.push(row)
        }
        let xdim = rows[0].len();
        let ydim = rows.len();
        Field{rows, xdim, ydim}
    }
    fn get(&self, point: &Point) -> u8 {
        self.rows[point.y][point.x]
    }
    fn neighbours(&self, point: &Point) -> [Option<Point>; 4] {
        let x = point.x;
        let y = point.y;
        [if y > 0 {Some(Point{x: x, y: y-1})} else {None}, 
         if x > 0 {Some(Point{x: x-1, y: y})} else {None},
         if y < self.ydim-1 {Some(Point{x: x, y: y+1})} else {None},
         if x < self.xdim-1 {Some(Point{x: x+1, y: y})} else {None}]
    }
    fn is_plot(&self, point: &Point) -> bool {
        self.get(point) != b'#'
    }
    fn get_start(&self) -> Point {
        for iy in 0..self.ydim {
            for ix in 0..self.xdim {
                if self.rows[iy][ix] == b'S' {
                    return Point{x: ix, y: iy};
                }
            }
        }
        panic!();
    }
}

fn options<'a>(field: &Field, memo: &'a mut HashMap<PointStep,HashSet<Point>>,
               point: Point, nstep: usize) -> &'a HashSet<Point> {
    let pstep = PointStep{point: point, nstep: nstep};
    if !memo.contains_key(&pstep) {
        let mut set: HashSet<Point>;
        if nstep == 0 {
            set = HashSet::with_capacity(1);
            set.insert(point);
        }
        else {
            set = HashSet::new();
            for qp in field.neighbours(&point) {
                if let Some(p) = qp {
                    if field.is_plot(&p) {
                        for n in options(field, memo, p, nstep-1) {
                            set.insert(n.clone());
                        }
                    }
                }
            }
            set.shrink_to_fit();
        }
        memo.insert(pstep, set);
    }
    memo.get(&pstep).unwrap()
}

pub fn calc21a(lines: Vec<String>) -> i64 {
    let field = Field::from(lines);
    let start = field.get_start();
    let mut memo: HashMap<PointStep,HashSet<Point>> = HashMap::new();
//  for n in 0..64 {
//      println!("{} -> {}",
//               n, options(&field, &mut memo, start.clone(), n).len());
//  }
    options(&field, &mut memo, start, 64).len() as i64
}
