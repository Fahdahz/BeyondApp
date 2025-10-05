//
//  ProgressPage.swift
//  BeyondApp
//
//  Created by Fahdah Alsamari on 11/04/1447 AH.
//

import SwiftUI

struct ProgressPage: View {
    @ObservedObject var store: ConfidenceStore
    @AppStorage("isDarkMode") private var isDarkMode = false

    private var bgColors: [Color] {
        isDarkMode
        ? [.black.opacity(0.92), .black.opacity(0.75)]
        : [Color(red: 1.0, green: 0.5843, blue: 0.0, opacity: 0.18),
           Color(red: 1.0, green: 0.4118, blue: 0.7059, opacity: 0.12)]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: bgColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Weekly headline card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your confidence grew \(store.thisWeekPercent())% this week — You're doing great!")
                            .font(.headline)
                        MiniLine(values: store.last14().deltas)
                            .frame(height: 72)
                            .padding(.horizontal, -8)
                        Text("Based on quick check-ins after challenges.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15)))

                    // Heat map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Confidence heat map (last 6 weeks)")
                            .font(.headline)
                        HeatMap(entries: store.entries)
                            .frame(height: 180)
                        HStack(spacing: 16) {
                            LegendSwatch(color: .red.opacity(0.45), label: "Lower")
                            LegendSwatch(color: .gray.opacity(0.25), label: "No data")
                            LegendSwatch(color: .green.opacity(0.55), label: "Higher")
                        }.font(.footnote)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15)))

                    Spacer(minLength: 12)
                }
                .padding()
            }
        }
        .navigationTitle("Progress")
    }
}

// MARK: - Mini Line
private struct MiniLine: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let vals = values.isEmpty ? [0] : values
            let minV = min(0, vals.min() ?? 0)
            let maxV = max(0, vals.max() ?? 0)
            let range = max(0.001, maxV - minV)

            Path { p in
                for (i, v) in vals.enumerated() {
                    let x = w * CGFloat(Double(i) / Double(max(1, vals.count - 1)))
                    let y = h - (CGFloat((v - minV) / range) * h)
                    i == 0 ? p.move(to: CGPoint(x: x, y: y)) : p.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Heat map
private struct HeatMap: View {
    let entries: [ConfidenceEntry]

    private var days: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<42).reversed().map { cal.date(byAdding: .day, value: -$0, to: today)! }
    }

    private func color(for date: Date) -> Color {
        let cal = Calendar.current
        let dayEntries = entries.filter { cal.isDate($0.date, inSameDayAs: date) }
        guard !dayEntries.isEmpty else { return .gray.opacity(0.25) }
        let avg = dayEntries.map(\.delta).reduce(0,+) / Double(dayEntries.count)
        if avg > 0.5 { return .green.opacity(0.55) }
        if avg < -0.5 { return .red.opacity(0.45) }
        return .yellow.opacity(0.45)
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(days, id: \.self) { d in
                RoundedRectangle(cornerRadius: 6)
                    .fill(color(for: d))
                    .frame(height: 18)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.white.opacity(0.1)))
                    .accessibilityLabel(Text(d.formatted(date: .abbreviated, time: .omitted)))
            }
        }
    }
}

private struct LegendSwatch: View {
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4).fill(color).frame(width: 14, height: 14)
            Text(label)
        }
    }
}
