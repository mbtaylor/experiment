
fn hash(txt: &str) -> i64 {
    let mut h = 0;
    for b in txt.as_bytes() {
        h += *b as i64;
        h *= 17;
        h = h % 256;
    }
    h
}

pub fn calc15a(lines: Vec<String>) -> i64 {
    let mut tot = 0;
    for line in lines {
        for word in line.split(',') {
            tot += hash(word);
        }
    }
    tot
}
