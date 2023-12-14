
#[derive(PartialEq)]
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
    fn simplify(&self) -> SpringState {
        let mut txt = self.txt.clone();
        let mut counts = self.counts.clone();
        while txt.as_bytes()[0] != b'?' {
            if txt.as_bytes()[0] == b'#' && counts.len() > 0 {
                txt.remove(0);
                counts[0] -= 1;
                if counts[0] == 0 {
                    counts.remove(0);
                }
            }
            else if txt.as_bytes()[0] == b'.' {
                txt.remove(0);
            }
        }
        SpringState{txt, counts}
    }

    fn count_possible_matches_b(&mut self) -> i64 {
        if !self.can_match() {
            return 0
        }
        match self.txt.find('?') {
            None => 1,
            Some(iq) => {
                let mut state = self.simplify();
                if state.counts.len() == 0 {
                    return 0;
                }
                if &state == self {
                    assert!(state.txt.as_bytes()[0] == b'?');
                    let mut ic = 0;
                    state.txt.replace_range(0..1, ".");
                    ic += state.count_possible_matches_b();
                    state.txt.replace_range(0..1, "#");
                    ic += state.count_possible_matches_b();
                    return ic;
                }
                let nq = state.txt.bytes().take_while(|c| c == &b'?').count();
                let mut ic = 0;
                let c0 = state.counts[0];
                let nfill = if nq > state.counts[0] { nq - state.counts[0] }
                                               else { nq };
                for i in 0..nfill {
                    let mut rep = String::with_capacity(c0);
                    for j in 0..c0 {
                        if j < i {
                            rep.push('.');
                        }
                        else if j >= i && j < i + nq {
                            rep.push('#');
                        }
                        else {
                            rep.push('?');
                        }
                    }
                    state.txt.replace_range(i..i+c0, &rep[..]);
                    ic += state.count_possible_matches_b();
                }
                ic
            }
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
                    .count_possible_matches_b();
        println!("{}: {}", i, nmatch);
        tot += nmatch;
    }
    tot
}

