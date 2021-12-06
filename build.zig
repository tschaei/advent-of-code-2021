const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    makeBuildForDay(b, target, mode, "01");
    makeBuildForDay(b, target, mode, "02");
    makeBuildForDay(b, target, mode, "03");
    makeBuildForDay(b, target, mode, "04");
    makeBuildForDay(b, target, mode, "05");
    makeBuildForDay(b, target, mode, "06");
}

pub fn makeBuildForDay(b: *std.build.Builder, target: std.build.Target, mode: std.builtin.Mode, day: []const u8) void {
    var step_name = [_]u8{undefined} ** 5;
    _ = std.fmt.bufPrint(&step_name, "day{s}", .{day}) catch unreachable;
    var step_src = [_]u8{undefined} ** 13;
    _ = std.fmt.bufPrint(&step_src, "src/{s}.zig", .{step_name}) catch unreachable;
    const step = b.addExecutable(&step_name, &step_src);
    step.setTarget(target);
    step.setBuildMode(mode);
    step.install();
    const run_cmd = step.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    var run_step_name = [_]u8{undefined} ** 9;
    _ = std.fmt.bufPrint(&run_step_name, "run_day{s}", .{day}) catch unreachable;
    var run_desc = [_]u8{undefined} ** 9;
    _ = std.fmt.bufPrint(&run_desc, "Run {s}", .{step_name}) catch unreachable;
    const run_step = b.step(&run_step_name, &run_desc);
    run_step.dependOn(&run_cmd.step);
}
