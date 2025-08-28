const std = @import("std");
const opt = @import("optzig");

pub fn main() !void {
    var out_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&out_buffer);
    var stdout = &stdout_writer.interface;

    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();

    var arg_iputs = try std.process.argsWithAllocator(arena.allocator());

    var ag = opt.Args.init(arena.allocator());
    const verb = try ag.boolean("verbose", "verbosity level", false, false);
    const port = try ag.int32("port", "binding port", false, 0);
    const to = try ag.string("to", "outbound phone number", true, "");
    const help = try ag.boolean("help", "Print this usage", false, false);

    ag.parse(std.process.ArgIterator, &arg_iputs) catch |err| {
        switch (err) {
            opt.ArgParserError.RequiredArgument => try ag.usage(null),
            else => return err,
        }
    };

    if (help.*) {
        try ag.usage(null);
    }

    try stdout.print("Port Number: {d}\n", .{port.*});
    try stdout.print("To Number: {s}\n", .{to.*});
    try stdout.print("Vebose: {}\n", .{verb.*});
    try stdout.flush();
}

