const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const MAXBUF: usize = 100_000;

const filename = "data/input03.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const p1 = try part1(lines);
    std.debug.print("Part 1: {d}\n", .{p1});
}

fn part1(lines: [][]const u8) !u32 {
    var sum: u32 = 0;
    for (lines) |line| {
        const ic0 = find_max_index(line[0..line.len-1]);
        const ic1 = find_max_index(line[ic0+1..line.len]) + ic0 + 1;
        const jolt = (line[ic0] - '0') * 10 + (line[ic1] - '0');
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
