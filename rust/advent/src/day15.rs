use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;

struct Step {
    label: Label,
    focal: Option<u8>,
}

#[derive(PartialEq)]
struct Label {
    txt: [u8; 2],
}

struct Room {
    racks: [Rack; 256],
}

struct Rack {
    lenses: Vec<Lens>,
}

struct Lens {
    label: Label,
    focal: u8,
}

impl Label {
    fn ibox(&self) -> u8 {
        hash(&self.txt)
    }
}

impl Room {
    fn new() -> Room {
        let racks: [Rack; 256] =
            std::array::from_fn(|_| Rack{lenses: Vec::new()});
        Room{racks}
    }
}

impl Display for Label {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "{}{}", self.txt[0] as char, self.txt[1] as char)
    }
}

impl Display for Step {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        _ = write!(f, "{}", self.label);
        match self.focal {
            Some(n) => write!(f, "={}", n),
            None => write!(f, "-"),
        }
    }
}

impl Step {
    fn from_word(word: &str) -> Step {
        let buf = word.as_bytes();
        let label = Label{txt: [buf[0], buf[1]]};
        let focal = match buf[2] {
            b'-' => None,
            b'=' => Some(String::from_utf8_lossy(&buf[3..]).parse().unwrap()),
            _ => panic!(),
        };
        Step{label, focal}
    }
}

fn hash(buf: &[u8]) -> u8 {
    let mut h: i32 = 0;
    for b in buf {
        h += *b as i32;
        h *= 17;
        h = h % 256;
    }
    h as u8
}

pub fn calc15a(lines: Vec<String>) -> i64 {
    let mut tot = 0;
    for line in lines {
        for word in line.split(',') {
            tot += hash(word.as_bytes()) as i64;
        }
    }
    tot
}

pub fn calc15b(lines: Vec<String>) -> i64 {
    let mut room = Room::new();
    for line in lines {
        for word in line.split(',') {
            let step = Step::from_word(word);
            let label = step.label;
            let rack = &mut room.racks[label.ibox() as usize];
            let lenses = &mut rack.lenses;
            let ipos = lenses.iter().position(|l| l.label == label);
            match step.focal {
                None => {
                    if let Some(i) = ipos {
                        lenses.remove(i);
                    }
                },
                Some(focal) => {
                    let lens = Lens{label, focal};
                    match ipos {
                        Some(i) => {
                            lenses[i] = lens;
                        }
                        None => {
                            lenses.push(lens);
                        }
                    }
                },
            }
        }
    }
    let mut tot = 0;
    for (ir, rack) in room.racks.iter().enumerate() {
        for (il, lens) in rack.lenses.iter().enumerate() {
            tot += ((ir+1) as i64) *
                   ((il+1) as i64) *
                   lens.focal as i64;
        }
    }
    tot
}
