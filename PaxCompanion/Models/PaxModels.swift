//
//  PaxModels.swift
//  PaxCompanion
//
//  Domain models matching the public surface of paxhistoria.co. Names follow
//  the wiki + YC company page vocabulary: "preset" = scenario template,
//  "game" = an instance someone is playing, "tick" = single time-step,
//  "event" = something significant (war declared, alliance, your turn).
//
//  Decoded shapes are best-effort against the public web — swap to the real
//  schema once /api is documented.
//

import Foundation

struct Preset: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let summary: String
    let era: String              // "1920s", "Cold War", "Modern", ...
    let region: String           // "Europe", "Asia", "Global"
    let players: Int             // current active rounds using this preset
    let plays: Int               // lifetime plays — drives "trending" sort
    let creatorHandle: String
    let coverImageName: String   // SF Symbol stand-in until real CDN URLs land
}

struct Game: Identifiable, Codable, Hashable {
    let id: String
    let presetTitle: String
    let nationName: String       // "Soviet Union", "Brazil", ...
    let nationEmoji: String      // flag emoji
    let currentTurn: Int
    let totalTurns: Int          // session length cap; nil for open-ended
    let lastTickAt: Date
    let stability: Double        // 0..1 — derived stat surfaced in the widget
}

enum GameEventKind: String, Codable {
    case turnAdvanced     = "turn_advanced"
    case warDeclared      = "war_declared"
    case allianceFormed   = "alliance_formed"
    case territoryGained  = "territory_gained"
    case territoryLost    = "territory_lost"
    case yourTurn         = "your_turn"
    case diplomatMessage  = "diplomat_message"

    var headline: String {
        switch self {
        case .turnAdvanced:    return "Turn advanced"
        case .warDeclared:     return "War declared"
        case .allianceFormed:  return "Alliance formed"
        case .territoryGained: return "Territory gained"
        case .territoryLost:   return "Territory lost"
        case .yourTurn:        return "Your turn"
        case .diplomatMessage: return "Diplomat message"
        }
    }

    var iconName: String {
        switch self {
        case .turnAdvanced:    return "hourglass"
        case .warDeclared:     return "burst"
        case .allianceFormed:  return "handshake.fill"
        case .territoryGained: return "arrow.up.right.square.fill"
        case .territoryLost:   return "arrow.down.left.square.fill"
        case .yourTurn:        return "bell.badge.fill"
        case .diplomatMessage: return "bubble.left.and.bubble.right.fill"
        }
    }
}

struct GameEvent: Identifiable, Codable, Hashable {
    let id: String
    let gameId: String
    let kind: GameEventKind
    let body: String             // "Germany declared war on France"
    let actor: String?           // nation acting (or nil for your-turn)
    let target: String?          // nation acted upon
    let at: Date
}
