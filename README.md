# swift-thread-local

A swift package providing thread-local value wrappers.

## Installation

### Swift Package Manager (SPM)

Add the [swift-thread-local](https://github.com/ben-smith-dev/swift-thread-local) SPM package to your package's dependency list:

```swift
dependencies: [
    .package(url: "https://github.com/ben-smith-dev/swift-thread-local", from: "0.1.0"),
]
```

Then add the `ThreadLocal` product to a target's dependency list:

```swift
dependencies: [
    .product(name: "ThreadLocal", package: "swift-thread-local"),
]
```

### Xcode

Add [swift-thread-local](https://github.com/ben-smith-dev/swift-thread-local) to your project as a package dependency.

## Contributing

**This project is currently not accepting Pull Requests.**

However, feedback is welcome! Please feel free to [open an issue](https://github.com/ben-smith-dev/swift-thread-local/issues) to report bugs, suggest improvements, or discuss feature requests.

## License

This package is available under the MIT license, see [LICENSE](https://github.com/ben-smith-dev/swift-thread-local/blob/main/LICENSE) for details.
