
#[derive(PartialEq)]
struct SpringState {
    txt: Vec<u8>,
    counts: Vec<usize>,
}

impl SpringState {
    fn count_possible_matches(&mut self) -> i64 {
        match self.txt.iter().position(|c| c == &b'?') {
            None => {
                if self.can_match() {
                    1
                }
                else {
                    0
                }
            },
            Some(iq) => {
                if self.can_match() {
                    let mut c1 = 0;
                    self.txt[iq] = b'.';
                    c1 += self.count_possible_matches();
                    self.txt[iq] = b'#';
                    c1 += self.count_possible_matches();
                    self.txt[iq] = b'?';
                    c1
                }
                else {
                    0
                }
            },
        }
    }
    fn simplify(&self) -> SpringState {
        let mut txt = self.txt.clone();
        let mut counts = self.counts.clone();
        while txt[0] != b'?' {
            if txt[0] == b'#' && counts.len() > 0 {
                txt.remove(0);
                counts[0] -= 1;
                if counts[0] == 0 {
                    counts.remove(0);
                }
            }
            else if txt[0] == b'.' {
                txt.remove(0);
            }
        }
        SpringState{txt, counts}
    }

    fn can_match(&self) -> bool {
        let ngrp = self.counts.len();
        let mut igrp = 0;
        let mut hash_count = 0;
        for c in &self.txt {
            match c {
                b'#' => {
                    hash_count += 1;
                    if igrp >= self.counts.len() {
                        return false;
                    }
                },
                b'.' => {
                    if hash_count > 0 {
                        if hash_count != self.counts[igrp] {
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
            if hash_count != self.counts[igrp] {
                return false;
            }
            igrp += 1;
        }
        igrp == ngrp
    }
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
        let nmatch = SpringState{txt: map.as_bytes().to_vec(),
                                 counts: counts.clone()}
                    .count_possible_matches();
        tot += nmatch;
    }
    tot
}

pub fn calc12b(lines: Vec<String>) -> i64 {
    let nfold = 5;
    let mut tot = 0;
    for (i, line) in lines.iter().enumerate() {
        let mut split = line.split_whitespace();
        let txt1 = split.next().unwrap().as_bytes();
        let counts: Vec<usize> =
            split.next().unwrap()
           .split(',').map(|x| x.parse().unwrap()).collect();
        let mut map_fold: Vec<u8> = Vec::new();
        let mut counts_fold: Vec<usize> = Vec::new();
        for i in 0..nfold {
            if i > 0 {
                map_fold.push(b'?');
            }
            map_fold.extend_from_slice(txt1);
            counts_fold.extend_from_slice(&counts);
        }
        let nmatch = SpringState{txt: map_fold.clone(),
                                 counts: counts_fold.clone()}
                    .count_possible_matches();
        println!("{}: {}", i, nmatch);
        tot += nmatch;
    }
    tot
}

