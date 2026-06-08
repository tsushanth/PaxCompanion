//
//  ScenarioBrowserView.swift
//  PaxCompanion
//
//  Browse trending presets. Filter chips by era + region. Tap a preset card
//  to see details — in the real app this would deep-link to paxhistoria.co
//  with a magic-link sign-in to immediately start a round.
//

import SwiftUI

struct ScenarioBrowserView: View {
    @EnvironmentObject private var session: PaxSession
    @State private var selectedEra: String? = nil
    @State private var selectedRegion: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    chipRow(title: "Era", values: eras, selection: $selectedEra)
                    chipRow(title: "Region", values: regions, selection: $selectedRegion)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(filteredPresets) { preset in
                            NavigationLink {
                                PresetDetailView(preset: preset)
                            } label: {
                                presetCard(preset)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .navigationTitle("Trending")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    private var eras: [String]    { Array(Set(session.presets.map(\.era))).sorted() }
    private var regions: [String] { Array(Set(session.presets.map(\.region))).sorted() }

    private var filteredPresets: [Preset] {
        session.presets.filter { preset in
            (selectedEra == nil || preset.era == selectedEra) &&
            (selectedRegion == nil || preset.region == selectedRegion)
        }
        .sorted { $0.plays > $1.plays }
    }

    private func chipRow(title: String, values: [String], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary).padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip(label: "All", isSelected: selection.wrappedValue == nil) {
                        selection.wrappedValue = nil
                    }
                    ForEach(values, id: \.self) { v in
                        chip(label: v, isSelected: selection.wrappedValue == v) {
                            selection.wrappedValue = selection.wrappedValue == v ? nil : v
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.indigo : Color(.secondarySystemBackground),
                            in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private func presetCard(_ preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                LinearGradient(
                    colors: [colorFor(era: preset.era), colorFor(era: preset.era).opacity(0.55)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Image(systemName: preset.coverImageName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(preset.title).font(.headline).lineLimit(1)
            Text(preset.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack(spacing: 8) {
                Label("\(preset.players)", systemImage: "person.2.fill")
                Spacer()
                Text("\(preset.plays.formatted()) plays")
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func colorFor(era: String) -> Color {
        switch era {
        case "Cold War":   return .red
        case "Medieval":   return .brown
        case "Industrial": return .orange
        case "Near-Future": return .cyan
        case "Future":     return .purple
        default:           return .indigo
        }
    }
}

struct PresetDetailView: View {
    let preset: Preset

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    LinearGradient(colors: [.indigo, .purple],
                                   startPoint: .top, endPoint: .bottom)
                    Image(systemName: preset.coverImageName)
                        .font(.system(size: 88))
                        .foregroundStyle(.white)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 6) {
                    Text(preset.title).font(.title.bold())
                    Text("By \(preset.creatorHandle)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    stat(label: "Era", value: preset.era)
                    stat(label: "Region", value: preset.region)
                    stat(label: "Active", value: "\(preset.players)")
                }
                .padding(.horizontal, 16)

                Text(preset.summary)
                    .font(.body)
                    .padding(.horizontal, 16)

                Button {
                    if let url = URL(string: "https://paxhistoria.co/p/\(preset.id)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open in browser", systemImage: "arrow.up.right.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.indigo, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
