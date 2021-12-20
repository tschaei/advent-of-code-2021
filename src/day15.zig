const std = @import("std");

const input = @embedFile("day15.input");

const Position = struct {
    x: i64,
    y: i64,
    risk: u64,
    cost: u64,
};

fn lessThan(a: *Position, b: *Position) std.math.Order {
    if (a.cost < b.cost) {
        return std.math.Order.lt;
    } else if (a.cost > b.cost) {
        return std.math.Order.gt;
    } else {
        return std.math.Order.eq;
    }
}

const Vec2 = struct {
    x: i64,
    y: i64,
};

const PriorityQueue = std.PriorityQueue(*Position, lessThan);

// Dijkstra
pub fn findPath(grid: *std.AutoHashMap([2]i64, Position), candidates: *PriorityQueue, target: [2]i64) !u64 {
    var current: *Position = undefined;
    const offsets = [_][2]i64{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 } };
    while (candidates.removeOrNull()) |next| {
        if (current.x == target[0] and current.y == target[1]) {
            return current.cost;
        }
        current = next;
        for (offsets) |offset| {
            if (grid.getPtr(.{ current.x + offset[0], current.y + offset[1] })) |neighbor| {
                if (neighbor.cost > current.cost + neighbor.risk) {
                    neighbor.cost = current.cost + neighbor.risk;
                    try candidates.add(neighbor);
                }
            }
        }
        // if (current.x < grid[0].len - 1) {
        //     var neighbor_right = &grid[current.y][current.x + 1];
        //     if (neighbor_right.cost == std.math.maxInt(u64)) {
        //         neighbor_right.cost = current.cost + neighbor_right.risk;
        //         try candidates.add(neighbor_right);
        //     } else if (neighbor_right.cost > current.cost + neighbor_right.risk) {
        //         neighbor_right.cost = current.cost + neighbor_right.risk;
        //     }
        // }
        // if (current.x > 0) {
        //     var neighbor_left = &grid[current.y][current.x - 1];
        //     if (neighbor_left.cost == std.math.maxInt(u64)) {
        //         neighbor_left.cost = current.cost + neighbor_left.risk;
        //         try candidates.add(neighbor_left);
        //     } else if (neighbor_left.cost > current.cost + neighbor_left.risk) {
        //         neighbor_left.cost = current.cost + neighbor_left.risk;
        //     }
        // }
        // if (current.y < grid.len - 1) {
        //     var neighbor_bottom = &grid[current.y + 1][current.x];
        //     if (neighbor_bottom.cost == std.math.maxInt(u64)) {
        //         neighbor_bottom.cost = current.cost + neighbor_bottom.risk;
        //         try candidates.add(neighbor_bottom);
        //     } else if (neighbor_bottom.cost > current.cost + neighbor_bottom.risk) {
        //         neighbor_bottom.cost = current.cost + neighbor_bottom.risk;
        //     }
        // }
        // if (current.y > 0) {
        //     var neighbor_top = &grid[current.y - 1][current.x];
        //     if (neighbor_top.cost == std.math.maxInt(u64)) {
        //         neighbor_top.cost = current.cost + neighbor_top.risk;
        //         try candidates.add(neighbor_top);
        //     } else if (neighbor_top.cost > current.cost + neighbor_top.risk) {
        //         neighbor_top.cost = current.cost + neighbor_top.risk;
        //     }
        // }

        // current = candidates.remove();
    }

    return current.cost;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // var grid = std.ArrayList([]Position).init(allocator);
    var grid = std.AutoHashMap([2]i64, Position).init(allocator);
    var grid_big = std.AutoHashMap([2]i64, Position).init(allocator);
    // var grid_p2 = std.ArrayList([]Position).init(allocator);
    var candidates = PriorityQueue.init(allocator);

    var y: i64 = 0;
    while (lines.next()) |line| : (y += 1) {
        // var row = try allocator.alloc(Position, line.len);
        // var row_p2 = try allocator.alloc(Position, line.len * 5);
        for (line) |cell, idx| {
            const x = @intCast(i64, idx);
            const risk = try std.fmt.parseInt(usize, &.{cell}, 10);
            try grid.put(.{ x, y }, .{ .x = x, .y = y, .risk = risk, .cost = std.math.maxInt(u64) });
            var x_extra: i64 = 0;
            while (x_extra < 5) : (x_extra += 1) {
                var y_extra: i64 = 0;
                while (y_extra < 5) : (y_extra += 1) {
                    try grid_big.put(.{ x + x_extra * (x + 1), y + y_extra * (y + 1) }, .{ .x = x + x_extra * (x + 1), .y = y + y_extra * (y + 1), .cost = std.math.maxInt(u64), .risk = (risk + @intCast(u64, x_extra + y_extra) - 1) % 9 + 1 });
                }
            }
            // row[x] = .{ .x = x, .y = y, .risk = risk, .cost = std.math.maxInt(u64) };
            // row_p2[x] = .{ .x = x, .y = y, .risk = risk, .cost = std.math.maxInt(u64) };
            // row_p2[x + line.len] = .{ .x = x + line.len, .y = y, .risk = if (risk < 9) risk + 1 else 1, .cost = std.math.maxInt(u64) };
            // row_p2[x + line.len * 2] = .{ .x = x + line.len * 2, .y = y, .risk = if (risk < 8) risk + 2 else ((risk + 2) % 9), .cost = std.math.maxInt(u64) };
            // row_p2[x + line.len * 3] = .{ .x = x + line.len * 3, .y = y, .risk = if (risk < 7) risk + 3 else ((risk + 3) % 9), .cost = std.math.maxInt(u64) };
            // row_p2[x + line.len * 4] = .{ .x = x + line.len * 4, .y = y, .risk = if (risk < 6) risk + 4 else ((risk + 4) % 9), .cost = std.math.maxInt(u64) };
        }
        // try grid.append(row);
        // try grid_p2.append(row_p2);
    }
    // const single_grid_height = y;
    // const total_grid_height = y * 5;
    // while (y < total_grid_height) : (y += 1) {
    //     var row = try allocator.alloc(Position, grid_p2.items[0].len);
    //     std.mem.copy(Position, row, grid_p2.items[y % single_grid_height]);
    //     const increase = @divFloor(y, single_grid_height);
    //     for (row) |*pos| {
    //         pos.y = y;
    //         pos.risk = if (pos.risk + increase < 10) pos.risk + increase else (pos.risk + increase) % 9;
    //     }
    //     try grid_p2.append(row);
    // }

    std.debug.print("Runtime for parsing: {}us\n", .{timer.read() / std.time.ns_per_us});

    // grid.items[0][0].cost = 0;
    try candidates.add(grid.getPtr(.{ 0, 0 }).?);
    var p1 = try findPath(&grid, &candidates, .{ 4, 4 });
    candidates.shrinkAndFree(0);
    // grid_p2.items[0][0].cost = 0;
    // try candidates.add(&grid_p2.items[0][0]);
    try candidates.add(grid.getPtr(.{ 0, 0 }).?);
    var p2 = try findPath(&grid_big, &candidates, .{ 24, 24 });

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
