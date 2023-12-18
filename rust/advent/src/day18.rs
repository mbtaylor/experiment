use regex::Regex;
use std::cmp;
use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;

struct Field {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

#[derive(Debug)]
struct Step {
    dir: Direction,
    len: usize,
}

struct Point {
    x: i32,
    y: i32,
}

#[derive(Copy,Clone,Debug)]
enum Direction {
    U, L, D, R,
}

impl Field {
    fn new(xdim: usize, ydim: usize) -> Field {
        let mut rows: Vec<Vec<u8>> = Vec::with_capacity(ydim);
        for iy in 0..ydim {
            let mut row: Vec<u8> = Vec::with_capacity(xdim);
            for ix in 0..xdim {
                row.push(b'.');
            }
            rows.push(row);
        }
        Field{xdim, ydim, rows}
    }
    fn get(&self, ix: usize, iy: usize) -> u8 {
        self.rows[iy][ix]
    }
    fn set(&mut self, ix: usize, iy: usize, byte: u8) {
        let row = &mut self.rows[iy];
        row[ix] = byte;
    }
}

impl Point {
    fn displace_step(&self, step: &Step) -> Point {
        self.displace(step.dir, step.len)
    }
    fn displace(&self, dir: Direction, len: usize) -> Point {
        let mut x = self.x;
        let mut y = self.y;
        match dir {
            Direction::U => { y -= len as i32 },
            Direction::L => { x -= len as i32 },
            Direction::D => { y += len as i32 },
            Direction::R => { x += len as i32 },
        }
        Point{x, y}
    }
}

impl Display for Field {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        for row in &self.rows {
            for b in row {
                write!(f, "{}", *b as char).unwrap();
            }
            writeln!(f, "").unwrap();
        }
        writeln!(f, "{} x {}", self.xdim, self.ydim)
    }
}

pub fn calc18a(lines: Vec<String>) -> i64 {
    let line_re = Regex::new(concat!(
        "([ULDR]) ",
        "([0-9]+) ",
        ".*",
    //  "[(][#]([0-9a-f]{2}) ([0-9a-f]{2}) ([0-9a-f]{2})[)]"
    )).unwrap();
    let mut steps: Vec<Step> = Vec::new();
    for line in lines {
        let caps = line_re.captures(&line[..]).unwrap();
        let dir = match &caps[1] {
            "U" => Direction::U,
            "L" => Direction::L,
            "D" => Direction::D,
            "R" => Direction::R,
            _ => panic!(),
        };
        let len: usize = caps[2].parse().unwrap();
    //  let rgb: [u8; 3] = [caps[3].parse().unwrap(),
    //                      caps[4].parse().unwrap(),
    //                      caps[5].parse().unwrap()];
    //  let rgb = [0, 0, 0];
        steps.push(Step{dir, len});
    }
    let mut p = Point{x: 0, y: 0};
    let mut xmin = 0;
    let mut xmax = 0;
    let mut ymin = 0;
    let mut ymax = 0;
    for step in &steps {
        p = p.displace_step(&step);
        xmin = cmp::min(xmin, p.x);
        xmax = cmp::max(xmax, p.x);
        ymin = cmp::min(ymin, p.y);
        ymax = cmp::max(ymax, p.y);
    }
    xmin -= 1;
    xmax += 1;
    ymin -= 1;
    ymax += 1;
    let x0 = xmin;
    let y0 = ymin;
    let mut field = Field::new((xmax+1-xmin) as usize, (ymax+1-ymin) as usize);
    let mut p = Point{x: 0, y: 0};
    field.set((p.x - x0) as usize, (p.y - y0) as usize, b'#');
    for step in &steps {
        for i in 0..step.len {
            p = p.displace(step.dir, 1);
            field.set((p.x - x0) as usize, (p.y - y0) as usize, b'#');
        }
    }

    for iy in 1..field.ydim-1 {
        let mut state = 0;
        let mut sgn1: Option<i8> = None;
        let mut sgn3: Option<i8> = None;
        for ix in 1..field.xdim-1 {
            let c = field.get(ix, iy);
            let is_hole = c == b'#';
            match state {
                0 => {
                    if is_hole {
                        state = 1;
                        let up = field.get(ix, iy-1) == b'#';
                        let down = field.get(ix, iy+1) == b'#';
                        if up && down {
                            sgn1 = Some(0);
                        }
                        else if up {
                            sgn1 = Some(1);
                        }
                        else {
                            assert!(down, "{} {}", ix, iy);
                            sgn1 = Some(-1);
                        }
                    }
                },
                1 => {
                    if !is_hole {
                        let up = field.get(ix-1, iy-1) == b'#';
                        let down = field.get(ix-1, iy+1) == b'#';
                        let sgn1a: i8;
                        if up && down {
                            sgn1a = 0;
                        }
                        else if up {
                            sgn1a = 1;
                        }
                        else {
                            assert!(down);
                            sgn1a = -1;
                        }
                        state = if sgn1a * sgn1.unwrap() == 1 {0} else {2};
                        sgn1 = None;
                    }
                },
                2 => {
                    if is_hole {
                        state = 3;
                        let up = field.get(ix, iy-1) == b'#';
                        let down = field.get(ix, iy+1) == b'#';
                        if up && down {
                            sgn3 = Some(0);
                        }
                        else if up {
                            sgn3 = Some(1);
                        }
                        else {
                            assert!(down, "{} {}", ix, iy);
                            sgn3 = Some(-1);
                        }
                    }
                },
                3 => {
                    if !is_hole {
                        let up = field.get(ix-1, iy-1) == b'#';
                        let down = field.get(ix-1, iy+1) == b'#';
                        let sgn3a: i8;
                        if up && down {
                            sgn3a = 0;
                        }
                        else if up {
                            sgn3a = 1;
                        }
                        else {
                            assert!(down);
                            sgn3a = -1;
                        }
                        state = if sgn3a * sgn3.unwrap() == 1 {2} else {0};
                        sgn3 = None;
                    }
                },
                _ => panic!(),
            }
            if state == 2 {
                field.set(ix, iy, b'+');
            }
        }
    }

    let mut tot = 0;
    for row in field.rows {
        for c in row {
            if c == b'#' || c == b'+' {
                tot += 1;
            }
        }
    }
    tot
}
