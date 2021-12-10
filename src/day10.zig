const std = @import("std");

const input = @embedFile("day10.input");

pub fn pointsForCharP1(char: u8) u64 {
    return switch (char) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => {
            unreachable;
        },
    };
}

pub fn pointsForCharP2(char: u8) u64 {
    return switch (char) {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        else => {
            unreachable;
        },
    };
}

pub fn closingMatch(openingParen: u8) u8 {
    return switch (openingParen) {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stack = std.ArrayList(u8).init(allocator);

    var p_1: u64 = 0;
    var p_2 = std.ArrayList(u64).init(allocator);

    outer: while (lines.next()) |line| {
        stack.clearRetainingCapacity();
        for (line) |char| {
            if (char == '(' or char == '<' or char == '[' or char == '{') {
                try stack.append(char);
            } else {
                if (stack.items.len == 0) {
                    p_1 += pointsForCharP1(char);
                    continue :outer;
                }
                const expected = closingMatch(stack.items[stack.items.len - 1]);
                if (char != expected) {
                    p_1 += pointsForCharP1(char);
                    continue :outer;
                } else {
                    _ = stack.pop();
                }
            }
        }

        var s: u64 = 0;
        while (stack.items.len > 0) {
            s = s * 5 + pointsForCharP2(closingMatch(stack.pop()));
        }
        try p_2.append(s);
    }
    std.sort.sort(u64, p_2.items, {}, comptime std.sort.asc(u64));

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p_1});
    std.debug.print("Part2: {}\n", .{p_2.items[@divFloor(p_2.items.len, 2)]});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
