//
//  PaxAPI.swift
//  PaxCompanion
//
//  Read-only client surface for the companion app: list trending presets,
//  fetch the user's active games, stream events for a specific game. Designed
//  against what a future REST surface would expose — see PaxAPIClient.swift
//  for the shape the official API would need to fulfil.
//
//  Live game state on paxhistoria.co flows over WebSocket (per public HN
//  reverse-engineering thread), but the *mobile* surface they're hiring for
//  is REST per the Founding Engineer (Unity Mobile) JD. This client targets
//  the REST surface they've publicly committed to building.
//

import Foundation

protocol PaxAPIClient: Sendable {
    func trendingPresets() async throws -> [Preset]
    func myGames() async throws -> [Game]
    func events(forGame id: String, since: Date?) async throws -> [GameEvent]
}

enum PaxAPIError: LocalizedError {
    case notImplemented
    case decoding(Error)
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .notImplemented:  return "Endpoint not yet exposed in the public API"
        case .decoding(let e): return "Decoding failed: \(e.localizedDescription)"
        case .http(let s):     return "HTTP \(s)"
        }
    }
}
