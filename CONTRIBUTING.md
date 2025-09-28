# Contributing to Dart NoSQL Database

Thank you for your interest in contributing to the Dart NoSQL Database! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** to demonstrate the steps
- **Describe the behavior you observed** and explain why it's a problem
- **Explain which behavior you expected** to see instead
- **Include your environment details** (Dart version, operating system, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Provide specific examples** to demonstrate how it would work
- **Describe the current behavior** and how your suggestion improves it
- **Explain why this enhancement would be useful** to most users

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing code style
6. Issue that pull request!

## Development Setup

### Prerequisites

- Dart SDK (3.0.0 or higher)
- Git

### Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/dart-nosql-database.git
   cd dart-nosql-database
   ```

3. Install dependencies:
   ```bash
   dart pub get
   ```

4. Run tests:
   ```bash
   dart test
   ```

5. Run the example:
   ```bash
   dart run example/basic_usage.dart
   ```

## Development Guidelines

### Code Style

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Testing

- Write tests for new functionality
- Ensure all tests pass before submitting
- Aim for good test coverage
- Test both happy path and error scenarios

### Documentation

- Update README.md if you add new features
- Add inline documentation for public APIs
- Update examples if you change the API
- Keep documentation concise and clear

## Project Structure

```
dart-nosql-database/
├── lib/
│   ├── src/
│   │   ├── database.dart          # Main database class
│   │   ├── query_engine.dart      # Query execution engine
│   │   ├── index_manager.dart     # Index management
│   │   └── storage_engine.dart    # File storage operations
│   └── dart_nosql_database.dart   # Library exports
├── bin/
│   └── main.dart                  # CLI interface
├── test/
│   └── database_test.dart         # Test suite
├── examples/
│   ├── basic_usage.dart           # Basic usage examples
│   └── advanced_queries.dart      # Advanced query examples
├── web/
│   └── index.html                 # Interactive web demo
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── pubspec.yaml
```

## Areas for Contribution

### Core Features
- **Query Optimization**: Improve query execution performance
- **Indexing**: Add support for compound indexes and full-text search
- **Storage**: Enhance file storage with compression and encryption
- **Concurrency**: Add thread-safe operations
- **Transactions**: Implement ACID transaction support

### Developer Experience
- **Documentation**: Improve guides, tutorials, and API docs
- **Examples**: Create more usage examples and use cases
- **Tools**: Build development and debugging tools
- **Performance**: Add benchmarks and profiling tools

### Ecosystem
- **Connectors**: Build connectors for popular frameworks
- **ORM**: Create an Object-Document Mapper
- **Migration**: Add data migration tools
- **Backup**: Implement backup and restore functionality

## Submitting Changes

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines above

3. **Test your changes**:
   ```bash
   dart test
   dart analyze
   dart format --set-exit-if-changed .
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Build process or auxiliary tool changes

Examples:
- `feat: add compound index support`
- `fix: resolve query predicate evaluation error`
- `docs: update API documentation`
- `test: add tests for storage engine`

## Review Process

1. All submissions require review
2. Reviewers will check for:
   - Code quality and style
   - Test coverage
   - Documentation updates
   - Performance implications
   - Backward compatibility

3. Address any feedback before merge

## Questions?

Feel free to ask questions by:
- Opening an issue with the `question` label
- Starting a discussion in the GitHub Discussions
- Reaching out to maintainers

Thank you for contributing! 🚀