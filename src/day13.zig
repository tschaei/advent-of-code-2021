const std = @import("std");

const input = @embedFile("day13.input");

const FoldDirection = enum {
    Up,
    Left,
};

const Fold = struct {
    direction: FoldDirection,
    at: usize,
};

const Dot = struct {
    x: usize,
    y: usize,
};

fn foldPaper(dots: *std.AutoHashMap(Dot, void), fold: Fold) !void {
    var dots_clone = try dots.clone();
    var dots_iter = dots_clone.keyIterator();
    switch (fold.direction) {
        .Left => {
            while (dots_iter.next()) |dot| {
                if (dot.x > fold.at) {
                    try dots.put(.{
                        .x = fold.at - (dot.x - fold.at),
                        .y = dot.y,
                    }, {});
                    _ = dots.remove(dot.*);
                }
            }
        },
        .Up => {
            while (dots_iter.next()) |dot| {
                if (dot.y > fold.at) {
                    try dots.put(.{
                        .x = dot.x,
                        .y = fold.at - (dot.y - fold.at),
                    }, {});
                    _ = dots.remove(dot.*);
                }
            }
        },
    }
}

fn printPaper(dots: *std.AutoHashMap(Dot, void)) void {
    var x_max: usize = 0;
    var y_max: usize = 0;
    var iter = dots.iterator();
    while (iter.next()) |entry| {
        if (entry.key_ptr.*.x > x_max) {
            x_max = entry.key_ptr.*.x;
        }

        if (entry.key_ptr.*.y > y_max) {
            y_max = entry.key_ptr.*.y;
        }
    }

    var y: usize = 0;
    while (y <= y_max) : (y += 1) {
        var x: usize = 0;
        while (x <= x_max) : (x += 1) {
            if (dots.contains(.{ .x = x, .y = y })) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var input_blocks = std.mem.split(u8, input, "\n\n");
    const paper_bytes = input_blocks.next().?;
    var paper_lines = std.mem.tokenize(u8, paper_bytes, "\r\n");
    const fold_bytes = input_blocks.next().?;
    var fold_lines = std.mem.tokenize(u8, fold_bytes, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var dots = std.AutoHashMap(Dot, void).init(allocator);
    var folds = std.ArrayList(Fold).init(allocator);

    while (paper_lines.next()) |line| {
        var nums = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(usize, nums.next().?, 10);
        const y = try std.fmt.parseInt(usize, nums.next().?, 10);

        try dots.put(.{
            .x = x,
            .y = y,
        }, {});
    }

    while (fold_lines.next()) |line| {
        var split = std.mem.split(u8, line, "=");
        const direction = split.next().?;
        const at = try std.fmt.parseInt(usize, split.next().?, 10);

        try folds.append(.{
            .direction = if (direction[direction.len - 1] == 'y') .Up else .Left,
            .at = at,
        });
    }

    try foldPaper(&dots, folds.items[0]);
    var p1 = dots.count();

    for (folds.items[1..folds.items.len]) |fold| {
        try foldPaper(&dots, fold);
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    printPaper(&dots);
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
