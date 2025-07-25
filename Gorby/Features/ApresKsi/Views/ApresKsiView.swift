//
//  ApresKsiView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-19.
//

import SwiftUI

struct ApresKsiView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        
                        Text("Apres Ski")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Text("Coming Soon!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // Placeholder content
                    VStack(spacing: 16) {
                        Text("Apres ski content will be available soon")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("Apres")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ApresKsiView()
        .environmentObject(ThemeManager())
} 