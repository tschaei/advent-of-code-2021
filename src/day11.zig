const std = @import("std");

const input = @embedFile("day11.input");

const size = 10;

const Offset = struct {
    x: i64,
    y: i64,
};

fn increase(flashed: *[size][size]bool, energy: *[size][size]u8, row_idx: i64, o_idx: i64) u64 {
    if (row_idx < 0 or row_idx >= energy.len or o_idx < 0 or o_idx >= energy[0].len) {
        return 0;
    }
    const r = @intCast(usize, row_idx);
    const o = @intCast(usize, o_idx);
    if (flashed[r][o]) {
        return 0;
    }

    energy[r][o] += 1;
    if (energy[r][o] <= 9) {
        return 0;
    }

    return flash(flashed, energy, row_idx, o_idx);
}

fn flash(flashed: *[size][size]bool, energy: *[size][size]u8, row_idx: i64, o_idx: i64) u64 {
    const r = @intCast(usize, row_idx);
    const o = @intCast(usize, o_idx);
    var result: u64 = 1;
    flashed[r][o] = true;

    const neighbor_offsets = [_]Offset{
        .{ .x = -1, .y = -1 },
        .{ .x = 0, .y = -1 },
        .{ .x = 1, .y = -1 },
        .{ .x = -1, .y = 0 },
        .{ .x = 1, .y = 0 },
        .{ .x = -1, .y = 1 },
        .{ .x = 0, .y = 1 },
        .{ .x = 1, .y = 1 },
    };
    for (neighbor_offsets) |offset| {
        result += increase(flashed, energy, row_idx + offset.y, o_idx + offset.x);
    }

    energy[r][o] = 0;
    return result;
}

fn step(flashed: *[size][size]bool, energy: *[size][size]u8) u64 {
    for (flashed) |*row| {
        std.mem.set(bool, &row.*, false);
    }

    for (energy) |*row| {
        for (row.*) |*octopus| {
            octopus.* += 1;
        }
    }

    var result: usize = 0;
    for (energy) |*row, row_idx| {
        for (row.*) |octopus, o_idx| {
            if (octopus > 9) {
                result += flash(flashed, energy, @intCast(i64, row_idx), @intCast(i64, o_idx));
            }
        }
    }

    return result;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var flashed = [_][size]bool{[_]bool{false} ** size} ** size;
    var energy = [_][size]u8{[_]u8{0} ** size} ** size;
    var p1: u64 = 0;

    var line_idx: usize = 0;
    while (lines.next()) |line| : (line_idx += 1) {
        for (line) |c, idx| {
            energy[line_idx][idx] = try std.fmt.parseInt(u8, &.{c}, 10);
        }
    }

    var current_step: usize = 0;
    outer: while (true) : (current_step += 1) {
        const flashes = step(&flashed, &energy);
        if (current_step < 100) {
            p1 += flashes;
        }

        for (flashed) |row| {
            for (row) |o| {
                if (!o) {
                    continue :outer;
                }
            }
        }
        current_step += 1;
        break;
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{current_step});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
