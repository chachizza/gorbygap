//
//  WebcamView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct WebcamView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Live Webcams")
                    .font(.title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Live Webcams")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WebcamView()
} 