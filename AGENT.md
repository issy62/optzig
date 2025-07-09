# AGENT.md

DO NOT MODIFY THE CODE BASE! Only make suggestions.

## Project Overview
**optzig** is a command-line argument parsing library for Zig, inspired by Go's approach. It provides structured argument definition and parsing with comprehensive type support.

## Frequently Used Commands

### Build Commands
- `zig build` - Build the project
- `zig build run` - Build and run the demo (runner.zig)
- `zig build test` - Run all tests
- `zig build test -- --summary all` - Run tests with detailed output

### Test Commands
- `zig test src/optzig.zig` - Run tests directly
- `zig test src/optzig.zig --summary all` - Run tests with verbose output

## Project Structure

```
src/
├── optzig.zig     # Main library - Args, Arg structs, parsing logic
└── runner.zig     # Demo application showing library usage
```

## Code Style & Conventions

### Naming
- **Structs**: PascalCase (e.g., `Args`, `Arg`, `ArgTypes`)
- **Functions**: snake_case (e.g., `make_arg`, `parse_boolean`)
- **Variables**: snake_case (e.g., `active_key`, `required_count`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `BUILD_MODE`)

### Error Handling
- Use custom error types: `ArgDefinitionError`, `ArgParserError`
- Propagate errors with `try` or handle with `catch`
- Return specific errors for different failure modes

### Memory Management
- Use arena allocator pattern for CLI applications
- Clean up with `defer arena.deinit()`
- Allocate structs on heap when needed (`try allocator.create(Arg)`)

### Testing
- Use `MockArgIterator` for testing argument parsing
- Test both success and error cases
- Follow naming pattern: `test "Optzig.Component description"`

## Library Architecture

### Core Components
- **Args**: Main container for argument definitions and parsing
- **Arg**: Individual argument definition with name, description, type, and validation
- **ArgTypes**: Union type supporting 11 different data types
- **Parsing Logic**: Handles `--long` and `-short` flags, boolean toggles, negative numbers

### Type Support
- Boolean, String
- Integers: i32, i64, i128, u32, u64, u128
- Floats: f32, f64, f128

### Key Features
- Required argument validation
- Type-safe argument binding
- Error reporting with specific messages
- Boolean flag toggling
- Negative number parsing

## Development Notes

### Testing Strategy
- Unit tests for all core functionality
- MockArgIterator for controlled test scenarios
- Test both parsing success and error conditions
- Required argument validation has dedicated test coverage

### Recent Changes
- Added required argument support (breaking change)
- All argument definition functions now require `required` parameter
- Added `supplied` field tracking for validation
- Enhanced error reporting

## Common Patterns

### Argument Definition
```zig
var args = Args.init(arena.allocator());
try args.add("port", "Server port", true, ArgTypes{ .UInt32 = 8080 });
const verbose = try args.boolean("verbose", "Enable verbose", false, false);
```

### Parsing
```zig
var arg_inputs = try std.process.argsWithAllocator(arena.allocator());
try args.parse(std.process.ArgIterator, &arg_inputs);
```

### Error Handling
```zig
args.parse(std.process.ArgIterator, &arg_inputs) catch |err| {
    switch (err) {
        .RequiredArgument => {
            // Handle missing required arguments
        },
        else => return err,
    }
};
```

