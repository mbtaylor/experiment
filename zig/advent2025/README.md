# Advent of Code 2025 in Zig

I did AoC in Zig this year, encouraged (and a little bit helped) by Fergus.
After a shaky start, it went OK.

I got all the stars except for day 10 part 2, which kept me awake
several nights and I still failed at.  I have got an idea how to
do it from scratch (i.e. without using some external Integer Linear
Programming library) but (a) I don't know if it would succeed and
(b) it's a bit too much like hard work.

Apart from that failure, the result is FAST!  Total runtime of about
250ms on my laptop, when running with -O ReleaseFast

To run these you will need to install zig.
I'm using version 0.15.2.
You can download it from here:

> https://ziglang.org/download/

Input data is assumed to be in files named like "data/input01.txt" etc.
To run a single day:
```
 zig run day01.zig
```

To run the whole lot with timings:
```
   make bench
```
or
```
   make bench-all
```

