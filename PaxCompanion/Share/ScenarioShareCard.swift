//
//  ScenarioShareCard.swift
//  PaxCompanion
//
//  SwiftUI -> UIImage via ImageRenderer. Generates the kind of square card
//  that gets posted to X / TikTok / Discord. Plays directly into Pax's
//  content-creator hire (they explicitly listed it on the jobs page) — every
//  shared card is free top-of-funnel.
//

import SwiftUI

struct ScenarioShareCard: View {
    let game: Game
    let highlight: GameEvent?

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo, .purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text(game.nationEmoji).font(.system(size: 60))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.nationName)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text(game.presetTitle)
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                if let h = highlight {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: h.kind.iconName)
                            Text(h.kind.headline.uppercased())
                                .font(.caption.weight(.bold))
                                .tracking(2)
                        }
                        .foregroundStyle(.white)
                        Text(h.body)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    .padding(.top, 8)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TURN").font(.caption2.weight(.bold)).foregroundStyle(.white.opacity(0.7))
                        Text("\(game.currentTurn) / \(game.totalTurns)")
                            .font(.title3.monospacedDigit().bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("STABILITY").font(.caption2.weight(.bold)).foregroundStyle(.white.opacity(0.7))
                        Text("\(Int(game.stability * 100))%")
                            .font(.title3.monospacedDigit().bold())
                            .foregroundStyle(.white)
                    }
                }
                HStack {
                    Spacer()
                    Text("paxhistoria.co")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(28)
        }
        .frame(width: 600, height: 600)
    }

    /// Renders the card as a UIImage suitable for ShareLink / UIActivityViewController.
    @MainActor
    func render() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
