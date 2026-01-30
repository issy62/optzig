const std = @import("std");
const opt = @import("optzig");

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var out_buffer: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &out_buffer);
    var stdout = &stdout_writer.interface;

    var arg_iputs = try std.process.Args.Iterator.initAllocator(init.minimal.args, allocator);

    var ag = opt.Args.init(allocator);
    const verb = try ag.boolean("verbose", "verbosity level", false, false);
    const port = try ag.int32("port", "binding port", false, 0);
    const to = try ag.string("to", "outbound phone number", true, "");
    const help = try ag.boolean("help", "Print this usage", false, false);

    ag.parse(std.process.Args.Iterator, &arg_iputs) catch |err| {
        switch (err) {
            opt.ArgParserError.RequiredArgument => try ag.usageWithExit(init.io, 0),
            else => return err,
        }
    };

    if (help.*) {
        try ag.usageWithExit(init.io, 0);
    }

    try stdout.print("Port Number: {d}\n", .{port.*});
    try stdout.print("To Number: {s}\n", .{to.*});
    try stdout.print("Verbose: {}\n", .{verb.*});
    try stdout.flush();
}
