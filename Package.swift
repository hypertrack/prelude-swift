// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Prelude",
  products: [
    .library(
      name: "Prelude",
      type: .dynamic,
      targets: ["Prelude"]
    ),
  ],
  targets: [
    .target(
      name: "Prelude",
      exclude: ["Templates"]
    ),
    .testTarget(
      name: "PreludeTests",
      dependencies: ["Prelude"]
    )
  ]
)
