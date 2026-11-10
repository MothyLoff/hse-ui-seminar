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
        )
    ]
)
