
struct Map {
    nx: usize,
    ny: usize,
    lines: Vec<String>,
}

#[derive(Debug,PartialEq,Clone,Copy)]
struct Pos {
    x: i32,
    y: i32,
}

impl Pos {
    fn from(x: i32, y: i32) -> Pos {
        Pos{x: x, y}
    }
    fn n(&self) -> Pos {
        Pos{x: self.x, y: self.y-1}
    }
    fn s(&self) -> Pos {
        Pos{x: self.x, y: self.y+1}
    }
    fn e(&self) -> Pos {
        Pos{x: self.x+1, y: self.y}
    }
    fn w(&self) -> Pos {
        Pos{x: self.x-1, y: self.y}
    }
    fn neighbours(&self) -> [Pos; 4] {
        [self.n(), self.e(), self.w(), self.s(),]
    }
}

impl Map {
    fn from(lines: Vec<String>) -> Map {
        let nx = lines[0].len();
        let ny = lines.len();
        Map{nx, ny, lines}
    }
    fn read(&self, pos: &Pos) -> Option<u8> {
        if pos.x >= 0 && pos.x < self.nx as i32 &&
           pos.y >= 0 && pos.y < self.ny as i32 {
            Some(self.lines[pos.y as usize].as_bytes()[pos.x as usize])
        }
        else {
            None
        }
    }
    fn find_start(&self) -> Pos {
        for x in 0..self.nx {
            for y in 0..self.ny {
                let pos = Pos::from(x as i32, y as i32);
                if self.read(&pos) == Some(b'S') {
                    return pos;
                }
            }
        }
        panic!();
    }
    fn ends(&self, pos: &Pos) -> Option<[Pos; 2]> {
        match self.read(pos) {
            Some(b'|') => Some([pos.n(), pos.s()]),
            Some(b'-') => Some([pos.w(), pos.e()]),
            Some(b'L') => Some([pos.n(), pos.e()]),
            Some(b'J') => Some([pos.n(), pos.w()]),
            Some(b'7') => Some([pos.s(), pos.w()]),
            Some(b'F') => Some([pos.s(), pos.e()]),
            Some(b'.') => None,
            Some(b'S') => None,
            None => None,
            _ => panic!(),
        }
    }
    fn exits(&self, pos: &Pos) -> Vec<Pos> {
        let mut exits = Vec::new();
        for nb in pos.neighbours() {
            if let Some(ends) = self.ends(&nb) {
                if ends.iter().any(|x| x == pos) {
                    exits.push(nb);
                }
            }
        }
        exits
    }
    fn tunnel(&self) -> Vec<Pos> {
        let mut tunnel: Vec<Pos> = Vec::new();
        let start = self.find_start();
        let mut p0 = start;
        let mut p1 = self.exits(&p0)[0];
        tunnel.push(p0);
        loop {
            tunnel.push(p1);
            let ends = self.ends(&p1).unwrap();
            (p0, p1) = (p1, if ends[0] == p0 { ends[1] } else { ends[0] });
            if p1 == start {
                return tunnel;
            }
        }
    }
}

fn tunnel_contains(tunnel: &Vec<Pos>, pos: &Pos) -> bool {
    tunnel.iter().any(|x| x == pos)
}

pub fn calc10a(lines: Vec<String>) -> i64 {
    let map = Map::from(lines);
    let tunnel = &map.tunnel();
    let siz = tunnel.len();
    (siz / 2) as i64
}

pub fn calc10b(lines: Vec<String>) -> i64 {
    let map = Map::from(lines);
    let tunnel = &map.tunnel();
    let mut nin = 0;
    for iy in 0..map.ny {
        let mut ncross: i32 = 0;
        for ix in 0..map.nx {
            let pos = Pos{x: ix as i32, y: iy as i32};
            if tunnel_contains(tunnel, &pos) {
                let add_cross = match map.read(&pos).unwrap() {
                    b'|' => 1,
                    b'L' => 0,
                    b'F' => 1,
                    b'J' => 0,
                    b'7' => 1,
                    b'-' => 0,
                    b'S' => 0,  // cheat
                    b'.' => 0,
                    _ => 0,
                };
                ncross += add_cross;
            }
            else {
                if ncross % 2 == 1 {
                    nin += 1;
                }
            }
        }
    }
    nin
}
