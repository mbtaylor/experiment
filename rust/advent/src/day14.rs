use std::collections::HashSet;
use std::collections::hash_map::DefaultHasher;
use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;
use std::hash::Hash;
use std::hash::Hasher;

#[derive(PartialEq,Clone,Hash)]
struct Dish {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

enum Direction {
    N, W, S, E,
}

impl Dish {
    fn from(lines: Vec<String>) -> Dish {
        let mut rows: Vec<Vec<u8>> = Vec::new();
        for line in lines {
            let row = line.bytes().collect();
            rows.push(row)
        }
        let xdim = rows[0].len();
        let ydim = rows.len();
        Dish{rows, xdim, ydim}
    }
    fn get(&self, ix: usize, iy: usize) -> u8 {
        self.rows[iy][ix]
    }
    fn set(&mut self, ix: usize, iy: usize, byte: u8) {
        let row = &mut self.rows[iy];
        row[ix] = byte;
    }
    fn score_north(&self) -> i64 {
        let mut score = 0;
        for iy in 0..self.ydim {
            let w = self.ydim - iy;
            for ix in 0..self.xdim {
                if self.get(ix, iy) == b'O' {
                    score += w as i64;
                }
            }
        }
        score
    }
    fn checksum(&self) -> u64 {
        let mut hasher = DefaultHasher::new();
        self.hash(&mut hasher);
        hasher.finish()
    }
    fn tilt(&mut self, dir: Direction) {
        match dir {
            Direction::N => {
                for ix in 0..self.xdim {
                    let mut iy1 = 0;
                    for iy in 0..self.ydim {
                        match self.get(ix, iy) {
                            b'O' => {
                                if iy > iy1 {
                                    self.set(ix, iy, b'.');
                                    self.set(ix, iy1, b'O');
                                }
                                iy1 += 1;
                            },
                            b'#' => {
                                iy1 = iy + 1;
                            },
                            _ => {},
                        }
                    }
                }
            },
            Direction::S => {
                for ix in 0..self.xdim {
                    let mut iy1 = self.ydim - 1;
                    for jy in 0..self.ydim {
                        let iy = self.ydim - 1 - jy;
                        match self.get(ix, iy) {
                            b'O' => {
                                if iy < iy1 {
                                    self.set(ix, iy, b'.');
                                    self.set(ix, iy1, b'O');
                                }
                                if iy1 > 0 {
                                    iy1 -= 1;
                                }
                            },
                            b'#' => {
                                if iy > 1 {
                                    iy1 = iy - 1;
                                }
                            },
                            _ => {},
                        }
                    }
                }
            },
            Direction::W => {
                for iy in 0..self.ydim {
                    let mut ix1 = 0;
                    for ix in 0..self.xdim {
                        match self.get(ix, iy) {
                            b'O' => {
                                if ix > ix1 {
                                    self.set(ix, iy, b'.');
                                    self.set(ix1, iy, b'O');
                                }
                                ix1 += 1;
                            },
                            b'#' => {
                                ix1 = ix + 1;
                            },
                            _ => {},
                        }
                    }
                }
            },
            Direction::E => {
                for iy in 0..self.ydim {
                    let mut ix1 = self.xdim - 1;
                    for jx in 0..self.xdim {
                        let ix = self.xdim - 1 - jx;
                        match self.get(ix, iy) {
                            b'O' => {
                                if ix < ix1 {
                                    self.set(ix, iy, b'.');
                                    self.set(ix1, iy, b'O');
                                }
                                if ix1 > 0 {
                                    ix1 -= 1;
                                }
                            },
                            b'#' => {
                                if ix > 1 {
                                    ix1 = ix - 1;
                                }
                            },
                            _ => {},
                        }
                    }
                }
            },
        }
    }
    fn spin_cycle(&mut self) {
        self.tilt(Direction::N);
        self.tilt(Direction::W);
        self.tilt(Direction::S);
        self.tilt(Direction::E);
    }
}

impl Display for Dish {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        for row in &self.rows {
            _ = writeln!(f, "{}", String::from_utf8(row.to_vec()).unwrap());
        }
        Ok(())
    }
}

pub fn calc14a(lines: Vec<String>) -> i64 {
    let dish = Dish::from(lines);
    let mut tot: i64 = 0;
    let ydim = dish.ydim;
    for ix in 0..dish.xdim {
        let mut iytop = ydim;
        for iy in 0..ydim {
            match dish.get(ix, iy) {
                b'O' => {
                    tot += iytop as i64;
                    iytop -= 1;
                },
                b'#' => {
                    iytop = ydim - iy - 1;
                },
                b'.' => {},
                _ => panic!(),
            }
        }
    }
    tot
}

pub fn calc14b(lines: Vec<String>) -> i64 {
    let mut dish = Dish::from(lines);
    let mut j = 0;
    for i in 0..1000 {
        dish.spin_cycle();
        j += 1;
    }
    let j0 = j;
    let mut set = HashSet::new();
    for i in 0..1000 {
        dish.spin_cycle();
        j += 1;
        set.insert(dish.checksum());
    }
    let period = set.len();
    let ncycle: i64 = 1_000_000_000 - j;
    let iscore = ( ncycle % period as i64 ) as usize;
    let mut scores = Vec::new();
    for i in 0..period {
        scores.push(dish.score_north());
        dish.spin_cycle();
        j += 1;
    }
    println!("{} -> {:?}    {}", scores.len(), scores, iscore);
    scores[iscore]
}
