use std::cmp;
use std::collections::HashSet;

struct Field {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

#[derive(Debug,Copy,Clone,Hash,PartialEq,Eq)]
struct Beam {
    xpos: usize,
    ypos: usize,
    dir: Direction,
}

#[derive(Debug,Copy,Clone,Hash,PartialEq,Eq)]
enum Direction {
    N, W, S, E,
}

enum OutDirs {
    Dir1(Direction),
    Dir2(Direction, Direction),
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
    fn get(&self, ix: usize, iy: usize) -> u8 {
        self.rows[iy][ix]
    }
    fn next_beam(&self, beam: Beam, dir: Direction) -> Option<Beam> {
        let x = beam.xpos;
        let y = beam.ypos;
        match dir {
            Direction::N => {
                if y > 0 { Some(Beam{xpos: x, ypos: y-1, dir: dir}) }
                else { None }
            },
            Direction::W => {
                if x > 0 { Some(Beam{xpos: x-1, ypos: y, dir: dir}) }
                else { None }
            },
            Direction::S => {
                if y < self.ydim-1 { Some(Beam{xpos: x, ypos: y+1, dir: dir}) }
                else { None }
            },
            Direction::E => {
                if x < self.xdim-1 { Some(Beam{xpos: x+1, ypos: y, dir: dir}) }
                else { None }
            },
        }
    }
    fn prop_dirs(&self, beam: Beam) -> OutDirs {
        let x = beam.xpos;
        let y = beam.ypos;
        let dir = beam.dir;
        match self.get(x, y) {
            b'.' => {
                OutDirs::Dir1(dir)
            }
            b'-' => {
                match dir {
                    Direction::N => OutDirs::Dir2(Direction::W, Direction::E),
                    Direction::W => OutDirs::Dir1(dir),
                    Direction::S => OutDirs::Dir2(Direction::W, Direction::E),
                    Direction::E => OutDirs::Dir1(dir),
                }
            },
            b'|' => {
                match dir {
                    Direction::N => OutDirs::Dir1(dir),
                    Direction::W => OutDirs::Dir2(Direction::N, Direction::S),
                    Direction::S => OutDirs::Dir1(dir),
                    Direction::E => OutDirs::Dir2(Direction::N, Direction::S),
                }
            },
            b'/' => {
                match dir {
                    Direction::N => OutDirs::Dir1(Direction::E),
                    Direction::W => OutDirs::Dir1(Direction::S),
                    Direction::S => OutDirs::Dir1(Direction::W),
                    Direction::E => OutDirs::Dir1(Direction::N),
                }
            },
            b'\\' => {
                match dir {
                    Direction::N => OutDirs::Dir1(Direction::W),
                    Direction::W => OutDirs::Dir1(Direction::N),
                    Direction::S => OutDirs::Dir1(Direction::E),
                    Direction::E => OutDirs::Dir1(Direction::S),
                }
            },
            _ => panic!(),
        }
    }
}

fn prop_beam(field: &Field, seen: &mut HashSet<Beam>, beam: Beam) {
    if seen.insert(beam) {
        match field.prop_dirs(beam) {
            OutDirs::Dir1(d1) => {
                if let Some(b1) = field.next_beam(beam, d1) {
                    prop_beam(field, seen, b1);
                }
            },
            OutDirs::Dir2(d1, d2) => {
                if let Some(b1) = field.next_beam(beam, d1) {
                    prop_beam(field, seen, b1);
                }
                if let Some(b2) = field.next_beam(beam, d2) {
                    prop_beam(field, seen, b2);
                }
            },
        }
    }
}

fn count_activated(field: &Field, beam0: Beam) -> i64 {
    let mut seen_beams: HashSet<Beam> = HashSet::new();
    prop_beam(&field, &mut seen_beams, beam0);
    let mut activated: HashSet<[usize; 2]> = HashSet::new();
    for beam in seen_beams {
        activated.insert([beam.xpos, beam.ypos]);
    }
    activated.len() as i64
}

pub fn calc16a(lines: Vec<String>) -> i64 {
    count_activated(&Field::from(lines),
                    Beam{xpos: 0, ypos: 0, dir: Direction::E})
}

pub fn calc16b(lines: Vec<String>) -> i64 {
    let field = Field::from(lines);
    let mut max_act = 0;
    for ix in 0..field.xdim {
        let beam1 = Beam{xpos: ix, ypos:0, dir: Direction::S};
        let beam2 = Beam{xpos: ix, ypos:field.ydim-1, dir: Direction::N};
        let c1 = count_activated(&field, beam1);
        let c2 = count_activated(&field, beam2);
        max_act = cmp::max(max_act, c1);
        max_act = cmp::max(max_act, c2);
    }
    for iy in 0..field.ydim {
        let beam3 = Beam{xpos: 0, ypos: iy, dir: Direction::E};
        let beam4 = Beam{xpos: field.xdim-1, ypos: iy, dir: Direction::W};
        let c3 = count_activated(&field, beam3);
        let c4 = count_activated(&field, beam4);
        max_act = cmp::max(max_act, c3);
        max_act = cmp::max(max_act, c4);
    }
    max_act
}
