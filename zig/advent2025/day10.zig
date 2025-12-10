const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const filename = "data/input10.txt";
// const filename = "test10.txt";

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

    const p1 = part1(machines);
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1(machines: []const Machine) u32 {
    var tot_press: u32 = 0;
    for (machines) |m| {
        const nbutt: u4 = @intCast(m.buttons.len);
        const nposs: u16 = @as(u16, 1) << nbutt;
        var min_press: u4 = 15;
        // Could be faster if you sorted the butt_combos by bit count?
        for (0..nposs) |butt_combo| {
            var state: u16 = 0;
            var bitmask: u16 = 1;
            var npress: u4 = 0;
            for (0..nbutt) |ibutt| {
                if (bitmask & butt_combo != 0) {
                    state ^= m.buttons[ibutt];
                    npress += 1;
                }
                bitmask = bitmask << 1;
            }
            if (state == m.target) {
                min_press = @min(npress, min_press);
            }
        }
        tot_press += min_press;
    }
    return tot_press;
}

pub fn readMachines(allocator: Allocator, lines: [][]const u8) ![]const Machine{
    const nm = lines.len;
    const machines: []Machine = try allocator.alloc(Machine, nm);
    for (lines, 0..) |line, im| {
        machines[im] = try Machine.init(allocator, line);
    }
    return machines;
}

pub fn countBits(pattern: u16) u4 {
    var nbit: u4 = 0;
    var mask: u4 = 1;
    for (0..15) |_| {
        if (pattern & mask != 0) {
            nbit += 1;
        }
        mask = mask << 1;
    }
    return nbit;
}

const Machine = struct {
    allocator: Allocator,
    nbit: u4,
    target: u16,
    buttons: []u16,

    pub fn init(allocator: Allocator, line: []const u8) !Machine {
        const target_limits = findBrackets(line, 0, "[]").?;
        const target_txt = line[target_limits[0]..target_limits[1]];
        const nbit: u4 = @intCast(target_txt.len);
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
            .nbit = nbit,
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

