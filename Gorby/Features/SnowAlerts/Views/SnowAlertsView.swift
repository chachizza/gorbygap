//
//  SnowAlertsView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct SnowAlertsView: View {
    @StateObject private var viewModel = SnowAlertsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Snow Threshold") {
                    HStack {
                        Text("Alert when new snow exceeds:")
                        Spacer()
                        Picker("Threshold", selection: $viewModel.snowThreshold) {
                            Text("10 cm").tag(10)
                            Text("20 cm").tag(20)
                            Text("30 cm").tag(30)
                            Text("40 cm").tag(40)
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Notification Settings") {
                    Toggle("Enable Snow Alerts", isOn: $viewModel.snowAlertsEnabled)
                    
                    if viewModel.snowAlertsEnabled {
                        DatePicker("Wake-up Time", 
                                 selection: $viewModel.wakeUpTime, 
                                 displayedComponents: .hourAndMinute)
                        
                        Toggle("24-Hour Check", isOn: $viewModel.hourlyCheck)
                            .help("Check for snow updates every hour")
                    }
                }
                
                Section("Alert History") {
                    ForEach(viewModel.recentAlerts) { alert in
                        SnowAlertHistoryRow(alert: alert)
                    }
                }
                
                Section("Test") {
                    Button("Send Test Notification") {
                        viewModel.sendTestNotification()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Snow Alerts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SnowAlertHistoryRow: View {
    let alert: SnowAlert
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(alert.snowAmount) cm new snow")
                    .font(.headline)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(alert.timestamp, style: .date)
                    .font(.caption)
                
                Text(alert.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SnowAlertsView()
} 