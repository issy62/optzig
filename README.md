# optzig

`optzig` is a command-line argument parsing library for the Zig programming language, inspired by the approach used in Go. It provides a structured way to define and parse command-line arguments, supporting various data types such as booleans, integers, floats, and strings.

## Features

- Define arguments with names, descriptions, and types
- Parse command-line arguments and automatically assign values to defined arguments
- Error handling for invalid input or argument definitions
- Mimics the Go language's approach to command-line argument parsing

## Usage

```zig
const std = @import("std");
const opt = @import("optzig");

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();

    var ag = opt.Args.init(arena.allocator());

    // Define arguments
    const port = try ag.int32("port", "binding port", false, 0);
    const help = try ag.boolean("help", "Print this usage", false, false);

    // Parse command-line arguments
    var arg_inputs = try std.process.Args.Iterator.initAllocator(init.minimal.args, arena.allocator());
    try ag.parse(std.process.ArgIterator, &arg_inputs);

    // Use parsed arguments
    // ...
    std.log.info("Binding Port: {d}\n", .{port.*});

    if (help.*) {
        // try ag.usage(init.io);
        try ag.usageWithExit(init.io, 0);
    }
}
```

## Contributing

Contributions are welcome! Please follow the guidelines outlined in the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.

## License

This project is licensed under the [BSD 3-Clause](LICENSE).

