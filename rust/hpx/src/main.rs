use cdshealpix::nested::{to_zuniq, to_uniq_ivoa};

fn main() {
    println!("order\tindex\tnuniq\tzuniq");
    for (l, i) in [(0,11), (1,11), (28,11), (29,11)] {
       println!("{}\t{}\t-> {}\t{}", l, i, to_uniq_ivoa(l,i), to_zuniq(l,i));
    }
}
