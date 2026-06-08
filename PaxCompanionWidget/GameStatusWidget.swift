//
//  GameStatusWidget.swift
//  PaxCompanionWidget
//
//  Home Screen widget — "Your Soviet Union, Turn 47" passive ping. The whole
//  point of this widget is solving the 35K-DAU pain that players have zero
//  way to know their game ticked without opening a browser tab. A small,
//  medium, and rectangular lock-screen size cover the three surfaces.
//

import WidgetKit
import SwiftUI

struct GameStatusEntry: TimelineEntry {
    let date: Date
    let nationEmoji: String
    let nationName: String
    let presetTitle: String
    let currentTurn: Int
    let totalTurns: Int
    let stability: Double
    let secondsSinceTick: Int

    static let preview = GameStatusEntry(
        date: Date(),
        nationEmoji: "🇷🇺",
        nationName: "Soviet Union",
        presetTitle: "Thirteen Days",
        currentTurn: 47, totalTurns: 80,
        stability: 0.62, secondsSinceTick: 720
    )
}

struct GameStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> GameStatusEntry { .preview }
    func getSnapshot(in context: Context, completion: @escaping (GameStatusEntry) -> Void) {
        completion(.preview)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<GameStatusEntry>) -> Void) {
        // Refresh every 5 minutes — the real app would write the latest
        // entry to App Group storage from a push-notification handler, and
        // this provider would read from there.
        let entries = [GameStatusEntry.preview]
        let refresh = Date().addingTimeInterval(300)
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }
}

struct GameStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GameStatusWidget", provider: GameStatusProvider()) { entry in
            GameStatusWidgetView(entry: entry)
                .containerBackground(for: .widget) { background }
        }
        .configurationDisplayName("Active Game")
        .description("Shows your current nation, turn, and stability.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }

    private var background: some View {
        LinearGradient(colors: [.indigo.opacity(0.85), .purple.opacity(0.85)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct GameStatusWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: GameStatusEntry

    var body: some View {
        switch family {
        case .systemMedium:                 medium
        case .accessoryRectangular:         rectangular
        default:                            small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.nationEmoji).font(.system(size: 28))
            Text(entry.nationName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                Text("Turn \(entry.currentTurn)/\(entry.totalTurns)")
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.white.opacity(0.9))
            stabilityBar
        }
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.nationEmoji).font(.system(size: 36))
                Text(entry.nationName)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.presetTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Image(systemName: "hourglass")
                    Text("Turn \(entry.currentTurn) of \(entry.totalTurns)")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white)
                stabilityBar
                lastTickPill
            }
            Spacer(minLength: 0)
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(entry.nationEmoji)
                Text(entry.nationName).font(.headline)
            }
            Text("Turn \(entry.currentTurn)/\(entry.totalTurns) · \(Int(entry.stability * 100))% stab")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private var stabilityBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(.white.opacity(0.2))
                RoundedRectangle(cornerRadius: 3)
                    .fill(stabilityColor)
                    .frame(width: geo.size.width * CGFloat(entry.stability))
            }
        }
        .frame(height: 5)
    }

    private var stabilityColor: Color {
        switch entry.stability {
        case ..<0.4:  return .red
        case ..<0.7:  return .yellow
        default:      return .green
        }
    }

    private var lastTickPill: some View {
        let mins = max(0, entry.secondsSinceTick / 60)
        return HStack(spacing: 3) {
            Image(systemName: "clock")
            Text(mins == 0 ? "just now" : "\(mins) min ago")
        }
        .font(.caption2.monospacedDigit())
        .foregroundStyle(.white.opacity(0.75))
    }
}
