
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

fn count_possible_matches(txt: &str, counts: &[usize]) -> i64 {
    match txt.find('?') {
        None => {
            if can_match(txt, counts) {
                1
            }
            else {
                0
            }
        },
        Some(iq) => {
            if can_match(txt, counts) {
                let mut c1 = 0;
                let mut txt1 = String::from(txt);
                txt1.replace_range(iq..iq+1, ".");
                c1 += count_possible_matches(&txt1[..], counts);
                txt1.replace_range(iq..iq+1, "#");
                c1 += count_possible_matches(&txt1[..], counts);
                c1
            }
            else {
                0
            }
        },
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
        let nmatch = count_possible_matches(&map[..], &counts[..]);
        tot += nmatch;
    }
    tot
}
