//
//  ConfidenceCheckInPopup.swift
//  BeyondApp
//
//  Created by Fahdah Alsamari on 11/04/1447 AH.
//

import SwiftUI

/// A compact modal styled like your trophy popup (no emoji).
/// `onSkip` and `onSave` both advance to Congrats in ContentView.
struct ConfidenceCheckInPopup: View {
    let isDarkMode: Bool
    let onSkip: () -> Void
    let onSave: (_ before: Int, _ after: Int) -> Void
    let onClose: () -> Void

    @State private var before: Double = 2
    @State private var after: Double  = 3

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            // Card
            VStack(spacing: 0) {
                // Header (lavender like your other popup)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(red: 207/255, green: 214/255, blue: 237/255))
                    .frame(height: 56)
                    .overlay(
                        HStack {
                            Text("How confident are you?")
                                .font(.headline)
                                .foregroundStyle(.black.opacity(0.9))
                            //Spacer()
//                            Button(action: onClose) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.title3)
//                                    .foregroundStyle(.white.opacity(0.95))
//                                    .shadow(radius: 1)
//                            }
                            .accessibilityLabel("Close")
                            
                        }
                        .padding(.horizontal, 16)
                    )
                    .clipShape(RoundedCorner(radius: 14, corners: [.topLeft, .topRight])) // uses the one in Popup.swift
                

                // Body (cream like your popup)
                VStack(spacing: 14) {
                    Text("Quick before/after confidence check  to track your progress!! 👀")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black.opacity(0.7))
                        .padding(.horizontal)

                    Meter(title: "Before", value: $before)
                    Meter(title: "After",  value: $after)

                    HStack(spacing: 14) {
                        ActionPill(title: "Skip", isPrimary: false) {
                            onSkip()
                        }
                        ActionPill(title: "Save", isPrimary: true) {
                            onSave(Int(before), Int(after))
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(16)
                .background(
                    RoundedCorner(radius: 14, corners: [.bottomLeft, .bottomRight])
                        .fill(Color(red: 255/255, green: 250/255, blue: 238/255))
                )
            }
            .frame(width: 330)
            .shadow(color: .black.opacity(0.18), radius: 12, y: 10)
        }
    }

    // MARK: - Subviews

    struct Meter: View {
        let title: String
        @Binding var value: Double
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                    Spacer()
                    Text("\(Int(value))/5")
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.6))
                }
                Slider(value: $value, in: 0...5, step: 1).tint(.blue)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.65))
                    .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
            )
        }
    }

    struct ActionPill: View {
        let title: String
        var isPrimary: Bool
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.brown.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 248/255, green: 238/255, blue: 210/255))
                    )
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ConfidenceCheckInPopup(
        isDarkMode: false,
        onSkip: {},
        onSave: { _, _ in },
        onClose: {}
    )
}

