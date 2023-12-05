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

#[derive(Clone,Copy,Debug)]
struct Span {
    start: i64,
    len: i64,
}

impl MapBlock {
    fn map_span(&self, in_span: &Span) -> Vec<Span> {
        let s = in_span;
        if s.len == 0 {
            return Vec::new();
        }
        let smin = s.start;
        let smax = s.start + s.len;
        for r in &self.ranges {
            let rmin = r.isrc;
            let rmax = r.isrc + r.len;
            let start_off = smin - rmin;
            let end_off = smax - rmax;

            // no overlap
            if smax <= rmin || smin >= rmax {
                // no action
            }

            // span within range
            else if start_off >= 0 && end_off <= 0 {
                assert!(smin >= rmin && smax <= rmax);
                return vec!(Span{start: r.idest + start_off, len: s.len});
            }

            // span overhangs both ends of range
            else if start_off <= 0 && end_off >= 0 {
                assert!(smin <= rmin && smax >= rmax);
                let mut out_spans = Vec::new();
                out_spans.push(Span{start: r.idest, len: r.len});
                let s1 = Span{start: smin, len: -start_off};
                let s2 = Span{start: rmax, len: end_off};
                for subspan in self.map_span(&s1) {
                    out_spans.push(subspan);
                }
                for subspan in self.map_span(&s2) {
                    out_spans.push(subspan);
                }
                return out_spans;
            }

            // span overhangs high end of range
            else if start_off >= 0 && end_off >= 0 {
                assert!(smin >= rmin && smin < rmax && smax >= rmax);
                let mut out_spans = Vec::new();
                out_spans.push(Span{start: r.idest + start_off,
                                    len: s.len - end_off});
                let s1 = Span{start: rmax, len: end_off};
                for subspan in self.map_span(&s1) {
                    out_spans.push(subspan);
                }
                return out_spans;
            }

            // span overhangs low end of range
            else if start_off <= 0 && end_off <= 0 {
                assert!(smin <= rmin && smax > rmin && smax <= rmax,
                        "{}-{};  {}-{}", smin, smax, rmin, rmax );
                let mut out_spans = Vec::new(); 
                out_spans.push(Span{start: r.idest,
                                    len: s.len + start_off});
                let s1 = Span{start: smin, len: -start_off};
                for subspan in self.map_span(&s1) {
                    out_spans.push(subspan);
                }
                return out_spans;
            }
        }

        // no overlaps at all
        vec!(*in_span)
    }
    fn map_spans(&self, in_spans: Vec<Span>) -> Vec<Span> {
        let mut out_spans: Vec<Span> = Vec::new();
        for in_span in in_spans {
            for s in self.map_span(&in_span) {
                out_spans.push(s);
            }
        }
        out_spans
    }
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

pub fn calc05b(lines: Vec<String>) -> i64 {
    let almanac = read_almanac(&lines);
    let mut min_locs: Vec<i64> = Vec::new();
    let seeds = &almanac.seeds;
    for i in 0..seeds.len()/2 {
        let start = seeds[2*i+0];
        let len = seeds[2*i+1];
        let mut id_spans = vec!(Span{start: start, len: len});
        for block in &almanac.blocks {
            id_spans = block.map_spans(id_spans);
        }
        min_locs.push(id_spans.iter().map(|x| x.start).min().unwrap());
    }
    *min_locs.iter().min().unwrap()
}
