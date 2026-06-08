//
//  RootTabs.swift
//  PaxCompanion
//

import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            ScenarioBrowserView()
                .tabItem { Label("Scenarios", systemImage: "map.fill") }
            MyGamesView()
                .tabItem { Label("My Games", systemImage: "flag.checkered") }
        }
        .tint(.indigo)
    }
}
