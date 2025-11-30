const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const MAXBUF: usize = 100_000;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    const filename = "day0.txt";
    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    try process(data_lines.line_list);
}

fn process(lines: [][]const u8) !void {
    for (lines) |line| {
        const i = try std.fmt.parseInt(i32, line, 10);
        std.debug.print(" -- {d}\n", .{i});
    }
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
