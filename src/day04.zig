const std = @import("std");

const input = @embedFile("day04.input");

const Board = struct {
    marked: [5][5]bool,
    values: [5][5]u64,

    pub fn init(values: [5][5]u64) Board {
        return .{
            .marked = [_][5]bool{[_]bool{false} ** 5} ** 5,
            .values = values,
        };
    }

    pub fn hasWon(self: Board) bool {
        for (self.values) |row, rowIdx| {
            // check row itself
            var row_marked = true;
            for (row) |_, col_idx| {
                if (!self.marked[rowIdx][col_idx]) {
                    row_marked = false;
                    break;
                }
            }
            if (row_marked) {
                return true;
            }
            // check "rowIdx"th column
            var column_marked = true;
            for (self.values) |_, innerRowIdx| {
                if (!self.marked[innerRowIdx][rowIdx]) {
                    column_marked = false;
                    break;
                }
            }
            if (column_marked) {
                return true;
            }
        }

        return false;
    }

    pub fn markNumberIfPresent(self: *Board, number: u64) void {
        for (self.values) |row, rowIdx| {
            for (row) |boardNum, colIdx| {
                if (number == boardNum) {
                    self.marked[rowIdx][colIdx] = true;
                }
            }
        }
    }

    pub fn result(self: Board, finalDraw: u64) u64 {
        var sum: u64 = 0;
        for (self.values) |row, rowIdx| {
            for (row) |num, colIdx| {
                if (!self.marked[rowIdx][colIdx]) {
                    sum += num;
                }
            }
        }
        return sum * finalDraw;
    }
};

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var p_1: ?u64 = null;
    var p_2: ?u64 = null;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();
    var lines = std.mem.split(u8, input, "\n");
    var draws = std.mem.tokenize(u8, lines.next() orelse return, ",");
    var boards = try parseBoards(allocator, &lines);
    var next_boards = try std.ArrayList(Board).initCapacity(allocator, boards.items.len);

    while (draws.next()) |draw| {
        for (boards.items) |*board| {
            const drawn = try std.fmt.parseInt(usize, draw, 10);
            board.markNumberIfPresent(drawn);
            if (board.hasWon()) {
                var result = board.result(drawn);
                if (p_1 == null) {
                    p_1 = result;
                }
                p_2 = result;
            } else {
                try next_boards.append(board.*);
            }
        }
        std.mem.swap(std.ArrayList(Board), &boards, &next_boards);
        next_boards.clearRetainingCapacity();
    }

    const end = timer.read();
    std.debug.print("Part1: {}\n", .{p_1});
    std.debug.print("Part2: {}\n", .{p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{end / std.time.ns_per_us});
}

fn parseBoards(allocator: std.mem.Allocator, lines: *std.mem.SplitIterator(u8)) !std.ArrayList(Board) {
    var board = Board.init([_][5]u64{[_]u64{0} ** 5} ** 5);
    var line_idx: usize = 0;
    var boards = std.ArrayList(Board).init(allocator);
    _ = lines.next();
    while (lines.next()) |line| {
        if (line.len > 0) {
            var numIter = std.mem.tokenize(u8, line, " \r\n");
            var idx: usize = 0;
            while (numIter.next()) |num| {
                board.values[line_idx][idx] = try std.fmt.parseInt(u64, num, 10);
                idx += 1;
            }
            line_idx += 1;
        } else {
            try boards.append(board);
            board = Board.init([_][5]u64{[_]u64{0} ** 5} ** 5);
            line_idx = 0;
        }
    }
    try boards.append(board);
    return boards;
}
