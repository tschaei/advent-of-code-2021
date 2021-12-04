const std = @import("std");

const input = @embedFile("day04.input");

const Board = struct {
    markedFields: [5][5]bool,
    fields: [5][5]usize,

    pub fn init(fields: [5][5]usize) Board {
        return .{
            .markedFields = [_][5]bool{[_]bool{false} ** 5} ** 5,
            .fields = fields,
        };
    }

    pub fn hasWon(self: Board) bool {
        for (self.fields) |row, rowIdx| {
            // check row itself
            var allRowFieldsMarked = true;
            for (row) |_, colIdx| {
                if (!self.markedFields[rowIdx][colIdx]) {
                    allRowFieldsMarked = false;
                    break;
                }
            }
            if (allRowFieldsMarked) {
                return true;
            }
            // check "rowIdx"th column
            var allColumnFieldsMarked = true;
            for (self.fields) |_, innerRowIdx| {
                if (!self.markedFields[innerRowIdx][rowIdx]) {
                    allColumnFieldsMarked = false;
                    break;
                }
            }
            if (allColumnFieldsMarked) {
                return true;
            }
        }

        return false;
    }

    pub fn markNumberIfPresent(self: *Board, number: usize) void {
        for (self.fields) |row, rowIdx| {
            for (row) |boardNum, colIdx| {
                if (number == boardNum) {
                    self.markedFields[rowIdx][colIdx] = true;
                }
            }
        }
    }

    pub fn result(self: Board, finalDraw: usize) usize {
        var sum: usize = 0;
        for (self.fields) |row, rowIdx| {
            for (row) |num, colIdx| {
                if (!self.markedFields[rowIdx][colIdx]) {
                    sum += num;
                }
            }
        }
        return sum * finalDraw;
    }
};

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var p1: ?usize = null;
    var p2: ?usize = null;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var lines = std.mem.split(u8, input, "\n");
    var draws = std.mem.tokenize(u8, lines.next() orelse return, ",");
    var boards = try parseBoards(&gpa.allocator, &lines);
    defer boards.deinit();
    var boardsForNextDraw = try std.ArrayList(Board).initCapacity(&gpa.allocator, boards.items.len);
    defer boardsForNextDraw.deinit();

    while (draws.next()) |draw| {
        for (boards.items) |*board| {
            const drawnNumber = try std.fmt.parseInt(usize, draw, 10);
            board.markNumberIfPresent(drawnNumber);
            if (board.hasWon()) {
                var result = board.result(drawnNumber);
                if (p1 == null) {
                    p1 = result;
                }
                p2 = result;
            } else {
                try boardsForNextDraw.append(board.*);
            }
        }
        std.mem.swap(std.ArrayList(Board), &boards, &boardsForNextDraw);
        boardsForNextDraw.clearRetainingCapacity();
    }

    const end = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{end / std.time.ns_per_us});
}

fn parseBoards(allocator: *std.mem.Allocator, lines: *std.mem.SplitIterator(u8)) !std.ArrayList(Board) {
    var currentBoard = Board.init([_][5]usize{[_]usize{0} ** 5} ** 5);
    var currentLine: usize = 0;
    var boards = std.ArrayList(Board).init(allocator);
    _ = lines.next();
    while (lines.next()) |line| {
        if (line.len > 0) {
            var numIter = std.mem.tokenize(u8, line, " \r\n");
            var idx: usize = 0;
            while (numIter.next()) |num| {
                currentBoard.fields[currentLine][idx] = try std.fmt.parseInt(usize, num, 10);
                idx += 1;
            }
            currentLine += 1;
        } else {
            try boards.append(currentBoard);
            currentBoard = Board.init([_][5]usize{[_]usize{0} ** 5} ** 5);
            currentLine = 0;
        }
    }
    try boards.append(currentBoard);
    return boards;
}
