//
//  GameLiveActivity.swift
//  PaxCompanionWidget
//
//  Lock Screen + Dynamic Island presentation for an active game session.
//  Updates are pushed from the host app whenever a significant event lands
//  (war declared, your turn, alliance formed). The exact event headline is
//  passed via ContentState — see GameAttributes.
//
//  Why a Live Activity instead of a banner notification: events that need
//  follow-up action (your turn, war declared) deserve persistent surface
//  area, not a notification the user swipes away. Dynamic Island gives
//  Pax that surface area while the player is in another app.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct GameLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameAttributes.self) { context in
            // Lock Screen / banner
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: context.state.iconSystemName)
                        .foregroundStyle(.indigo)
                    Text(context.state.headline)
                        .font(.headline)
                    Spacer()
                    Text(context.state.nationEmoji).font(.title3)
                }
                Text(context.state.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                ProgressView(value: Double(context.state.currentTurn),
                             total: Double(max(context.state.totalTurns, 1)))
                    .tint(.indigo)
                HStack {
                    Text("Turn \(context.state.currentTurn)/\(context.state.totalTurns)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(context.state.stability * 100))% stability")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(stabilityColor(context.state.stability))
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.5))
            .activitySystemActionForegroundColor(.indigo)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.state.nationName).font(.caption.weight(.semibold))
                    } icon: {
                        Text(context.state.nationEmoji)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("T\(context.state.currentTurn)/\(context.state.totalTurns)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.iconSystemName)
                            .foregroundStyle(.indigo)
                        Text(context.state.headline).font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            } compactLeading: {
                Text(context.state.nationEmoji)
            } compactTrailing: {
                Image(systemName: context.state.iconSystemName)
                    .foregroundStyle(.indigo)
            } minimal: {
                Image(systemName: context.state.iconSystemName)
                    .foregroundStyle(.indigo)
            }
        }
    }

    private func stabilityColor(_ s: Double) -> Color {
        switch s {
        case ..<0.4:  return .red
        case ..<0.7:  return .yellow
        default:      return .green
        }
    }
}

@main
struct PaxCompanionWidgetBundle: WidgetBundle {
    var body: some Widget {
        GameStatusWidget()
        GameLiveActivity()
    }
}
