//
//  PaxCompanionApp.swift
//  PaxCompanion
//

import SwiftUI

@MainActor
final class PaxSession: ObservableObject {
    let client: PaxAPIClient
    @Published var presets: [Preset] = []
    @Published var games: [Game] = []

    init(client: PaxAPIClient = MockPaxClient()) { self.client = client }

    func refresh() async {
        async let p = (try? await client.trendingPresets()) ?? []
        async let g = (try? await client.myGames()) ?? []
        let (presets, games) = await (p, g)
        self.presets = presets
        self.games = games
    }
}

@main
struct PaxCompanionApp: App {
    @StateObject private var session = PaxSession()

    var body: some Scene {
        WindowGroup {
            RootTabs()
                .environmentObject(session)
                .task { await session.refresh() }
        }
    }
}
