use std::collections::HashSet;
use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;
use std::iter::Iterator;
use regex::Regex;
use std::collections::HashMap;

#[derive(Clone,Copy,Debug,Eq,PartialEq,Hash)]
struct Loc ([u8; 3]);

struct Pair(Loc, Loc);

struct Chart {
    dirs: String,
    map: HashMap<Loc,Pair>,
}

#[derive(Copy,Clone,Debug)]
struct Offset {
    dest: Loc,
    nstep: i64,
}

struct ZoffMap {
    map: HashMap<Loc,Vec<Option<Offset>>>,
}

impl Loc {
    fn from(txt: &str) -> Loc {
        let mut triple = [0u8; 3];
        for (i, c) in txt.as_bytes().iter().enumerate() {
            triple[i] = *c;
        }
        Loc(triple)
    }
}

impl ZoffMap {
    fn from_chart(chart: &Chart) -> ZoffMap {
        let mut map: HashMap<Loc,Vec<Option<Offset>>> = HashMap::new();
        for loc in chart.map.keys() {
            let mut offs: Vec<Option<Offset>> = Vec::new();
            for i in 0..chart.dirs.len() {
                offs.push(None);
            }
            map.insert(loc.clone(), offs);
        }
        ZoffMap{map}
    }
    fn next_zero(&mut self, chart: &Chart, loc: Loc, ipos: usize) -> Offset {
        let offs = self.map.get_mut(&loc).unwrap();
        if let None = offs[ipos] {
            let dirs = chart.dirs.as_bytes();
            let ndir = dirs.len() as i64;
            let mut i: i64 = 0;
            let mut loc = loc;
            loop {
                let pair = chart.map.get(&loc).unwrap();
                let jpos = ((ipos as i64 + i) % ndir) as usize;
                loc = match dirs[jpos] {
                    b'L' => pair.0,
                    b'R' => pair.1,
                    _ => panic!(),
                };
                if loc.0[2] == b'Z' {
                    offs[ipos] = Some(Offset{dest: loc, nstep: i + 1});
                    break;
                }
                i += 1;
            }
        }
        offs[ipos].unwrap()
    }
}

impl Display for Loc {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "{}{}{}", self.0[0] as char,
                            self.0[1] as char,
                            self.0[2] as char)
    }
}

impl Display for Pair {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "({}, {})", self.0, self.1)
    }
}

fn read_chart(lines: Vec<String>) -> Chart {
    let dirs = String::from(&lines[0]);
    let mut map: HashMap<Loc,Pair> = HashMap::new();
    let node_re =
        Regex::new("([A-Z1-9]{3}) = [(]([A-Z1-9]{3}), ([A-Z1-9]{3})[)]")
       .unwrap();
    for line in lines.iter().skip(2) {
        match node_re.captures(&line[..]) {
            Some(caps) => {
                let loc = Loc::from(&caps[1]);
                let left = Loc::from(&caps[2]);
                let right = Loc::from(&caps[3]);
                map.insert(loc, Pair(left, right));
            },
            None => panic!(),
        }
    }
    Chart{dirs, map}
}

fn unique_value(values: &Vec<i64>) -> Option<i64> {
    let mut iter = values.iter();
    let v0 = match iter.next() {
        None => return None,
        Some(v) => v,
    };
    for v in iter {
        if v != v0 {
            return None;
        }
    }
    Some(v0.clone())
}

pub fn calc08a(lines: Vec<String>) -> i64 {
    let chart = read_chart(lines);
    let start = Loc::from("AAA");
    let end = Loc::from("ZZZ");
    let mut loc = &start;
    for (i, c_dir) in chart.dirs.chars().cycle().enumerate() {
        let pair = &chart.map.get(loc).unwrap();
        loc = match c_dir {
            'L' => &pair.0,
            'R' => &pair.1,
            _ => panic!(),
        };
        if loc == &end {
            return (i + 1) as i64;
        }
    }
    panic!()
}

pub fn calc08b(lines: Vec<String>) -> i64 {
    let chart = read_chart(lines);
    let mut zoff_map = ZoffMap::from_chart(&chart);
    let ndir = chart.dirs.len() as i64;
    let starts: Vec<&Loc> =
        chart.map.keys().filter(|k| k.0[2] == b'A').collect();
    let nstart = starts.len();
    let mut highs: Vec<i64> = Vec::new();
    let mut offs: Vec<Offset> = Vec::new();
    for start in starts {
        highs.push(0);
        offs.push(Offset{dest: start.clone(), nstep: 0});
    }
    let high_set: HashSet<i64> = HashSet::new();
    loop {
        for is in 0..nstart {
            let off = offs[is];
            while highs[is] == 0 ||
                  highs[is] < *highs.iter().max().unwrap() {
                let ipos = ((highs[is] + off.nstep) % ndir) as usize;
                offs[is] = zoff_map.next_zero(&chart, off.dest, ipos);
                highs[is] += offs[is].nstep;
            }
            if let Some(value) = unique_value(&highs) {
                return value;
            }
        }
    }
}
