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

    try ag.put("verbose", "verbosity level", opt.ArgTypes{ .Boolean = false });
    try ag.put("port", "binding port", opt.ArgTypes{ .Float32 = 0.0 });
    try ag.put("to", "outbound phone number", opt.ArgTypes{ .String = "" });
    try ag.put("help", "Print this usage", opt.ArgTypes{ .Boolean = false });

    var arg_iputs = try std.process.argsWithAllocator(arena.allocator());

    try ag.parse(std.process.ArgIterator, &arg_iputs);

    if (ag.items.get("help").?.value.Boolean) {
        try ag.usage(null);
    }

    const port_n = ag.items.get("port").?.value.Float32;
    const to_n = ag.items.get("to").?.value.String;
    const verb = ag.items.get("verbose").?.value.Boolean;

    try io.print("Port Number: {d}\n", .{port_n});
    try io.print("To Number: {s}\n", .{to_n});
    try io.print("Vebose: {}\n", .{verb});
}

