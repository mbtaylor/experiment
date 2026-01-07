const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
const MAXJOLT: u32 = 999;
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

    // Hopeless.  I thought this might complete in a reasonable time,
    // but for some of the inputs it's more than a day.  Give up.
//  const p2 = try part2(allocator, machines);
//  std.debug.print("Part 2: {d}\n", .{p2});
    std.debug.print("Part 2: {s}\n", .{"Give up."});
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

pub fn part2(allocator: Allocator, machines: []const Machine) !u32 {
    var sum: u32 = 0;
    for (machines, 0..) |*m, i| {
        const t0 = std.time.nanoTimestamp();
        const jp = try countJoltPushes(allocator, m);
        const millis = @divFloor(std.time.nanoTimestamp()-t0, 1000000);
        sum += jp;
  std.debug.print("{d}:\t{d}\t{d}ms\n", .{i+1,jp,millis});
    }
    return sum;
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
    var mask: u16 = 1;
    for (0..15) |_| {
        if (pattern & mask != 0) {
            nbit += 1;
        }
        mask = mask << 1;
    }
    return nbit;
}

fn countJoltPushes(allocator0: Allocator, m: *const Machine) !u32 {
    var arena = std.heap.ArenaAllocator.init(allocator0);
    defer arena.deinit();
    var allocator = arena.allocator();
    const nbutt = m.buttons.len;
    const njolt = m.joltages.len;
    const mbutts: []u16 = try allocator.alloc(u16, nbutt);
    std.mem.copyForwards(u16, mbutts, m.buttons);
    std.mem.sort(u16, mbutts, {}, cmpByBitCount);

    const sbutts: [][]usize = try allocator.alloc([]usize, nbutt);
    for (0..nbutt) |i| {
        const mbutt = mbutts[i];
        sbutts[i] = try allocator.alloc(usize, countBits(mbutt));
        var mask: u16 = 1;
        var j: usize = 0;
        for (0..15) |ibit| {
            if (mbutt & mask != 0) {
                sbutts[i][j] = ibit;
                j += 1;
            }
            mask = mask << 1;
        }
        // not really necessary
        std.debug.assert(sbutts[i].len == countBits(mbutt));
    }

    const pushes: []u32 = try allocator.alloc(u32, nbutt);
    const jolts: []u32 = try allocator.alloc(u32, njolt);
    @memset(pushes, 0);
    @memset(jolts, 0);
    var ibutt: usize = 0;
    while (true) {
        const butt = sbutts[ibutt];
        const pmax = maxPushes(butt, jolts, m.joltages);
        if (pmax > 0) {
            pushes[ibutt] = pmax;
            pushButton(butt, pmax, jolts);
        }
        if (ibutt == nbutt-1) {
            if (std.mem.eql(u32, jolts, m.joltages)) {
                var npush: u32 = 0;
                for (pushes) |p| {
                    npush += p;
                }
                return npush;
            }
            else {
                while (ibutt>0) {
                    pushes[ibutt] = 0;
                    if (pushes[ibutt-1]>0) {
                        pushes[ibutt-1] -= 1;
                        break;
                    }
                    else {
                        ibutt -= 1;
                    }
                }
                pushButtons(sbutts, pushes, jolts);
            }
        }
        else {
            ibutt += 1;
        }
    }
    unreachable;
}

fn pushButton(butt: []usize, npush: u32, jolts: []u32) void {
    for (butt) |i| {
        jolts[i] += npush;
    }
}

fn pushButtons(butts: [][]usize, pushes: []u32, jolts: []u32) void {
    @memset(jolts, 0);
    for (butts, pushes) |b, p| {
        pushButton(b, p, jolts);
    }
}

fn maxPushes(butt: []usize, c_jolts: []const u32, t_jolts: []const u32) u32 {
    var maxdiff: ?u32 = null;
    for (butt) |i| {
        const diff = t_jolts[i] - c_jolts[i];
        if (maxdiff) |m| {
            maxdiff = @min(m, diff);
        }
        else {
            maxdiff = diff;
        }
    }
    return maxdiff.?;
}

fn cmpByBitCount(context: void, b1: u16, b2: u16) bool {
    return std.sort.desc(u16)(context, countBits(b1), countBits(b2));
}

fn cmpByLen(context: void, b1: []usize, b2: []usize) bool {
    return std.sort.desc([]usize)(context, b1.len, b2.len);
}

const Machine = struct {
    allocator: Allocator,
    target: u16,
    buttons: []const u16,
    joltages: []const u32,

    pub fn init(allocator: Allocator, line: []const u8) !Machine {
        const target_limits = findBrackets(line, 0, "[]").?;
        const target_txt = line[target_limits[0]..target_limits[1]];
        const nlight: u4 = @intCast(target_txt.len);
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
            var split_it = std.mem.splitScalar(u8, butt_txt, ',');
            var butt_mask: u16 = 0;
            while (split_it.next()) |word| {
                const ibutt = try std.fmt.parseInt(u4, word, 10);
                butt_mask |= @as(u16, 1) << ibutt;
            }
            try butt_list.append(allocator, butt_mask);
        }
        const buttons = try butt_list.toOwnedSlice(allocator);
        const jolt_limits = findBrackets(line, ipos, "{}").?;
        const jolt_txt = line[jolt_limits[0]..jolt_limits[1]];
        var joltages: []u32 = try allocator.alloc(u32, nlight);
        var split_it = std.mem.splitScalar(u8, jolt_txt, ',');
        var ij: usize = 0;
        while (split_it.next()) |word| {
            joltages[ij] = try std.fmt.parseInt(u32, word, 10);
            ij += 1;
        }
        return .{
            .allocator = allocator,
            .target = target,
            .buttons = buttons,
            .joltages = joltages,
        };
    }

    pub fn deinit(self: Machine) void {
        self.allocator.free(self.buttons);
        self.allocator.free(self.joltages);
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
