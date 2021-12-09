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
    var p1: usize = 0;
    var p2: usize = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    while (lines.next()) |line| {
        var lineIter = std.mem.split(u8, line, " | ");
        var lineInput = std.mem.tokenize(u8, lineIter.next() orelse return error.InputParseError, " ");
        var inputs: [10][]u8 = .{ &.{}, &.{}, &.{}, &.{}, &.{}, &.{}, &.{}, &.{}, &.{}, &.{} };
        var signalToSegment = [_]u8{0} ** 7;
        var signalOccurences = [_]u8{0} ** 7;
        var inputIdx: usize = 0;
        while (lineInput.next()) |digit| : (inputIdx += 1) {
            inputs[inputIdx] = try allocator.alloc(u8, digit.len);
            std.mem.copy(u8, inputs[inputIdx], digit);
            for (digit) |signal| {
                signalOccurences[signal - 'a'] += 1;
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
        if (signalOccurences[cf[0] - 'a'] == 9) {
            signalToSegment[cf[0] - 'a'] = 'f';
            signalToSegment[cf[1] - 'a'] = 'c';
        } else {
            signalToSegment[cf[0] - 'a'] = 'c';
            signalToSegment[cf[1] - 'a'] = 'f';
        }

        // digit.len == 3 => acf => a
        for (inputs[1]) |signal| {
            if (signalToSegment[signal - 'a'] == 0) {
                signalToSegment[signal - 'a'] = 'a';
                break;
            }
        }

        // 4x: e
        for (signalOccurences) |count, idx| {
            if (count == 4) {
                signalToSegment[idx] = 'e';
                break;
            }
        }

        // digit.len == 4 => bdcf/dbcf => 6x: b, 7x: d => b, d
        const bdcf = inputs[2];
        for (bdcf) |signal| {
            if (signalToSegment[signal - 'a'] == 0) {
                for (signalOccurences) |count, idx| {
                    if (count == 6 and (signal - 'a') == idx) {
                        signalToSegment[idx] = 'b';
                    } else if (count == 7 and (signal - 'a') == idx) {
                        signalToSegment[idx] = 'd';
                    }
                }
            }
        }

        // last => g
        for (signalToSegment) |segment, idx| {
            if (segment == 0) {
                signalToSegment[idx] = 'g';
            }
        }

        var output = std.mem.tokenize(u8, lineIter.next() orelse return error.OutputParseError, " ");
        var decimalPlace: usize = 3;
        var num: usize = 0;
        while (output.next()) |outputDigit| : (decimalPlace -= 1) {
            var digit = try allocator.alloc(u8, outputDigit.len);
            std.mem.copy(u8, digit, outputDigit);
            if (digit.len == 2) {
                num += 1 * std.math.pow(usize, 10, decimalPlace);
                p1 += 1;
            } else if (digit.len == 3) {
                num += 7 * std.math.pow(usize, 10, decimalPlace);
                p1 += 1;
            } else if (digit.len == 4) {
                num += 4 * std.math.pow(usize, 10, decimalPlace);
                p1 += 1;
            } else if (digit.len == 7) {
                num += 8 * std.math.pow(usize, 10, decimalPlace);
                p1 += 1;
            } else {
                for (digit) |*signal| {
                    signal.* = signalToSegment[signal.* - 'a'];
                }
                std.sort.sort(u8, digit, {}, comptime std.sort.asc(u8));

                if (std.mem.eql(u8, digit, "acdeg")) {
                    num += 2 * std.math.pow(usize, 10, decimalPlace);
                } else if (std.mem.eql(u8, digit, "acdfg")) {
                    num += 3 * std.math.pow(usize, 10, decimalPlace);
                } else if (std.mem.eql(u8, digit, "abdfg")) {
                    num += 5 * std.math.pow(usize, 10, decimalPlace);
                } else if (std.mem.eql(u8, digit, "abdefg")) {
                    num += 6 * std.math.pow(usize, 10, decimalPlace);
                } else if (std.mem.eql(u8, digit, "abcdfg")) {
                    num += 9 * std.math.pow(usize, 10, decimalPlace);
                } // otherwise it's a 0 => ignore
            }
        }
        p2 += num;
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
