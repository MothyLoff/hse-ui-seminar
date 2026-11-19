import ProjectDescription

let project = Project(
    name: "VotingApp",
    settings: .settings(base: ["SWIFT_VERSION": "6.0"]),
    targets: [
        .target(
            name: "Pollar",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.timothyloff.pollar.app",
            deploymentTargets: .iOS("27.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Pollar",
                "UILaunchScreen": [:]
            ]),
            sources: ["App/Sources/**"],
            dependencies: [
                .target(name: "PollarCore")
            ],
            settings: .settings(base: [
                "DEVELOPMENT_TEAM": "72UHRA8X5G",
                "CODE_SIGN_STYLE": "Automatic"
            ])
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
