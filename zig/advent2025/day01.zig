const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const MAXBUF: usize = 100_000;

const filename = "data/input01.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    const codes = try toCodes(allocator, data_lines);
    data_lines.deinit();
    defer allocator.free(codes);

    const p1 = try part1(codes);
    std.debug.print("part 1: {d}\n", .{p1});
    const p2 = try part2(codes);
    std.debug.print("part 2: {d}\n", .{p2});
}

fn part1(codes: []const Code) !u32 {
    var p: i32 = 50;
    var n0: u32 = 0;
    for (codes) |code| {
        p += code.product();
        if (@mod(p, @as(u32, 100)) == 0) {
            n0 += 1;
        }
    }
    return n0;
}

fn part2(codes: []const Code) !u32 {
    // brute force!
    var p: i32 = 50;
    var n0: u32 = 0;
    for (codes) |code| {
       var num = code.num;
       while (num > 0) : (num -= 1) {
           p += code.sense;
           if (@mod(p, @as(u32, 100)) == 0) {
               n0 += 1;
           }
       }
    }
    return n0;
}

fn toCodes(allocator: Allocator, data_lines: DataLines) ![]const Code {
    const lines = data_lines.line_list;
    const n = lines.len;
    const codes: []Code = try allocator.alloc(Code, n);
    for (data_lines.line_list, 0..) |line, i| {
        const sense: i2 = try switch (line[0]) {
            'L' => @as(i2, -1),
            'R' => @as(i2, 1),
            else => error.ParseLine,
        };
        const num = try std.fmt.parseInt(u16, line[1..], 10);
        codes[i] = Code{.sense = sense, .num = num};
    }
    return codes;
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

const Code = struct {
    sense: i2,
    num: u16,

    fn product(self: Code) i32 {
        return @as(i32, self.sense) * @as(i32, self.num);
    }
};
