use regex::Regex;
use std::iter;

trait Mapper {
    fn raw_map(&self, k: i64) -> Option<i64>;
    fn map(&self, k: i64) -> i64 {
        match self.raw_map(k) {
            Some(m) => m,
            None => k,
        }
    }
}

#[derive(Clone,Debug)]
struct RangeMap {
    idest: i64,
    isrc: i64,
    len: i64,
}

#[derive(Debug)]
struct MapBlock {
    ranges: Vec<RangeMap>,
}

#[derive(Debug)]
struct Almanac {
    seeds: Vec<i64>,
    blocks: Vec<MapBlock>,
}

impl Mapper for RangeMap {
    fn raw_map(&self, k: i64) -> Option<i64> {
        let off = k - self.isrc;
        if off >= 0 && off < self.len {
            Some(&self.idest + off)
        }
        else {
            None
        }
    }
}

impl Mapper for MapBlock {
    fn raw_map(&self, k: i64) -> Option<i64> {
        for r in &self.ranges {
            if let Some(m) = r.raw_map(k) {
                return Some(m);
            }
        }
        None
    }
}

fn read_blocks(lines: &[String]) -> Vec<MapBlock> {
    let triple_re = Regex::new(" *([0-9]+) +([0-9]+) +([0-9]+) *").unwrap();
    let mut blocks: Vec<MapBlock> = Vec::new();
    let mut ranges: Vec<RangeMap> = Vec::new();
    for line in lines.iter().chain(iter::once(&String::from(""))) {
        match triple_re.captures(&line[..]) {
            Some(caps) => {
                ranges.push(RangeMap{idest: caps[1].parse().unwrap(),
                                     isrc: caps[2].parse().unwrap(),
                                     len: caps[3].parse().unwrap()});
            },
            None => {
                if !ranges.is_empty() {
                    blocks.push(MapBlock{ranges: ranges.clone()});
                    ranges.clear();
                }
            },
        }
    }
    blocks
}

fn read_almanac(lines: &[String]) -> Almanac {
    let seeds: Vec<i64> = lines[0]
                         .split_whitespace()
                         .skip(1)
                         .map(|x| x.parse().unwrap())
                         .collect();
    let blocks = read_blocks(&lines[1..]);
    Almanac{seeds: seeds, blocks: blocks}
}

pub fn calc05a(lines: Vec<String>) -> i64 {
    let almanac = read_almanac(&lines);
    let mut locs: Vec<i64> = Vec::new();
    for seed in &almanac.seeds {
        let mut id = *seed;
        for block in &almanac.blocks {
            id = block.map(id);
        }
        locs.push(id);
    }
    *locs.iter().min().unwrap()
}
