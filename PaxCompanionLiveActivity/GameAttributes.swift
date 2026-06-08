//
//  GameAttributes.swift
//  PaxCompanionLiveActivity
//
//  Shared by host app (starts/updates the activity) and widget extension
//  (renders Lock Screen + Dynamic Island). Keep this file in BOTH targets —
//  see project.yml.
//

import ActivityKit

public struct GameAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var nationEmoji: String
        public var nationName: String
        public var headline: String        // "War declared", "Your turn", ...
        public var detail: String          // human-readable: "Germany declared war on France"
        public var iconSystemName: String  // SF Symbol for the event kind
        public var currentTurn: Int
        public var totalTurns: Int
        public var stability: Double       // 0..1

        public init(nationEmoji: String, nationName: String, headline: String,
                    detail: String, iconSystemName: String,
                    currentTurn: Int, totalTurns: Int, stability: Double) {
            self.nationEmoji = nationEmoji
            self.nationName = nationName
            self.headline = headline
            self.detail = detail
            self.iconSystemName = iconSystemName
            self.currentTurn = currentTurn
            self.totalTurns = totalTurns
            self.stability = stability
        }
    }

    public var gameId: String
    public var presetTitle: String

    public init(gameId: String, presetTitle: String) {
        self.gameId = gameId
        self.presetTitle = presetTitle
    }
}
