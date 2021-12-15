const std = @import("std");

const input = @embedFile("day15.input");

const Position = struct {
    x: usize,
    y: usize,
    risk: u64,
    cost: u64,
};

// Dijkstra
pub fn findPath(grid: [][]Position, candidates: *std.AutoHashMap(*Position, void)) !u64 {
    var current = &grid[0][0];

    while (current.x != grid[0].len - 1 or current.y != grid.len - 1) {
        if (current.x < grid[0].len - 1) {
            var neighbor_right = &grid[current.y][current.x + 1];
            if (neighbor_right.cost == std.math.maxInt(u64)) {
                neighbor_right.cost = current.cost + neighbor_right.risk;
                try candidates.put(neighbor_right, {});
            } else if (candidates.contains(neighbor_right) and neighbor_right.cost > current.cost + neighbor_right.risk) {
                neighbor_right.cost = current.cost + neighbor_right.risk;
            }
        }
        if (current.x > 0) {
            var neighbor_left = &grid[current.y][current.x - 1];
            if (neighbor_left.cost == std.math.maxInt(u64)) {
                neighbor_left.cost = current.cost + neighbor_left.risk;
                try candidates.put(neighbor_left, {});
            } else if (candidates.contains(neighbor_left) and neighbor_left.cost > current.cost + neighbor_left.risk) {
                neighbor_left.cost = current.cost + neighbor_left.risk;
            }
        }
        if (current.y < grid.len - 1) {
            var neighbor_bottom = &grid[current.y + 1][current.x];
            if (neighbor_bottom.cost == std.math.maxInt(u64)) {
                neighbor_bottom.cost = current.cost + neighbor_bottom.risk;
                try candidates.put(neighbor_bottom, {});
            } else if (candidates.contains(neighbor_bottom) and neighbor_bottom.cost > current.cost + neighbor_bottom.risk) {
                neighbor_bottom.cost = current.cost + neighbor_bottom.risk;
            }
        }
        if (current.y > 0) {
            var neighbor_top = &grid[current.y - 1][current.x];
            if (neighbor_top.cost == std.math.maxInt(u64)) {
                neighbor_top.cost = current.cost + neighbor_top.risk;
                try candidates.put(neighbor_top, {});
            } else if (candidates.contains(neighbor_top) and neighbor_top.cost > current.cost + neighbor_top.risk) {
                neighbor_top.cost = current.cost + neighbor_top.risk;
            }
        }

        var key_iter = candidates.keyIterator();
        var next = (key_iter.next() orelse return error.CandidateSelectionError).*;
        while (key_iter.next()) |candidate| {
            if (candidate.*.cost < next.cost) {
                next = candidate.*;
            }
        }
        current = next;
        _ = candidates.remove(current);
    }

    return current.cost;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var grid = std.ArrayList([]Position).init(allocator);
    var grid_p2 = std.ArrayList([]Position).init(allocator);
    var candidates = std.AutoHashMap(*Position, void).init(allocator);

    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        var row = try allocator.alloc(Position, line.len);
        var row_p2 = try allocator.alloc(Position, line.len * 5);
        for (line) |cell, x| {
            const risk = try std.fmt.parseInt(usize, &.{cell}, 10);
            row[x] = .{ .x = x, .y = y, .risk = risk, .cost = std.math.maxInt(u64) };
            row_p2[x] = .{ .x = x, .y = y, .risk = risk, .cost = std.math.maxInt(u64) };
            row_p2[x + line.len] = .{ .x = x + line.len, .y = y, .risk = if (risk < 9) risk + 1 else 1, .cost = std.math.maxInt(u64) };
            row_p2[x + line.len * 2] = .{ .x = x + line.len * 2, .y = y, .risk = if (risk < 8) risk + 2 else ((risk + 2) % 9), .cost = std.math.maxInt(u64) };
            row_p2[x + line.len * 3] = .{ .x = x + line.len * 3, .y = y, .risk = if (risk < 7) risk + 3 else ((risk + 3) % 9), .cost = std.math.maxInt(u64) };
            row_p2[x + line.len * 4] = .{ .x = x + line.len * 4, .y = y, .risk = if (risk < 6) risk + 4 else ((risk + 4) % 9), .cost = std.math.maxInt(u64) };
        }
        try grid.append(row);
        try grid_p2.append(row_p2);
    }
    const single_grid_height = y;
    const total_grid_height = y * 5;
    while (y < total_grid_height) : (y += 1) {
        var row = try allocator.alloc(Position, grid_p2.items[0].len);
        std.mem.copy(Position, row, grid_p2.items[y % single_grid_height]);
        const increase = @divFloor(y, single_grid_height);
        for (row) |*pos| {
            pos.y = y;
            pos.risk = if (pos.risk + increase < 10) pos.risk + increase else (pos.risk + increase) % 9;
        }
        try grid_p2.append(row);
    }

    grid.items[0][0].cost = 0;
    var p1 = try findPath(grid.items, &candidates);
    candidates.clearRetainingCapacity();
    grid_p2.items[0][0].cost = 0;
    var p2 = try findPath(grid_p2.items, &candidates);

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}ms\n", .{time / std.time.ns_per_ms});
}
