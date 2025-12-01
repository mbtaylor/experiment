const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const MAXBUF: usize = 100_000;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    const filename = "data/input01.txt";
    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const p1 = try part1(lines);
    std.debug.print("part 1: {d}\n", .{p1});
    const p2 = try part2(lines);
    std.debug.print("part 2: {d}\n", .{p2});
}

fn part1(lines: [][]const u8) !u32 {
    var p: i32 = 50;
    var n0: u32 = 0;
    for (lines) |line| {
        const c0: u8 = line[0];
        const sense: i32 = try switch (c0) {
            'L' => @as(i32, -1),
            'R' => @as(i32, 1),
            else => error.ParseLine,
        };
        const num = try std.fmt.parseInt(i32, line[1..], 10);
        p += sense * num;
        if (@mod(p, @as(u32, 100)) == 0) {
            n0 += 1;
        }
    }
    return n0;
}

fn part2(lines: [][]const u8) !u32 {
    // brute force!
    var p: i32 = 50;
    var n0: u32 = 0;
    for (lines) |line| {
       const c0: u8 = line[0];
       const sense: i32 = try switch (c0) {
           'L' => @as(i2, -1),
           'R' => @as(i2, 1),
           else => error.ParseLine,
       };
       var num = try std.fmt.parseInt(u32, line[1..], 10);
       while (num > 0) : (num -= 1) {
           p += sense;
           if (@mod(p, @as(u32, 100)) == 0) {
               n0 += 1;
           }
       }
    }
    return n0;
}

fn readLines(allocator: Allocator, filename: []const u8) !DataLines {
    const content = try std.fs.cwd().readFileAlloc(allocator, filename, MAXBUF);
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
