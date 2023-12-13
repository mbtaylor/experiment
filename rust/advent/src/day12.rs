
struct Calculator {
    txt: String,
    counts: Vec<usize>,
}

impl Calculator {
    fn count_possible_matches(&mut self) -> i64 {
        match self.txt.find('?') {
            None => {
                if can_match(&self.txt[..], &self.counts[..]) {
                    1
                }
                else {
                    0
                }
            },
            Some(iq) => {
                if can_match(&self.txt[..], &self.counts[..]) {
                    let mut c1 = 0;
                    self.txt.replace_range(iq..iq+1, ".");
                    c1 += self.count_possible_matches();
                    self.txt.replace_range(iq..iq+1, "#");
                    c1 += self.count_possible_matches();
                    self.txt.replace_range(iq..iq+1, "?");
                    c1
                }
                else {
                    0
                }
            },
        }
    }
}

fn can_match(txt: &str, counts: &[usize]) -> bool {
    let ngrp = counts.len();
    let mut igrp = 0;
    let mut hash_count = 0;
    for c in txt.as_bytes() {
        match c {
            b'#' => {
                hash_count += 1;
                if igrp >= counts.len() {
                    return false;
                }
            },
            b'.' => {
                if hash_count > 0 {
                    if hash_count != counts[igrp] {
                        return false;
                    }
                    hash_count = 0;
                    igrp += 1;
                }
            },
            b'?' => {
                return true;
            },
            _ => {
                panic!();
            },
        }
    }
    if hash_count > 0 {
        if hash_count != counts[igrp] {
            return false;
        }
        igrp += 1;
    }
    igrp == ngrp
}

pub fn calc12a(lines: Vec<String>) -> i64 {
    let mut tot = 0;
    for line in lines {
        let mut split = line.split_whitespace();
        let map = split.next().unwrap();
        let npos = map.len();
        let counts: Vec<usize> =
            split.next().unwrap()
           .split(',').map(|x| x.parse().unwrap()).collect();
        let nmatch = Calculator{txt: String::from(map), counts: counts.clone()}
                    .count_possible_matches();
        tot += nmatch;
    }
    tot
}
