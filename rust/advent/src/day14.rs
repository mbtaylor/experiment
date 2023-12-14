
struct Dish {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

impl Dish {
    fn from(lines: Vec<String>) -> Dish {
        let mut rows: Vec<Vec<u8>> = Vec::new();
        for line in lines {
            let row = line.bytes().collect();
            rows.push(row)
        }
        let xdim = rows[0].len();
        let ydim = rows.len();
        Dish{rows, xdim, ydim}
    }
    fn get(&self, ix: usize, iy: usize) -> u8 {
        self.rows[iy][ix]
    }
}

pub fn calc14a(lines: Vec<String>) -> i64 {
    let dish = Dish::from(lines);
    let mut tot: i64 = 0;
    let ydim = dish.ydim;
    for ix in 0..dish.xdim {
        let mut iytop = ydim;
        for iy in 0..ydim {
            match dish.get(ix, iy) {
                b'O' => {
                    tot += iytop as i64;
                    iytop -= 1;
                },
                b'#' => {
                    iytop = ydim - iy - 1;
                },
                b'.' => {},
                _ => panic!(),
            }
        }
    }
    tot
}
