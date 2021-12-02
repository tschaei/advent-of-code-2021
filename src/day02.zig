const std = @import("std");

const input = @embedFile("day02.input");

pub fn main() anyerror!void {
    var timer = std.time.Timer.start() catch unreachable;
    var horizontal: usize = 0;
    var depth_p1: usize = 0;
    var depth_p2: usize = 0;
    var aim: usize = 0;
    var lines = std.mem.tokenize(u8, input, "\r\n");

    while (lines.next()) |line| {
        var command = std.mem.tokenize(u8, line, " ");
        const direction = command.next() orelse return;
        const distance = try std.fmt.parseInt(usize, command.next() orelse return, 10);
        if (std.mem.eql(u8, direction, "forward")) {
            horizontal += distance;
            depth_p2 += distance * aim;
        } else if (std.mem.eql(u8, direction, "up")) {
            depth_p1 -= distance;
            aim -= distance;
        } else {
            depth_p1 += distance;
            aim += distance;
        }
    }

    const elapsed_time = timer.read();
    std.debug.warn("Part 1: depth: {}, horizontal: {}. Solution: {}\n", .{ depth_p1, horizontal, depth_p1 * horizontal });
    std.debug.warn("Part 2: depth: {}, aim: {}. Solution: {}\n", .{ depth_p2, aim, depth_p2 * horizontal });
    std.debug.warn("Runtime (excluding output): {}us\n", .{elapsed_time / std.time.ns_per_us});
}
