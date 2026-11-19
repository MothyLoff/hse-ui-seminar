import ProjectDescription

let project = Project(
    name: "VotingApp",
    settings: .settings(base: ["SWIFT_VERSION": "6.0"]),
    targets: [
        .target(
            name: "VotingApp",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.timothyloff.votingapp",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Голосования",
                "UILaunchScreen": [:]
            ]),
            sources: ["Sources/**"],
            dependencies: []
        ),
        
        .target(
            name: "PollarCore",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.timothyloff.pollar.core",
            deploymentTargets: .iOS("27.0"),
            infoPlist: .default,
            sources: ["Core/Sources/**"]
        ),
        .target(
            name: "PollarCoreTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.timothyloff.pollar.core.tests",
            deploymentTargets: .iOS("27.0"),
            infoPlist: .default,
            sources: ["Core/Tests/**"],
            dependencies: [
                .target(name: "PollarCore")
            ]
        )
    ]
)
