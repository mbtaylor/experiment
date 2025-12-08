const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const MAXBUF: usize = 100_000;

const filename = "data/input02.txt";
// const filename = "test02.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const ranges = try readRanges(allocator, data_lines.line_list[0]);
    defer allocator.free(ranges);

    const p1 = try part1(allocator, ranges);
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = try part2(allocator, ranges);
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn part1(allocator: Allocator, ranges: []const Range) !u64 {
    var set = IntSet.init(allocator);
    defer set.deinit();
    for (ranges) |range| {
        try addInvalids(range, 2, &set);
    }
    return sum_keys(set);
}

fn part2(allocator: Allocator, ranges: []const Range) !u64 {
    var set = IntSet.init(allocator);
    defer set.deinit();
    for (ranges) |range| {
        for (2..12) |rc| {
            const repeat_count: u8 = @intCast(rc);
            try addInvalids(range, repeat_count, &set);
        }
    }
    return sum_keys(set);
}

fn addInvalids(range: Range, repeat_count: u8, set: *IntSet) !void {
    const ndlo = range.lotxt.len;
    const ndhi = range.hitxt.len;
    if (ndlo == ndhi) {
        try addEqualLengthInvalids(range, repeat_count, set);
        return;
    }
    else if (ndhi - ndlo > 1) {
        return error.UhOh;
    }
    if (ndlo % repeat_count == 0) {
        const lo = range.loval;
        const hi = std.math.pow(u64, 10, range.lotxt.len) - 1;
        var buf: [64]u8 = undefined;
        const rword = try std.fmt.bufPrint(&buf, "{d}-{d}", .{lo, hi});
        try addEqualLengthInvalids(try Range.init(rword), repeat_count, set);
    }
    if (ndhi % repeat_count == 0) {
        const lo = std.math.pow(u64, 10, range.lotxt.len);
        const hi = range.hival;
        var buf: [64]u8 = undefined;
        const rword = try std.fmt.bufPrint(&buf, "{d}-{d}", .{lo, hi});
        try addEqualLengthInvalids(try Range.init(rword), repeat_count, set);
    }
}

fn addEqualLengthInvalids(range: Range, repeat_count: u8, set: *IntSet) !void {
    const ndlo = range.lotxt.len;
    const ndhi = range.hitxt.len;
    if (ndlo != ndhi) {
        return error.UhOh;
    }
    if (ndlo % repeat_count == 0) {
        const ndn = ndlo / repeat_count;
        const lopref = try std.fmt.parseInt(u64, range.lotxt[0..ndn], 10);
        const hipref = try std.fmt.parseInt(u64, range.hitxt[0..ndn], 10);
        const v1 = repeat(lopref, ndn, repeat_count);
        if (range.inRange(v1)) {
            try set.put_int(v1);
        } 
        if (hipref > lopref) {
            const v2 = repeat(hipref, ndn, repeat_count);
            if (range.inRange(v2)) {
                try set.put_int(v2);
            }
            for (lopref+1..hipref) |p| {
                const v3 = repeat(p, ndn, repeat_count);
                try set.put_int(v3);
            }
        }
    }
}

fn sum_keys(set: IntSet) u64 {
    var iterator = set.intIterator();
    var sum: u64 = 0;
    while (iterator.next()) |key| {
        sum += key.*;
    }
    return sum;
}

fn repeat(el: u64, n_digit: u64, repeat_count: u8) u64 {
    var val: u64 = 0;
    var fact: u64 = 1;
    for (0..repeat_count) |_| {
        val = val + el * fact;
        fact *= std.math.pow(u64, 10, n_digit);
    }
    return val;
}

fn readRanges(allocator: Allocator, line: []const u8) ![]const Range {
    const nr = 1 + std.mem.count(u8, line, ",");
    const ranges = try allocator.alloc(Range, nr);
    var splitIt = std.mem.splitScalar(u8, line, ',');
    var i: usize = 0;
    while (splitIt.next()) |word| {
        ranges[i] = try Range.init(word);
        i += 1;
    }
    return ranges;
}

const Range = struct {
    word: []const u8,
    lotxt: []const u8,
    hitxt: []const u8,
    loval: u64,
    hival: u64,

    pub fn init(word: []const u8) !Range {
        var lotxt: []const u8 = undefined;
        var hitxt: []const u8 = undefined;
        for (word, 0..) |c, i| {
            if (c == '-') {
                lotxt = word[0..i];
                hitxt = word[i+1..];
                break;
            }
        }
        return Range{
            .word = word,
            .lotxt = lotxt,
            .hitxt = hitxt,
            .loval = try std.fmt.parseInt(u64, lotxt, 10),
            .hival = try std.fmt.parseInt(u64, hitxt, 10),
        };
    }

    pub fn inRange(self: Range, val: u64) bool {
        return val >= self.loval and val <= self.hival;
    }
};

const IntSet: type = struct {
    const MapType = std.AutoHashMap(u64, void);

    map: std.AutoHashMap(u64, void),

    pub fn init(allocator: Allocator) IntSet {
        const map = std.AutoHashMap(u64, void).init(allocator);
        return IntSet{
            .map = map,
        };
    }

    pub fn deinit(self: *IntSet) void {
        self.map.deinit();
    }

    pub fn put_int(self: *IntSet, num: u64) !void {
        try self.map.put(num, {});
    }

    pub fn intIterator(self: IntSet) MapType.KeyIterator {
        return self.map.keyIterator();
    }
};

fn readLines(allocator: Allocator, fname: []const u8) !DataLines {
    const content = try std.fs.cwd().readFileAlloc(allocator, fname, MAXBUF);
    var line_list: ArrayList([]const u8) = .empty;
    var splitIt = std.mem.splitScalar(u8, content, '\n');
    while (splitIt.next()) |line| {
        try line_list.append(allocator, line);
    }
    if (line_list.getLast().len == 0) {
        _ = line_list.pop();
    }
    return DataLines {
        .allocator = allocator,
        .line_list = try line_list.toOwnedSlice(allocator),
        .buf = content,
    };
}

const DataLines = struct {
    allocator: Allocator,
    line_list: [][]const u8,
    buf: []const u8,

    pub fn deinit(self: DataLines) void {
        self.allocator.free(self.line_list);
        self.allocator.free(self.buf);
    }
};
