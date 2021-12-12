const std = @import("std");

const input = @embedFile("day08.input");

fn sortSliceByLenAsc(comptime T: type) fn (void, []T, []T) bool {
    const impl = struct {
        fn inner(context: void, a: []T, b: []T) bool {
            _ = context;
            return a.len < b.len;
        }
    };

    return impl.inner;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var p_1: u64 = 0;
    var p_2: u64 = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    while (lines.next()) |line| {
        var line_iter = std.mem.split(u8, line, " | ");
        var input_line = std.mem.tokenize(u8, line_iter.next() orelse return error.InputParseError, " ");
        var inputs = [_][]u8{&.{}} ** 10;
        var signal_to_segment = [_]u8{0} ** 7;
        var signal_occurrences = [_]u8{0} ** 7;
        var input_idx: usize = 0;
        while (input_line.next()) |digit| : (input_idx += 1) {
            inputs[input_idx] = try allocator.alloc(u8, digit.len);
            std.mem.copy(u8, inputs[input_idx], digit);
            for (digit) |signal| {
                signal_occurrences[signal - 'a'] += 1;
            }
        }
        std.sort.sort([]u8, &inputs, {}, comptime sortSliceByLenAsc(u8));

        // a: 8x
        // b: 6x
        // c: 8x
        // d: 7x
        // e: 4x
        // f: 9x
        // g: 7x

        // digit.len == 2 => cf/fc => 9x: f => c, f
        const cf = inputs[0];
        if (signal_occurrences[cf[0] - 'a'] == 9) {
            signal_to_segment[cf[0] - 'a'] = 'f';
            signal_to_segment[cf[1] - 'a'] = 'c';
        } else {
            signal_to_segment[cf[0] - 'a'] = 'c';
            signal_to_segment[cf[1] - 'a'] = 'f';
        }

        // digit.len == 3 => acf => a
        for (inputs[1]) |signal| {
            if (signal_to_segment[signal - 'a'] == 0) {
                signal_to_segment[signal - 'a'] = 'a';
                break;
            }
        }

        // 4x: e
        for (signal_occurrences) |count, idx| {
            if (count == 4) {
                signal_to_segment[idx] = 'e';
                break;
            }
        }

        // digit.len == 4 => bdcf/dbcf => 6x: b, 7x: d => b, d
        const bdcf = inputs[2];
        for (bdcf) |signal| {
            if (signal_to_segment[signal - 'a'] == 0) {
                for (signal_occurrences) |count, idx| {
                    if (count == 6 and (signal - 'a') == idx) {
                        signal_to_segment[idx] = 'b';
                    } else if (count == 7 and (signal - 'a') == idx) {
                        signal_to_segment[idx] = 'd';
                    }
                }
            }
        }

        // last => g
        for (signal_to_segment) |segment, idx| {
            if (segment == 0) {
                signal_to_segment[idx] = 'g';
            }
        }

        var output = std.mem.tokenize(u8, line_iter.next() orelse return error.OutputParseError, " ");
        var digit_factor: usize = 1000;
        var num: u64 = 0;
        // last @divFloor will produce 0, but that's after the last iteration so it won't be used
        while (output.next()) |outputDigit| : (digit_factor = @divFloor(digit_factor, 10)) {
            var digit = try allocator.alloc(u8, outputDigit.len);
            std.mem.copy(u8, digit, outputDigit);
            if (digit.len == 2) {
                num += 1 * digit_factor;
                p_1 += 1;
            } else if (digit.len == 3) {
                num += 7 * digit_factor;
                p_1 += 1;
            } else if (digit.len == 4) {
                num += 4 * digit_factor;
                p_1 += 1;
            } else if (digit.len == 7) {
                num += 8 * digit_factor;
                p_1 += 1;
            } else {
                for (digit) |*signal| {
                    signal.* = signal_to_segment[signal.* - 'a'];
                }
                std.sort.sort(u8, digit, {}, comptime std.sort.asc(u8));

                if (std.mem.eql(u8, digit, "acdeg")) {
                    num += 2 * digit_factor;
                } else if (std.mem.eql(u8, digit, "acdfg")) {
                    num += 3 * digit_factor;
                } else if (std.mem.eql(u8, digit, "abdfg")) {
                    num += 5 * digit_factor;
                } else if (std.mem.eql(u8, digit, "abdefg")) {
                    num += 6 * digit_factor;
                } else if (std.mem.eql(u8, digit, "abcdfg")) {
                    num += 9 * digit_factor;
                } // otherwise it's a 0 => ignore
            }
        }
        p_2 += num;
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p_1});
    std.debug.print("Part2: {}\n", .{p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
