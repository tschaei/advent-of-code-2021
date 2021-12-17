const std = @import("std");

const input = @embedFile("day17.input");

const Velocity = struct {
    x: i64,
    y: i64,
};

const Position = struct {
    x: i64,
    y: i64,
};

const Probe = struct {
    p: Position,
    vel: Velocity,
};

const TargetArea = struct {
    left: i64,
    right: i64,
    top: i64,
    bottom: i64,
};

inline fn sign(v: i64) i64 {
    if (v == 0) {
        return 0;
    } else if (v < 0) {
        return -1;
    } else {
        return 1;
    }
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    const in_bytes = @embedFile("day17.input");
    var xy_inputs = std.mem.split(u8, in_bytes, ", ");
    var x_input = std.mem.split(u8, xy_inputs.next() orelse unreachable, "=");
    _ = x_input.next();
    var x_range = std.mem.split(u8, x_input.next() orelse unreachable, "..");
    const x_values = [_]i64{ try std.fmt.parseInt(i64, x_range.next() orelse unreachable, 10), try std.fmt.parseInt(i64, x_range.next() orelse unreachable, 10) };
    var y_input = std.mem.split(u8, xy_inputs.next() orelse unreachable, "=");
    _ = y_input.next();
    var y_range = std.mem.split(u8, y_input.next() orelse unreachable, "..");
    const y_values = [_]i64{ try std.fmt.parseInt(i64, y_range.next() orelse unreachable, 10), try std.fmt.parseInt(i64, y_range.next() orelse unreachable, 10) };
    const target_area = TargetArea{
        .left = std.math.min(x_values[0], x_values[1]),
        .right = std.math.max(x_values[0], x_values[1]),
        .top = std.math.max(y_values[0], y_values[1]),
        .bottom = std.math.min(y_values[0], y_values[1]),
    };

    var max_y: i64 = 0;
    var valid_initial_velocities: u64 = 0;
    var vel_x: i64 = 0;
    while (vel_x <= 200) : (vel_x += 1) {
        var vel_y: i64 = -200;
        while (vel_y <= 200) : (vel_y += 1) {
            var probe = Probe{
                .p = .{ .x = 0, .y = 0 },
                .vel = .{ .x = vel_x, .y = vel_y },
            };

            var current_max_y: i64 = 0;
            while (probe.p.y >= target_area.bottom and probe.p.x <= target_area.right) {
                probe.p.x += probe.vel.x;
                probe.p.y += probe.vel.y;
                probe.vel.x -= sign(probe.vel.x);
                probe.vel.y -= 1;
                if (probe.p.y > current_max_y) {
                    current_max_y = probe.p.y;
                }
                if (probe.p.x <= target_area.right and probe.p.x >= target_area.left and probe.p.y <= target_area.top and probe.p.y >= target_area.bottom) {
                    if (max_y < current_max_y) {
                        max_y = current_max_y;
                    }
                    valid_initial_velocities += 1;
                    break;
                }
            }
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{max_y});
    std.debug.print("Part2: {}\n", .{valid_initial_velocities});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
