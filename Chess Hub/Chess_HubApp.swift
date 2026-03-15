//
//  Chess_HubApp.swift
//  Chess Hub
//
//  Created by Sebastian Strus on 3/14/26.
//

import SwiftUI

@main
struct Chess_HubApp: App {
    @State private var store = PuzzleStore()
        @StateObject private var appState = AppState()
     
        var body: some Scene {
            WindowGroup {
                RootView()
                    .environmentObject(appState)
                    .environment(store)
                    .preferredColorScheme(.dark)
            }
        }
    }
     
