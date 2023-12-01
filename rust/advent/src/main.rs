use std::io;

fn main() {
    let mut line = String::new();
    let stdin = io::stdin();
    let mut tot = 0;
    loop {
        line.clear();
        match stdin.read_line(&mut line) {
            Ok(siz) => match siz {
                0 => break,
                _ => {},
            },
            Err(error) => { println!("{}", error); break },
        };
        let line = line.trim();
        let mut d1 = 0;
        let mut d2 = 0;
        for c in line.as_bytes() {
            let d = ( *c as i32 ) - 0x30;
            if d >= 0 && d <= 9 {
                if d1 == 0 {
                    d1 = d;
                }
                d2 = d;
            }
        }
        let dd = d1 * 10 + d2;
        tot += dd;
    }
    println!("{}", tot);
}
