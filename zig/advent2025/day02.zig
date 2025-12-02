const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const MAXBUF: usize = 100_000;

const filename = "data/input02.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const ranges = try readRanges(allocator, data_lines.line_list[0]);
    defer allocator.free(ranges);
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
//  @assert(i == nr);
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

