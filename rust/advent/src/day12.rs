
struct SpringState {
    txt: String,
    counts: Vec<usize>,
}

impl SpringState {
    fn count_possible_matches(&mut self) -> i64 {
        match self.txt.find('?') {
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

    fn can_match(&self) -> bool {
        let ngrp = self.counts.len();
        let mut igrp = 0;
        let mut hash_count = 0;
        for c in self.txt.as_bytes() {
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
        let nmatch = SpringState{txt: String::from(map), counts: counts.clone()}
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
        let map = split.next().unwrap();
        let counts: Vec<usize> =
            split.next().unwrap()
           .split(',').map(|x| x.parse().unwrap()).collect();
        let mut map_fold: String = String::new();
        let mut counts_fold: Vec<usize> = Vec::new();
        for i in 0..nfold {
            if i > 0 {
                map_fold.push('?');
            }
            map_fold.push_str(&map);
            for c in &counts {
                counts_fold.push(*c);
            }
        }
        let nmatch = SpringState{txt: String::from(map_fold),
                                 counts: counts_fold.clone()}
                    .count_possible_matches();
        println!("{}: {}", i, nmatch);
        tot += nmatch;
    }
    tot
}

