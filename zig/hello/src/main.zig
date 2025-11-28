const std = @import("std");
const hello = @import("hello");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    std.debug.print("This goes to {s}\n", .{"stderr"});

    var gpa = std.heap.DebugAllocator(.{}){};
    const stdout_alloc = gpa.allocator();
    const stdout = try create_stdout(stdout_alloc, @as(usize, 1024));
    try stdout.print("This goes to {s}\n", .{"stdout"});
    try stdout.flush();
}

fn create_stdout(allocator: Allocator, siz: usize) !*std.Io.Writer {
    const buf: []u8 = try allocator.alloc(u8, siz);
    std.debug.print("buf: {any}", .{buf.len});
    const writer_ptr = try allocator.create(std.fs.File.Writer);
    writer_ptr.* = std.fs.File.stdout().writer(buf);
    return &writer_ptr.interface;
}
