//
//  ConfidenceModels.swift
//  BeyondApp
//
//  Created by Fahdah Alsamari on 11/04/1447 AH.
//

import SwiftUI

// MARK: - Data model
struct ConfidenceEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let before: Int      // 0...5
    let after:  Int      // 0...5

    var delta: Double { Double(after - before) } // -5...+5
}

// MARK: - Store (persisted in UserDefaults)
final class ConfidenceStore: ObservableObject {
    @Published private(set) var entries: [ConfidenceEntry] = []
    private let key = "confidence_entries_v1"

    init() { load() }

    func add(before: Int, after: Int, date: Date = Date()) {
        let e = ConfidenceEntry(id: UUID(), date: date, before: before, after: after)
        entries.append(e)
        save()
    }

    /// last 14 entries, ascending by date
    func last14() -> [ConfidenceEntry] {
        Array(entries.sorted { $0.date < $1.date }.suffix(14))
    }

    /// Average weekly growth percentage for this week (friendly, 0…100+)
    func thisWeekPercent() -> Int {
        let cal = Calendar.current
        let thisWeek = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
        guard !thisWeek.isEmpty else { return 0 }
        let avg = thisWeek.map(\.delta).reduce(0,+) / Double(thisWeek.count)
        return max(0, Int((avg / 5.0) * 100.0)) // clamp to >= 0 for copy
    }

    // MARK: persistence
    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let arr = try? JSONDecoder().decode([ConfidenceEntry].self, from: data) {
            entries = arr
        }
    }
}

// MARK: - Palette shared with your app
extension Color {
    static let beyondCream = Color(red: 255/255, green: 250/255, blue: 238/255)
    static let beyondChip  = Color(red: 248/255, green: 238/255, blue: 210/255)
    static let deckBlue    = Color(red: 207/255, green: 214/255, blue: 237/255)
}

extension Array where Element == ConfidenceEntry {
    /// Values for drawing (delta only)
    var deltas: [Double] { map(\.delta) }
}
