//
//  MyGamesView.swift
//  PaxCompanion
//
//  Your active games. Tap a game to see the event log + Live Activity controls
//  + share card generator.
//

import SwiftUI

struct MyGamesView: View {
    @EnvironmentObject private var session: PaxSession

    var body: some View {
        NavigationStack {
            Group {
                if session.games.isEmpty {
                    empty
                } else {
                    list
                }
            }
            .navigationTitle("My Games")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    private var empty: some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 56))
                .foregroundStyle(.indigo.opacity(0.7))
            Text("No active games").font(.title3.weight(.semibold))
            Text("Start a round at paxhistoria.co — it'll show up here.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(session.games) { game in
                    NavigationLink {
                        GameDetailView(game: game)
                    } label: {
                        gameRow(game)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func gameRow(_ game: Game) -> some View {
        HStack(spacing: 12) {
            Text(game.nationEmoji).font(.system(size: 40))
            VStack(alignment: .leading, spacing: 4) {
                Text(game.nationName).font(.headline)
                Text(game.presetTitle).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "hourglass")
                    Text("Turn \(game.currentTurn)/\(game.totalTurns)")
                    Text("·")
                    Text("\(Int(game.stability * 100))% stab")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct GameDetailView: View {
    let game: Game

    @EnvironmentObject private var session: PaxSession
    @StateObject private var pushService = PushService.shared
    @State private var events: [GameEvent] = []
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                liveActivityRow
                shareRow
                eventLog
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(game.nationName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task {
            events = (try? await session.client.events(forGame: game.id, since: nil)) ?? []
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(items: [img])
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(game.nationEmoji).font(.system(size: 60))
            VStack(alignment: .leading, spacing: 4) {
                Text(game.presetTitle).font(.caption).foregroundStyle(.secondary)
                Text(game.nationName).font(.title2.bold())
                HStack(spacing: 8) {
                    Label("Turn \(game.currentTurn)/\(game.totalTurns)", systemImage: "hourglass")
                    Label("\(Int(game.stability * 100))% stab", systemImage: "gauge.with.dots.needle.50percent")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private var liveActivityRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Live Activity")
                .font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Button {
                    Task {
                        await pushService.requestPermissionsAndRegister()
                        if let first = events.first {
                            pushService.startLiveActivity(for: game, initialEvent: first)
                        }
                    }
                } label: {
                    Label("Start", systemImage: "bell.badge.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.indigo, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.white)
                }
                Button {
                    pushService.endLiveActivity()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.primary)
                }
            }
            .font(.subheadline.weight(.semibold))
            if let token = pushService.deviceToken {
                Text("APNs token: \(token.prefix(16))…")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private var shareRow: some View {
        Button {
            let card = ScenarioShareCard(game: game, highlight: events.first)
            shareImage = card.render()
            showShareSheet = shareImage != nil
        } label: {
            Label("Share a card", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.primary)
        }
    }

    private var eventLog: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent events").font(.caption).foregroundStyle(.secondary)
            ForEach(events) { e in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: e.kind.iconName)
                        .foregroundStyle(.indigo)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(e.kind.headline).font(.subheadline.weight(.semibold))
                        Text(e.body).font(.caption).foregroundStyle(.secondary)
                        Text(e.at.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Button {
                        Task { await pushService.ingest(event: e, for: game) }
                    } label: {
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(.indigo)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Share sheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
