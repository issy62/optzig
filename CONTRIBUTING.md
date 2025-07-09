# Contributing to optzig

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md). Keep it simple: be **DECENT** and **TOLERANT**.

## Getting Started

### Prerequisites
- Zig 0.14.0 or higher

### Development Setup
```bash
git clone https://github.com/issy62/optzig.git
cd optzig
zig build test  # Run tests to ensure everything works
```

## Development Workflow

### Before You Start
1. Check existing issues and PRs to avoid duplicates
2. For major changes, open an issue first to discuss
3. Fork the repository and create a feature branch

### Making Changes
1. **Write tests** where you see fit. Do make sure the existing ones are passing!
2. **Run the test suite**: `zig build test`

### Commit Guidelines
We use conventional commits. See [.gitmessage](.gitmessage) for detailed format.

**Quick reference:**
- `feat:` - New features
- `fix:` - Bug fixes
- `feat!:` - Breaking changes
- `docs:` - Documentation only
- `test:` - Test-related changes

**Examples:**
```
feat: add string argument support
fix: handle empty argument values
feat!: change argument definition API
```

## Testing

### Running Tests
```bash
zig build test                    # Run all tests
zig build test -- --summary all  # Detailed output
zig test src/optzig.zig          # Direct test execution
```

### Test Suggestions
- Test both success and error cases
- Use `MockArgIterator` for argument parsing tests
- Follow existing test naming: `test "Optzig.Component description"`

## Pull Request Process
1. **Update tests** and ensure they pass
2. **Clear commit messages**
3. **Small, focused PRs** are preferred over large ones
4. **Include breaking change notice** in commit if API changes

### PR Checklist
- [ ] Tests pass (`zig build test`)
- [ ] Code follows project conventions
- [ ] Commit messages follow conventional format
- [ ] No merge conflicts

## Types of Contributions

### Bug Fixes
- Include reproduction steps in the issue/PR
- Add tests that would have caught the bug

### New Features
- Discuss in an issue first for major features
- Consider backward compatibility
- Update documentation and examples (runner.zig)

## Questions?

- Open an issue for bugs or feature requests
- Check existing documentation and issues first
- Be specific and provide examples

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

