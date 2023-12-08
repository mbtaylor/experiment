use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;
use std::iter::Iterator;
use regex::Regex;
use std::collections::HashMap;

#[derive(Eq,PartialEq,Hash)]
struct Loc ([u8; 3]);

struct Pair(Loc, Loc);

struct Chart {
    dirs: String,
    map: HashMap<Loc,Pair>,
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
    let node_re = Regex::new("([A-Z]{3}) = [(]([A-Z]{3}), ([A-Z]{3})[)]")
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
