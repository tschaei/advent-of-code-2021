const std = @import("std");

const input = @embedFile("day18.input");

const ElementTag = enum {
    number,
    pair,
};

const Element = union(ElementTag) {
    number: *Number,
    pair: *Pair,

    pub fn setLeft(self: *Element, child: *Element) !void {
        if (self.* == .pair) {
            self.pair.left = child;
            switch (self.pair.left.*) {
                .number => self.pair.left.number.parent = self,
                .pair => self.pair.left.pair.parent = self,
            }
        } else unreachable;
    }

    pub fn setRight(self: *Element, child: *Element) !void {
        if (self.* == .pair) {
            self.pair.right = child;
            switch (self.pair.right.*) {
                .number => self.pair.right.number.parent = self,
                .pair => self.pair.right.pair.parent = self,
            }
        } else unreachable;
    }
};

const Number = struct {
    v: u8,
    parent: *Element,
};

const Pair = struct {
    left: *Element,
    right: *Element,
    parent: ?*Element,

    pub fn init(parent: ?*Element) Pair {
        return .{
            .left = undefined,
            .right = undefined,
            .parent = parent,
        };
    }
};

const ParseNumberResult = struct {
    e: *Element,
    remaining_input: []const u8,
};

fn parseNumber(allocator: std.mem.Allocator, buf: []const u8, parent: ?*Element) anyerror!ParseNumberResult {
    var result: ParseNumberResult = .{ .e = undefined, .remaining_input = undefined };
    if (buf[0] == '[') {
        result.e = try allocator.create(Element);
        var pair = try allocator.create(Pair);
        pair.* = Pair.init(parent);
        result.e.* = .{ .pair = pair };
        const left_result = try parseNumber(allocator, buf[1..], result.e);
        try result.e.setLeft(left_result.e);
        result.remaining_input = left_result.remaining_input;
        const right_result = try parseNumber(allocator, result.remaining_input, result.e);
        try result.e.setRight(right_result.e);
        if (right_result.remaining_input.len > 1) {
            result.remaining_input = right_result.remaining_input[1..];
        }
    } else if (buf[0] != ']') {
        var number = try allocator.create(Number);
        number.* = .{ .v = try std.fmt.parseInt(u8, &.{buf[0]}, 10), .parent = parent.? };
        result.e = try allocator.create(Element);
        result.e.* = .{ .number = number };
        result.remaining_input = buf[2..];
    }
    return result;
}

// used for debugging
fn printElement(element: *Element) void {
    switch (element.*) {
        .number => std.debug.print("{}", .{element.number.v}),
        .pair => printPair(element.pair),
    }
    std.debug.print("\n", .{});
}

// used for debugging
fn printPair(number: *Pair) void {
    std.debug.print("[", .{});
    switch (number.left.*) {
        .number => std.debug.print("{}", .{number.left.number.v}),
        .pair => printPair(number.left.pair),
    }
    std.debug.print(",", .{});
    switch (number.right.*) {
        .number => std.debug.print("{}", .{number.right.number.v}),
        .pair => printPair(number.right.pair),
    }
    std.debug.print("]", .{});
}

fn findFirstNumberLeft(e: *Element) ?*Element {
    var parent = switch (e.*) {
        .number => e.number.parent,
        .pair => if (e.pair.parent) |parent| parent else {
            return null;
        },
    };

    if (parent.pair.right == e) {
        var number: *Element = parent.pair.left;
        while (number.* != .number) {
            number = number.pair.right;
        }
        return number;
    } else {
        return findFirstNumberLeft(parent);
    }
}

fn findFirstNumberRight(e: *Element) ?*Element {
    var parent = switch (e.*) {
        .number => e.number.parent,
        .pair => if (e.pair.parent) |parent| parent else {
            return null;
        },
    };

    if (parent.pair.left == e) {
        var number: *Element = parent.pair.right;
        while (number.* != .number) {
            number = number.pair.left;
        }
        return number;
    } else {
        return findFirstNumberRight(parent);
    }
}

fn findExploding(e: *Element, depth: usize) ?*Element {
    if (depth > 4) {
        return null;
    }
    switch (e.*) {
        .number => return null,
        .pair => if (depth == 4) {
            return e;
        } else {
            if (findExploding(e.pair.left, depth + 1)) |exploding| {
                return exploding;
            } else if (findExploding(e.pair.right, depth + 1)) |exploding| {
                return exploding;
            } else {
                return null;
            }
        },
    }
}

fn findSplittableNumber(e: *Element) ?*Element {
    switch (e.*) {
        .number => if (e.number.v >= 10) return e,
        .pair => {
            if (findSplittableNumber(e.pair.left)) |n| {
                return n;
            }
            if (findSplittableNumber(e.pair.right)) |n| {
                return n;
            }
        },
    }

    return null;
}

// used to find issues with parent <-> child pointers
fn assertCorrectParents(e: *Element) void {
    switch (e.*) {
        .number => return,
        .pair => {
            switch (e.pair.left.*) {
                .number => std.debug.assert(e.pair.left.number.parent == e),
                .pair => {
                    std.debug.assert(e.pair.left.pair.parent.? == e);
                    assertCorrectParents(e.pair.left);
                },
            }
            switch (e.pair.right.*) {
                .number => std.debug.assert(e.pair.right.number.parent == e),
                .pair => {
                    std.debug.assert(e.pair.right.pair.parent.? == e);
                    assertCorrectParents(e.pair.right);
                },
            }
        },
    }
}

fn addPairs(allocator: std.mem.Allocator, p_1: *Element, p_2: *Element) !*Element {
    var result = try allocator.create(Element);
    var pair = try allocator.create(Pair);
    pair.* = Pair.init(null);
    result.* = .{ .pair = pair };
    try result.setLeft(p_1);
    try result.setRight(p_2);

    var performed_action = true;
    while (performed_action) {
        performed_action = false;
        if (findExploding(result, 0)) |e| {
            performed_action = true;
            if (findFirstNumberLeft(e)) |n| {
                n.number.v += e.pair.left.number.v;
            }
            if (findFirstNumberRight(e)) |n| {
                n.number.v += e.pair.right.number.v;
            }

            var number = try allocator.create(Number);
            number.v = 0;
            number.parent = e.pair.parent.?;
            e.* = .{ .number = number };

            continue;
        }

        if (findSplittableNumber(result)) |n| {
            performed_action = true;
            const v = n.number.v;
            pair = try allocator.create(Pair);
            pair.* = Pair.init(n.number.parent);
            n.* = .{ .pair = pair };
            var left_element = try allocator.create(Element);
            var left = try allocator.create(Number);
            left_element.* = .{ .number = left };
            left.* = .{ .parent = n, .v = try std.math.divFloor(u8, v, 2) };
            try n.setLeft(left_element);
            var right_element = try allocator.create(Element);
            var right = try allocator.create(Number);
            right_element.* = .{ .number = right };
            right.* = .{ .parent = n, .v = try std.math.divCeil(u8, v, 2) };
            try n.setRight(right_element);
        }
    }

    return result;
}

fn magnitude(e: *Element) u64 {
    return switch (e.*) {
        .number => e.number.v,
        .pair => 3 * magnitude(e.pair.left) + 2 * magnitude(e.pair.right),
    };
}

fn cloneElement(allocator: std.mem.Allocator, e: *Element, parent: ?*Element) anyerror!*Element {
    var result = try allocator.create(Element);
    switch (e.*) {
        .number => {
            var number = try allocator.create(Number);
            number.parent = parent.?;
            number.v = e.number.v;
            result.* = .{ .number = number };
        },
        .pair => {
            var pair = try allocator.create(Pair);
            pair.* = .{ .parent = parent, .left = try cloneElement(allocator, e.pair.left, result), .right = try cloneElement(allocator, e.pair.right, result) };
            result.* = .{ .pair = pair };
        },
    }

    return result;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    // Without ArenaAllocator, all parsed snailfish numbers leak all their memory
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var current: ?*Element = null;
    var numbers = std.ArrayList(*Element).init(allocator);
    while (lines.next()) |line| {
        var parsed = try parseNumber(allocator, line, null);
        try numbers.append(try cloneElement(allocator, parsed.e, null));
        if (current) |*c| {
            c.* = try addPairs(allocator, c.*, parsed.e);
        } else {
            current = parsed.e;
        }
    }

    var p2: u64 = 0;
    for (numbers.items) |n_1| {
        for (numbers.items) |n_2| {
            if (n_1 == n_2) continue;
            var mag = magnitude(try addPairs(allocator, try cloneElement(allocator, n_1, null), try cloneElement(allocator, n_2, null)));
            if (mag > p2) {
                p2 = mag;
            }
            mag = magnitude(try addPairs(allocator, try cloneElement(allocator, n_2, null), try cloneElement(allocator, n_1, null)));
            if (mag > p2) {
                p2 = mag;
            }
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{magnitude(current.?)});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}ms\n", .{time / std.time.ns_per_ms});
}
