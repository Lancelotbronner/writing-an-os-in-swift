// swift-tools-version: 6.4

import PackageDescription

let package = Package(
	name: "Writing an OS in Swift",
	platforms: [
		.macOS(.v14),
	],
	dependencies: [
		.package(url: "https://github.com/Lancelotbronner/swift-embedded-arch.git", branch: "main"),
	],
	targets: [
		.executableTarget(
			name: "Kernel",
			dependencies: [
				.product(name: "EmbeddedArch", package: "swift-embedded-arch"),
			],
			swiftSettings: [
				.enableExperimentalFeature("Embedded"),
				.enableExperimentalFeature("Extern"),
				.enableExperimentalFeature("Lifetimes"),
				.enableExperimentalFeature("SafeInteropWrappers"),
				.enableExperimentalFeature("Volatile"),
				.enableUpcomingFeature("ExistentialAny"),
				.enableUpcomingFeature("ImmutableWeakCaptures"),
				.enableUpcomingFeature("InferIsolatedConformances"),
				.enableUpcomingFeature("InternalImportsByDefault"),
				.enableUpcomingFeature("MemberImportVisibility"),
				.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
				.strictMemorySafety(),
				.treatAllWarnings(as: .error),
			],
		),
	],
	swiftLanguageModes: [.v6],
	cLanguageStandard: .c2x
)
