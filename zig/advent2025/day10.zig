const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

// const filename = "data/input10.txt";
const filename = "test10.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const machines = try readMachines(allocator, lines);
    defer {
        for (machines) |machine| {
            machine.deinit();
        }
        allocator.free(machines);
    }
}

pub fn readMachines(allocator: Allocator, lines: [][]const u8) ![]const Machine{
    const nm = lines.len;
    const machines: []Machine = try allocator.alloc(Machine, nm);
    for (lines, 0..) |line, im| {
        machines[im] = try Machine.init(allocator, line);
    }
    return machines;
}

const Machine = struct {
    allocator: Allocator,
    target: u16,
    buttons: []u16,

    pub fn init(allocator: Allocator, line: []const u8) !Machine {
        const target_limits = findBrackets(line, 0, "[]").?;
        const target_txt = line[target_limits[0]..target_limits[1]];
        var target: u16 = 0;
        var mask: u16 = 1;
        for (target_txt) |c| {
            if (c == '#') {
                target = target | mask;
            }
            mask = mask << 1;
        }
        var butt_list: std.ArrayList(u16) = .empty;
        var ipos: usize = target_limits[1];
        while (findBrackets(line, ipos, "()")) |butt_limits| {
            const butt_txt = line[butt_limits[0]..butt_limits[1]];
            ipos = butt_limits[1];
            var splitIt = std.mem.splitScalar(u8, butt_txt, ',');
            var butt_mask: u16 = 0;
            while (splitIt.next()) |word| {
                const ibutt = try std.fmt.parseInt(u4, word, 10);
                butt_mask |= @as(u16, 1) << ibutt;
            }
            try butt_list.append(allocator, butt_mask);
        }
        const buttons = try butt_list.toOwnedSlice(allocator);
        return .{
            .allocator = allocator,
            .target = target,
            .buttons = buttons,
        };
    }

    pub fn deinit(self: Machine) void {
        self.allocator.free(self.buttons);
    }

    fn findBrackets(line: []const u8, istart: usize, brackets: *const [2:0]u8)
                   ?[2]usize {
        if (std.mem.indexOfScalar(u8, line[istart..line.len], brackets[0])) |j|{
            const j0 = j + istart;
            const j1 =
                std.mem.indexOfScalar(u8, line[j0..line.len], brackets[1]).?
                + j0;
            return .{j0+1, j1};
        }
        else {
            return null;
        }
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

