//
//  ContentView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

// This view is no longer used as main interface
// WhistlerRideTabView is now the main app interface

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "mountain.2.fill")
                .imageScale(.large)
                .foregroundStyle(.blue)
            Text("Gorby gaap App")
                .font(.title)
                .fontWeight(.bold)
            Text("This view is replaced by WhistlerRideTabView")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
