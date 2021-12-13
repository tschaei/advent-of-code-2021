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

fn foldPaper(paper: *std.ArrayList(*std.ArrayList(bool)), fold: Fold) !void {
    switch (fold.direction) {
        .Left => {
            for (paper.items) |*row| {
                for (row.*.items[fold.at..row.*.items.len]) |dot, idx| {
                    row.*.items[fold.at - idx] = row.*.items[fold.at - idx] or dot;
                }
                try row.*.resize(fold.at);
            }
        },
        .Up => {
            for (paper.items[fold.at..paper.items.len]) |*row, row_idx| {
                for (row.*.items) |dot, col_idx| {
                    paper.items[fold.at - row_idx].items[col_idx] = paper.items[fold.at - row_idx].items[col_idx] or dot;
                }
            }
            try paper.resize(fold.at);
        },
    }
}

fn printPaper(paper: *std.ArrayList(*std.ArrayList(bool))) void {
    for (paper.items) |*row| {
        for (row.*.items) |dot| {
            if (dot) {
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
    const paper_bytes = input_blocks.next() orelse return;
    var paper_lines = std.mem.tokenize(u8, paper_bytes, "\r\n");
    const fold_bytes = input_blocks.next() orelse return;
    var fold_lines = std.mem.tokenize(u8, fold_bytes, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var paper = std.ArrayList(*std.ArrayList(bool)).init(allocator);
    var folds = std.ArrayList(Fold).init(allocator);

    var x_max: usize = 0;

    while (paper_lines.next()) |line| {
        var nums = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(usize, nums.next() orelse return, 10);
        const y = try std.fmt.parseInt(usize, nums.next() orelse return, 10);

        if (x > x_max) {
            x_max = x;
        }

        if (y >= paper.items.len) {
            var idx = paper.items.len;
            while (idx <= y) : (idx += 1) {
                var list = try allocator.create(std.ArrayList(bool));
                list.* = std.ArrayList(bool).init(allocator);
                try paper.append(list);
            }
        }

        for (paper.items) |*row| {
            while (row.*.items.len < x_max + 1) {
                try row.*.append(false);
            }
        }

        paper.items[y].items[x] = true;
    }

    while (fold_lines.next()) |line| {
        var split = std.mem.split(u8, line, "=");
        const direction = split.next() orelse return;
        const at = try std.fmt.parseInt(usize, split.next() orelse return, 10);

        try folds.append(.{
            .direction = if (direction[direction.len - 1] == 'y') .Up else .Left,
            .at = at,
        });
    }

    try foldPaper(&paper, folds.items[0]);
    var p1: u64 = 0;

    for (paper.items) |*row| {
        for (row.*.items) |dot| {
            if (dot) {
                p1 += 1;
            }
        }
    }

    for (folds.items[1..folds.items.len]) |fold| {
        try foldPaper(&paper, fold);
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    printPaper(&paper);
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
