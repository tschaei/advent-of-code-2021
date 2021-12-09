const std = @import("std");

const input = @embedFile("day01.input");

pub fn main() anyerror!void {
    const timer = std.time.Timer.start() catch unreachable;

    var p1: u64 = 0;
    var p2: u64 = 0;
    var parsed = [_]usize{0} ** 4;
    var i: usize = 0;
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| : (i += 1) {
        parsed[i % parsed.len] = try std.fmt.parseInt(usize, line, 10);

        if (i >= 1 and parsed[i % parsed.len] > parsed[(i - 1) % parsed.len]) {
            p1 += 1;
        }

        if (i >= 3 and parsed[i % parsed.len] > parsed[(i - 3) % parsed.len]) {
            p2 += 1;
        }
    }
    const time = timer.read();
    std.debug.print("Part 1: {} increases\n", .{p1});
    std.debug.print("Part 2: {} increases\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us", .{@divFloor(time, std.time.ns_per_us)});
}
