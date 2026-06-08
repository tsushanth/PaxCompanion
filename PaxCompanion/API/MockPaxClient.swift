//
//  MockPaxClient.swift
//  PaxCompanion
//
//  In-memory client backed by hand-crafted alt-history scenarios so the
//  demo is fully testable without an API key. Every preset / game / event
//  here is fake but plausibly shaped — when the real REST API lands, the
//  only thing that should change is `LivePaxClient.swift` (which doesn't
//  exist yet).
//

import Foundation

actor MockPaxClient: PaxAPIClient {

    func trendingPresets() async throws -> [Preset] {
        try? await Task.sleep(nanoseconds: 250_000_000)
        return Self.seedPresets
    }

    func myGames() async throws -> [Game] {
        try? await Task.sleep(nanoseconds: 250_000_000)
        return Self.seedGames
    }

    func events(forGame id: String, since: Date?) async throws -> [GameEvent] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        let all = Self.seedEvents[id] ?? []
        guard let since else { return all }
        return all.filter { $0.at > since }
    }

    // MARK: - Seeds

    static let seedPresets: [Preset] = [
        Preset(id: "pst_cold_war_1962",
               title: "Thirteen Days",
               summary: "October 1962. The world holds its breath. Pick a superpower or a non-aligned nation and steer through the Cuban Missile Crisis.",
               era: "Cold War", region: "Global", players: 412, plays: 18_900,
               creatorHandle: "@longshadow", coverImageName: "globe.americas.fill"),
        Preset(id: "pst_silk_road_1300",
               title: "Pax Mongolica",
               summary: "1300 CE. The Silk Road runs through your khanate. Manage tariffs, plague, succession crises.",
               era: "Medieval", region: "Asia", players: 287, plays: 12_400,
               creatorHandle: "@steppe_brain", coverImageName: "mountain.2.fill"),
        Preset(id: "pst_2042_post_climate",
               title: "After the Tide",
               summary: "2042. Coastal capitals have moved inland. Lead a climate-displaced nation through the new geopolitics of water.",
               era: "Near-Future", region: "Global", players: 633, plays: 24_100,
               creatorHandle: "@rivergeo", coverImageName: "water.waves"),
        Preset(id: "pst_1989_eu_alt",
               title: "Velvet Revolutions",
               summary: "1989. The Berlin Wall falls — but which way? Pick a Warsaw Pact state, choose your path.",
               era: "Cold War", region: "Europe", players: 198, plays: 9_800,
               creatorHandle: "@samizdat", coverImageName: "building.columns.fill"),
        Preset(id: "pst_meiji_1868",
               title: "Meiji Choice",
               summary: "1868. The shogunate is failing. Open the country or shut it harder?",
               era: "Industrial", region: "Asia", players: 154, plays: 7_300,
               creatorHandle: "@torii", coverImageName: "leaf.fill"),
        Preset(id: "pst_solar_grid_2080",
               title: "The Solar Compact",
               summary: "2080. The world runs on a shared orbital grid. Who controls it?",
               era: "Future", region: "Global", players: 521, plays: 21_500,
               creatorHandle: "@sunline", coverImageName: "sun.haze.fill"),
    ]

    static let seedGames: [Game] = [
        Game(id: "game_001",
             presetTitle: "Thirteen Days",
             nationName: "Soviet Union",
             nationEmoji: "🇷🇺",
             currentTurn: 47, totalTurns: 80,
             lastTickAt: Date().addingTimeInterval(-720),
             stability: 0.62),
        Game(id: "game_002",
             presetTitle: "After the Tide",
             nationName: "Brazil",
             nationEmoji: "🇧🇷",
             currentTurn: 12, totalTurns: 60,
             lastTickAt: Date().addingTimeInterval(-1800),
             stability: 0.81),
    ]

    static let seedEvents: [String: [GameEvent]] = [
        "game_001": [
            GameEvent(id: "evt_001", gameId: "game_001", kind: .yourTurn,
                      body: "Your move. Stability holding at 62%.",
                      actor: nil, target: nil,
                      at: Date().addingTimeInterval(-720)),
            GameEvent(id: "evt_002", gameId: "game_001", kind: .warDeclared,
                      body: "United States declared war on Cuba.",
                      actor: "United States", target: "Cuba",
                      at: Date().addingTimeInterval(-1800)),
            GameEvent(id: "evt_003", gameId: "game_001", kind: .diplomatMessage,
                      body: "Khrushchev: \"Comrade, the missiles must turn back.\"",
                      actor: "Khrushchev", target: nil,
                      at: Date().addingTimeInterval(-3600)),
            GameEvent(id: "evt_004", gameId: "game_001", kind: .allianceFormed,
                      body: "Czechoslovakia joined your bloc.",
                      actor: "Czechoslovakia", target: "Soviet Union",
                      at: Date().addingTimeInterval(-7200)),
            GameEvent(id: "evt_005", gameId: "game_001", kind: .territoryGained,
                      body: "Stabilized influence in East Germany.",
                      actor: "Soviet Union", target: "East Germany",
                      at: Date().addingTimeInterval(-10_800)),
        ],
        "game_002": [
            GameEvent(id: "evt_b01", gameId: "game_002", kind: .turnAdvanced,
                      body: "Year 2046 — drought intensifies in the Amazon basin.",
                      actor: nil, target: nil,
                      at: Date().addingTimeInterval(-1800)),
            GameEvent(id: "evt_b02", gameId: "game_002", kind: .allianceFormed,
                      body: "Argentina signed the Southern Cone Water Pact.",
                      actor: "Argentina", target: "Brazil",
                      at: Date().addingTimeInterval(-5400)),
        ],
    ]
}
