const std = @import("std");

const input = @embedFile("day02.input");

pub fn main() anyerror!void {
    var timer = std.time.Timer.start() catch unreachable;
    var horizontal: u64 = 0;
    var depth_p_1: u64 = 0;
    var depth_p_2: u64 = 0;
    var aim: u64 = 0;
    var lines = std.mem.tokenize(u8, input, "\r\n");

    while (lines.next()) |line| {
        var command = std.mem.tokenize(u8, line, " ");
        const direction = command.next().?;
        const distance = try std.fmt.parseInt(u64, command.next().?, 10);
        if (std.mem.eql(u8, direction, "forward")) {
            horizontal += distance;
            depth_p_2 += distance * aim;
        } else if (std.mem.eql(u8, direction, "up")) {
            depth_p_1 -= distance;
            aim -= distance;
        } else {
            depth_p_1 += distance;
            aim += distance;
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{depth_p_1 * horizontal});
    std.debug.print("Part2: {}\n", .{depth_p_2 * horizontal});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
