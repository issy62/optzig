# optzig

`optzig` is a command-line argument parsing library for the Zig programming language, inspired by the approach used in Go. It provides a structured way to define and parse command-line arguments, supporting various data types such as booleans, integers, floats, and strings.

## Features

- Define arguments with names, descriptions, and types
- Parse command-line arguments and automatically assign values to defined arguments
- Support for long arguments (e.g., `--verbose`)
- Error handling for invalid input or argument definitions
- Mimics the Go language's approach to command-line argument parsing

## Usage

```zig
const std = @import("std");
const opt = @import("optzig");

pub fn main() !void {
    var dba: if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}) else void =
        if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}).init else {};

    var arena = std.heap.ArenaAllocator.init(switch (BUILD_MODE) {
        .ReleaseFast, .ReleaseSmall, .ReleaseSafe => std.heap.smp_allocator,
        .Debug => dba.allocator(),
    });

    defer arena.deinit()

    var args = opt.Args.init(&arena);

    // Define arguments
    try args.add("verbose", "Enable verbose output", opt.ArgTypes{ .Boolean = false });
    try args.add("port", "Server port number", opt.ArgTypes{ .UInt16 = 8080 });
    try args.add("name", "User name", opt.ArgTypes{ .String = undefined });

    // Parse command-line arguments
    var arg_inputs = try std.process.argsWithAllocator(arena.allocator());
    try args.parse(&arg_inputs);

    // Access parsed argument values
    const verbose = args.items.get("verbose").?.value.Boolean;
    const port = args.items.get("port").?.value.UInt16;
    const name = args.items.get("name").?.value.String;

    // Use parsed arguments
    // ...
}
```

## Contributing

Contributions are welcome! Please follow the guidelines outlined in the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) file.

## License

This project is licensed under the [MIT License](LICENSE).

