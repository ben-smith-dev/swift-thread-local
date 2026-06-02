# swift-thread-local

A swift package providing thread-local value wrappers.

## Installation

### Swift Package Manager (SPM)

Add the [swift-thread-local](https://github.com/ben-smith-dev/swift-thread-local) SPM package to your package's dependency list:

```swift
dependencies: [
    .package(url: "https://github.com/ben-smith-dev/swift-thread-local", from: "0.2.0"),
]
```

Then add the `ThreadLocal` product to a target's dependency list:

```swift
dependencies: [
    .product(name: "ThreadLocal", package: "swift-thread-local"),
]
```

### Xcode

Add [swift-thread-local](https://github.com/ben-smith-dev/swift-thread-local) to your project as a [package dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency).

## Privacy

This package does not collect data or use required reason APIs.

<details>
  <summary>Apple's privacy requirements</summary>

  <ul>
    <li><a href="https://developer.apple.com/documentation/bundleresources/privacy-manifest-files">Privacy Manifest Files</a></li>
    <li><a href="https://developer.apple.com/app-store/user-privacy-and-data-use">User Privacy and Data Use</a></li>
    <li><a href="https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests">Describing Data Use in Privacy Manifests</a></li>
  </ul>
</details>

## Contributing

**This project is currently not accepting Pull Requests.**

However, feedback is welcome! Please feel free to [open an issue](https://github.com/ben-smith-dev/swift-thread-local/issues) to report bugs, suggest improvements, or discuss feature requests.

## License

This package is available under the MIT license, see [LICENSE](https://github.com/ben-smith-dev/swift-thread-local/blob/main/LICENSE) for details.
