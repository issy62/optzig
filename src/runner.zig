const std = @import("std");
const opt = @import("optzig");
const builtin = @import("builtin");
const compressor = std.compress.zlib;

const BUILD_MODE = builtin.mode;

pub fn main() !void {
    const io = std.io.getStdErr().writer();

    var dba: if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}) else void =
        if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}).init else {};

    var arena = std.heap.ArenaAllocator.init(switch (BUILD_MODE) {
        .ReleaseFast, .ReleaseSmall, .ReleaseSafe => std.heap.smp_allocator,
        .Debug => dba.allocator(),
    });

    defer arena.deinit();

    var ag = opt.Args.init(arena.allocator());

    const verb = try ag.boolean("verbose", "verbosity level", false);
    const port = try ag.float32("port", "binding port", 0.0);
    const to = try ag.string("to", "outbound phone number", "");
    const help = try ag.boolean("help", "Print this usage", false);

    var arg_iputs = try std.process.argsWithAllocator(arena.allocator());

    try ag.parse(std.process.ArgIterator, &arg_iputs);

    if (help.*) {
        try ag.usage(null);
    }

    try io.print("Port Number: {d}\n", .{port.*});
    try io.print("To Number: {s}\n", .{to.*});
    try io.print("Vebose: {}\n", .{verb.*});
}

