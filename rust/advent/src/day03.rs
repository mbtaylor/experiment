use std::collections::HashSet;

struct Grid {
    xdim: i32,
    ydim: i32,
    lines: Vec<String>,
}

#[derive(PartialEq, Eq, Hash)]
#[derive(Debug)]
struct Part {
    value: i32,
    ix: i32,
    iy: i32,
}

impl Grid {
    fn at(&self, ix: i32, iy: i32) -> &u8 {
        match self.lines.get(iy as usize) {
            Some(line) => match line.as_bytes().get(ix as usize) {
                Some(chr) => chr as &u8,
                None => &b'.',
            },
            None => &b'.',
        }
    }
    fn near_symbol(&self, ix: i32, iy: i32) -> bool {
        for jx in ix-1..ix+2 {
            for jy in iy-1..iy+2 {
                if is_symbol(self.at(jx, jy)) {
                    return true;
                }
            }
        }
        false
    }
    fn get_part(&self, ix: i32, iy: i32) -> Option<Part> {
        match digit(self.at(ix, iy)) {
            None => None,
            Some(_) => {
                let mut x = ix.clone();
                let x_min = loop {
                    match digit(self.at(x-1, iy)) {
                        None => break x,
                        Some(_) => x -= 1,
                    }
                };
                let mut x = ix.clone();
                let x_max = loop {
                    match digit(self.at(x+1, iy)) {
                        None => break x,
                        Some(_) => x +=1,
                    }
                };
                let value: i32 =
                    self.lines[iy as usize]
                              [(x_min as usize)..((x_max+1) as usize)]
                        .parse()
                        .expect("Bad num");
                let part = Part{value: value, ix: x_min, iy: iy};
                Some(part)
            },
        }
    }
    fn from_lines(lines: Vec<String>) -> Grid {
        let xdim = lines[0].len() as i32;
        let ydim = lines.len() as i32;
        Grid{xdim: xdim, ydim: ydim, lines: lines}
    }
}

fn digit(chr: &u8) -> Option<&u8> {
    if chr >= &b'0' && chr <= &b'9' { Some(chr) } else { None }
}

fn is_symbol(chr: &u8) -> bool {
    if chr == &b'.' {
        false
    }
    else {
        match digit(chr) {
            Some(_) => false,
            None => true,
        }
    }
}

pub fn calc03a(lines: Vec<String>) -> i32 {
    let grid = Grid::from_lines(lines);
    let mut tot: i32 = 0;
    let mut digs = String::new();
    let mut has_sym = false;
    for iy in -1..grid.ydim+1 {
        for ix in -1..grid.xdim+1 {
            match digit(grid.at(ix, iy)) {
                Some(dig) => {
                    digs.push(*dig as char);
                    if grid.near_symbol(ix, iy) {
                        has_sym = true;
                    }
                },
                None => {
                    if digs.len() > 0 {
                        let num: i32 = digs.parse().expect("bad digits");
                        if has_sym {
                            tot += num;
                        }
                    }
                    digs.clear();
                    has_sym = false;
                }
            }
        }
    }
    tot
}

pub fn calc03b(lines: Vec<String>) -> i32 {
    let grid = Grid::from_lines(lines);
    let mut tot = 0;
    for iy in -1..grid.ydim+1 {
        for ix in -1..grid.xdim+1 {
            if grid.at(ix, iy) == &b'*' {
                let mut parts: HashSet<Part> = HashSet::new();
                for jx in ix-1..ix+2 {
                    for jy in iy-1..iy+2 {
                        match grid.get_part(jx, jy) {
                            Some(part) => {
                                parts.insert(part)
                            },
                            None => false,
                        };
                    }
                }
                if parts.len() == 2 {
                    let mut pair = [0, 0];
                    for (i, p) in parts.iter().enumerate() {
                        pair[i] = p.value;
                    }
                    tot += pair[0] * pair[1];
                }
            }
        }
    }
    tot
}
