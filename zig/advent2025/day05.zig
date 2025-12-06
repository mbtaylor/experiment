const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const filename = "data/input05.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const input: Input = try Input.init(allocator, lines);
    defer input.deinit();

    const p1 = part1(input);
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = try part2(input);
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(input: Input) u64 {
    var nfresh: u64 = 0;
    for (input.ids) |id| {
        var is_fresh = false;
        for (input.ranges) |range| {
            if (range.inRange(id)) {
                is_fresh = true;
                break;
            }
        }
        if (is_fresh) {
            nfresh += 1;
        }
    }
    return nfresh;
}

pub fn part2(input: Input) !u64 {
    const allocator = gpa.allocator();
    var out_range_list: std.ArrayList(Range) = .empty;
    for (input.ranges) |in_range| {
        try addRange(allocator, &out_range_list, in_range);
    }
    const out_ranges = try out_range_list.toOwnedSlice(allocator);
    defer allocator.free(out_ranges);
    var sum: u64 = 0;
    for (out_ranges) |range| {
        sum += range.hi - range.lo + 1;
    }
    return sum;
}

fn addRange(allocator: Allocator,
            out_ranges: *std.ArrayList(Range), in_range: Range) !void {
    const ilo = in_range.lo;
    const ihi = in_range.hi;
    for (out_ranges.items) |out_range| {
        const olo = out_range.lo;
        const ohi = out_range.hi;
        if (ilo >= olo and ihi <= ohi) {
            return;
        }
        else if (ilo < olo and ihi > ohi) {
            try addRange(allocator,
                         out_ranges, Range{.lo = ilo, .hi = olo - 1});
            try addRange(allocator,
                         out_ranges, Range{.lo = olo + 1, .hi = ihi});
            return;
        }
        else if (ilo < olo and ihi >= olo) {
            try addRange(allocator,
                         out_ranges, Range{.lo = ilo, .hi = olo - 1});
            return;
        }
        else if (ilo <= ohi and ihi > ohi) {
            try addRange(allocator,
                         out_ranges, Range{.lo = ohi + 1, .hi = ihi});
            return;
        }
    }
    try out_ranges.append(allocator, in_range);
}

const Input = struct {
    allocator: Allocator,
    ranges: []const Range,
    ids: []const u64,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Input {
        var is_range_list: bool = true;
        var range_list: std.ArrayList(Range) = .empty;
        var id_list: std.ArrayList(u64) = .empty;
        for (lines) |line| {
            if (is_range_list) {
                if (line.len == 0) {
                    is_range_list = false;
                }
                else {
                    try range_list.append(allocator, try Range.init(line));
                }
            }
            else {
                try id_list.append(allocator,
                                   try std.fmt.parseInt(u64, line, 10));
            }
        }
        const ranges = try range_list.toOwnedSlice(allocator);
        const ids = try id_list.toOwnedSlice(allocator);
        return Input{
            .allocator = allocator,
            .ranges = ranges,
            .ids = ids,
        };
    }

    pub fn deinit(self: Input) void {
        self.allocator.free(self.ranges);
        self.allocator.free(self.ids);
    }
};

const Range = struct {
    lo: u64,
    hi: u64,

    pub fn init(line: []const u8) !Range {
        const idash = std.mem.indexOfScalar(u8, line, '-').?;
        const lo = try std.fmt.parseInt(u64, line[0..idash], 10);
        const hi = try std.fmt.parseInt(u64, line[idash+1..line.len], 10);
        return Range{
            .lo = lo,
            .hi = hi
        };
    }

    pub fn inRange(self: Range, val: u64) bool {
        return val >= self.lo and val <= self.hi;
    }
};

fn readLines(allocator: Allocator, fname: []const u8) !DataLines {
    const content = try std.fs.cwd().readFileAlloc(allocator, fname, MAXBUF);
    var line_list: std.ArrayList([]const u8) = .empty;
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
