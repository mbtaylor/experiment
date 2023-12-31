use regex::Regex;
use std::cmp;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(Debug,Clone,Copy)]
struct Block {
    index: usize,
    p1: Pos,
    p2: Pos,
}

#[derive(Debug,Clone,Copy)]
struct Pos {
    x: usize,
    y: usize,
    z: usize,
}

struct Field {
    xdim: usize,
    ydim: usize,
    rows: Vec<Vec<Vec<Option<usize>>>>,
}

impl Pos {
    fn component(&self, i: usize) -> usize {
        match i {
            0 => self.x,
            1 => self.y,
            2 => self.z,
            _ => panic!(),
        }
    }
    fn with_component(&self, i: usize, c: usize) -> Pos {
        let mut p = self.clone();
        match i {
            0 => p.x = c,
            1 => p.y = c,
            2 => p.z = c,
            _ => panic!(),
        }
        p
    }
}

impl Block {
    fn cells(&self) -> Vec<Pos> {
        for i in 0..3 {
            let c1 = self.p1.component(i);
            let c2 = self.p2.component(i);
            if c1 != c2 {
                let (clo, chi) = if c1 < c2 { (c1, c2) } else { (c2, c1) };
                let mut cells: Vec<Pos> = Vec::new();
                for c in clo..chi+1 {
                    cells.push(self.p1.with_component(i, c));
                }
                return cells;
            }
        }
        vec!(self.p1.clone())
    }
}

impl Field {
    fn new(xdim: usize, ydim: usize) -> Field {
        let mut rows: Vec<Vec<Vec<Option<usize>>>> = Vec::new();
        for iy in 0..ydim {
            let mut row: Vec<Vec<Option<usize>>> = Vec::new();
            for ix in 0..xdim {
                let pile: Vec<Option<usize>> = Vec::new();
                row.push(pile);
            }
            rows.push(row);
        }
        Field{xdim, ydim, rows}
    }
    fn get_pile(&mut self, ix: usize, iy: usize) -> &mut Vec<Option<usize>> {
        self.rows.get_mut(iy).unwrap().get_mut(ix).unwrap()
    }
    fn place_block(&mut self, ib: usize, block: &Block, vpos: usize) {
        for cell in block.cells() {
            let pile = self.get_pile(cell.x, cell.y);
            while pile.len() < vpos {
                pile.push(None);
            }
            pile.push(Some(ib));
        }
    }
}

fn read_blocks(lines: Vec<String>) -> Vec<Block> {
    let line_re =
        Regex::new("([0-9]+),([0-9]+),([0-9]+)~([0-9]+),([0-9]+),([0-9]+)")
       .unwrap();
    let mut blocks: Vec<Block> = Vec::new();
    for (ib, line) in lines.iter().enumerate() {
        let (_, [x1, y1, z1, x2, y2, z2]) =
            line_re.captures(&line).unwrap().extract();
        blocks.push(Block{index: ib,
                          p1: Pos{x: x1.parse().unwrap(),
                                  y: y1.parse().unwrap(),
                                  z: z1.parse().unwrap()},
                          p2: Pos{x: x2.parse().unwrap(),
                                  y: y2.parse().unwrap(),
                                  z: z2.parse().unwrap()}});
    }
    blocks
}

// output is map from block index to resting height
fn resting_heights(sorted_blocks: &Vec<Block>) -> HashMap<usize,usize> {
    let mut mins: [usize; 3] = [0, 0, 0];
    let mut maxs: [usize; 3] = [0, 0, 0];
    for block in sorted_blocks {
        for i in 0..3 {
            mins[i] = cmp::min(mins[i], cmp::min(block.p1.component(i),
                                                 block.p2.component(i)));
            maxs[i] = cmp::max(maxs[i], cmp::max(block.p1.component(i),
                                                 block.p2.component(i)));
        }
    }
    let xdim = maxs[0]+1;
    let ydim = maxs[1]+1;
    let mut field = Field::new(xdim, ydim);
    let mut heights: HashMap<usize,usize> = HashMap::new();
    for (ib, block) in sorted_blocks.iter().enumerate() {
        let mut h = 0;
        for cell in block.cells() {
            let pile = field.get_pile(cell.x, cell.y);
            h = cmp::max(h, pile.len());
        }
        field.place_block(ib, &block, h);
        let flag = heights.insert(block.index, h);
	assert!(flag==None);
    }
    heights
}

pub fn calc22a(lines: Vec<String>) -> i64 {
    let mut blocks = read_blocks(lines);
    blocks.sort_by(|a, b|             cmp::min(&a.p1.z, &a.p2.z)
                         .partial_cmp(cmp::min(&b.p1.z, &b.p2.z)).unwrap());
    let mut mins: [usize; 3] = [0, 0, 0];
    let mut maxs: [usize; 3] = [0, 0, 0];
    for block in &blocks {
        for i in 0..3 {
            mins[i] = cmp::min(mins[i], cmp::min(block.p1.component(i),
                                                 block.p2.component(i)));
            maxs[i] = cmp::max(maxs[i], cmp::max(block.p1.component(i),
                                                 block.p2.component(i)));
        }
    }
    let xdim = maxs[0]+1;
    let ydim = maxs[1]+1;
    let mut field = Field::new(xdim, ydim);
    for (ib, block) in blocks.iter().enumerate() {
        let mut h = 0;
        for cell in block.cells() {
            let pile = field.get_pile(cell.x, cell.y);
            h = cmp::max(h, pile.len());
        }
        field.place_block(ib, &block, h);
    }

    let mut supporters: Vec<HashSet<usize>> = Vec::new();
    let nblock = blocks.len();
    for ib in 0..nblock {
        supporters.push(HashSet::new());
    }
    for ix in 0..field.xdim {
        for iy in 0..field.ydim {
            let pile = field.get_pile(ix, iy);
            for (iz, ib_opt) in pile.iter().enumerate() {
                if iz > 0 {
                    if let Some(ib) = ib_opt {
                        if let Some(isup) = pile[iz-1] {
                            if isup != *ib {
                                supporters[*ib].insert(isup);
                            }
                        }
                    }
                }
            }
        }
    }
    let mut sole_supporters: HashSet<usize> = HashSet::new();
    for sup_set in supporters {
        if sup_set.len() == 1 {
            sole_supporters.insert(*sup_set.iter().next().unwrap());
        }
    }
    let tot = nblock - sole_supporters.len();
    tot as i64
}

pub fn calc22b(lines: Vec<String>) -> i64 {
    let blocks = read_blocks(lines);
    let nblock = blocks.len();
    let cmp = |a: &Block, b: &Block| cmp::min(&a.p1.z, &a.p2.z)
                        .partial_cmp(cmp::min(&b.p1.z, &b.p2.z)).unwrap();
    let mut blocks0 = blocks.clone();
    blocks0.sort_by(cmp);
    let heights0 = resting_heights(&blocks0);
    let boost = 10000;
    let mut tot = 0;
    for ib in 0..nblock {
        let mut blocks1 = blocks.clone();
        let block = blocks1.get_mut(ib).unwrap();
        block.p1.z += boost;
        block.p2.z += boost;
        blocks1.sort_by(cmp);
        let heights1 = resting_heights(&blocks1);
        let ndiff: i64 =
            heights0.keys()
                    .filter(|k| *k!=&ib)
                    .map(|k| if heights0.get(k)==heights1.get(k) {0} else {1})
                    .sum();
        tot += ndiff;
    }
    tot
}

