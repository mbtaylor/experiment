const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;

const filename = "data/input03.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const p1 = part1(lines);
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = part2(lines);
    std.debug.print("Part 2: {d}\n", .{p2});
}

fn part1(lines: [][]const u8) u64 {
    return joltage(lines, 2);
}

fn part2(lines: [][]const u8) u64 {
    return joltage(lines, 12);
}

fn joltage(lines: [][]const u8, nbatt: usize) u64 {
    var sum: u64 = 0;
    for (lines) |line| {
        var jolt: u64 = 0;
        var ic: usize = 0;
        for (0..nbatt) |ibatt| {
            const kbatt = nbatt - ibatt - 1;
            ic += find_max_index(line[ic..line.len-kbatt]);
            jolt += std.math.pow(u64, 10, kbatt) * (line[ic] - '0');
            ic += 1;
        }
        sum += jolt;
    }
    return sum;
}

fn find_max_index(line: []const u8) usize {
    var maxval: u8 = 0;
    var maxix: usize = 0;
    for (line, 0..) |c, ix| {
        if (c > maxval) {
            maxval = c;
            maxix = ix;
        }
    }
    return maxix;
}


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
