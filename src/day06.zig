const std = @import("std");

const input = @embedFile("day06.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var fish_initial = std.mem.split(u8, input, ",");
    var fish_on_day = [_]u64{0} ** 9;
    while (fish_initial.next()) |fish| {
        fish_on_day[try std.fmt.parseInt(u8, fish, 10)] += 1;
    }

    var p_1: u64 = 0;
    var p_2: u64 = 0;
    var day: u64 = 1;
    while (day <= 256) : (day += 1) {
        const newFish = fish_on_day[0];
        fish_on_day[0] = fish_on_day[1];
        fish_on_day[1] = fish_on_day[2];
        fish_on_day[2] = fish_on_day[3];
        fish_on_day[3] = fish_on_day[4];
        fish_on_day[4] = fish_on_day[5];
        fish_on_day[5] = fish_on_day[6];
        fish_on_day[6] = fish_on_day[7] + newFish;
        fish_on_day[7] = fish_on_day[8];
        fish_on_day[8] = newFish;

        if (day == 80) {
            for (fish_on_day) |fish| {
                p_1 += fish;
            }
        }
    }

    for (fish_on_day) |fish| {
        p_2 += fish;
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p_1});
    std.debug.print("Part2: {}\n", .{p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
