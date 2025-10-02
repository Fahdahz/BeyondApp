//
//  ContentView.swift
//  BeyondApp
//
//  Created by Fahdah Alsamari on 07/04/1447 AH.
//

import SwiftUI
import UIKit

// MARK: - Model
struct ChallengeItem: Identifiable, Equatable {
    let id = UUID()
    let front: String
    let back: String
}

// MARK: - View
struct ContentView: View {
    // ---- Settings you can tweak ----
    private let cardSize   = CGSize(width: 300, height: 450)
    private let cardCorner: CGFloat = 26
    private let iconFrontName = "cardSparkle"
    private let iconBackName  = "cardSparkle"

    private let maxShuffles = 3   // daily allowance

    // --------------------------------
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false

    @State private var shufflesUsed: Int = 0
    @State private var showCongrats: Bool = false
    @State private var showNoShuffles: Bool = false
    @State private var showOneLeft: Bool = false

    @State private var cardSwapID = UUID()
    @State private var deckShift = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    private var bgColors: [Color] {
        isDarkMode
        ? [.black.opacity(0.92), .black.opacity(0.75)]
        : [Color(red: 1.0, green: 0.5843, blue: 0.0, opacity: 0.18),   // orange 18%
           Color(red: 1.0, green: 0.4118, blue: 0.7059, opacity: 0.12)] // pink 12%
    }

    // Your challenges
    private let challenges: [ChallengeItem] = [
        .init(
            front: "Compliment someone!",
            back:  "Opportunity you might miss: sparking a warm chat, lifting someone’s day, and opening the door to future conversations."
        ),
        .init(
            front: "Ask someone for a small recommendation (a book, food, or a place).",
            back:  "Opportunity you might miss: discovering new interests and finding common ground to keep the conversation going."
        ),
        .init(
            front: "Volunteer for 1–2 hours at a community event!",
            back:  "Opportunity you might miss: meeting caring people, feeling useful, and growing confidence through shared purpose."
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: bgColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                // Banner + dark mode toggle
                ZStack {
                    Image("bannerRibbon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 420, height: 540)
                        .clipped()
                        .padding(.top, 25)

                    Text("TRY TODAY'S\nCHALLENGE")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.top,47)
                        .dynamicTypeSize(.xSmall)
                        .foregroundColor(.brown)
                        .opacity(1)
                }
                .frame(height: 120)
                .padding(.top, 2)
                .overlay(alignment: .topLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title3)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 2, y: 1)
                            .accessibilityLabel(isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode")
                    }
                    .padding(.leading, 37)
                    .padding(.top, -29)
                }

                // Deck look
                ZStack {
                    // ghost cards
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(red: 207/255, green: 214/255, blue: 237/255))
                        .frame(width: cardSize.width, height: cardSize.height)
                        .rotationEffect(.degrees(deckShift ? -10 : -6))
                        .offset(x: deckShift ? -14 : -8, y: deckShift ? 16 : 12)
                        .scaleEffect(deckShift ? 0.98 : 1.0)
                        .shadow(radius: 4, y: 3)
                        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: deckShift)

                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(red: 207/255, green: 214/255, blue: 237/255))
                        .frame(width: cardSize.width, height: cardSize.height)
                        .rotationEffect(.degrees(deckShift ? 8 : 6))
                        .offset(x: deckShift ? 16 : 10, y: deckShift ? 22 : 18)
                        .scaleEffect(deckShift ? 0.98 : 1.0)
                        .shadow(radius: 4, y: 3)
                        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: deckShift)

                    // MAIN card
                    FlipCard(
                        front: AnyView(CardFront(text: challenges[currentIndex].front, imageName: iconFrontName)),
                        back:  AnyView(CardBack(text: challenges[currentIndex].back,  imageName: iconBackName)),
                        isFlipped: isFlipped,
                        size: cardSize
                    )
                    .onTapGesture { withAnimation(.spring()) { isFlipped.toggle() } }
                    .id(cardSwapID)
                    .transition(.asymmetric(
                        insertion: .fromDeck.combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: cardSwapID)
                    .zIndex(1)
                }

                // Buttons Row (Shuffle shows remaining)
                HStack(spacing: 16) {
                    SoftButton(title: "DID IT!", systemImage: "checkmark.seal.fill") {
                        showCongrats = true
                    }

                    ShuffleButton(remaining: max(0, maxShuffles - shufflesUsed)) {
                        shuffle()
                    }
                }
                .padding(.top, 32)

                Spacer()
            }
            .padding()

            // Congrats popup
            if showCongrats {
                Popup(
                    icon: "trophy.fill",
                    title: "CONGRATULATIONS!",
                    messge: "Well done, you did it!\nKeep up the good work!",
                    onClose: {
                        withAnimation(.easeInOut) { showCongrats = false }
                    }
                )
                .transition(.opacity)
                .zIndex(10)
            }


            // All used popup
            if showNoShuffles {
                PopupSuffle(
                    icon: "shuffle",
                    title: "ALL SHUFFLES USED!",
                    messge: "You used all the available shuffles.\nTry this challenge!",
                    onClose: {
                        withAnimation(.easeInOut) { showNoShuffles = false }
                    }
                )
                .transition(.opacity)
                .zIndex(12)
            }
        }
    }

    // MARK: - Actions
    private func shuffle() {
        // If already at 0 remaining, block and show final popup
        guard shufflesUsed < maxShuffles else {
            withAnimation(.easeInOut) { showNoShuffles = true }
            return
        }

        // move to next card (sequential)
        let newIndex = (currentIndex + 1) % challenges.count
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            isFlipped = false
            currentIndex = newIndex
            cardSwapID = UUID()
            deckShift.toggle()
        }

        // increment usage & notify
        shufflesUsed += 1
        let remaining = maxShuffles - shufflesUsed

        // Optional: show "one left" popup when remaining == 1
        if remaining == 1 {
            withAnimation(.easeInOut) { showOneLeft = true }
        }

        // Show "all used" popup immediately when you reach 0 remaining
        if remaining == 0 {
            withAnimation(.easeInOut) { showNoShuffles = true }
        }
        // Note: Shuffle button is disabled at 0; guard above also covers extra taps if you remove the disabled state.
    }
}

// MARK: - Buttons
struct SoftButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.headline)
            .foregroundColor(.brown)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color(red: 248/255, green: 238/255, blue: 210/255))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct ShuffleButton: View {
    let remaining: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "shuffle")
                Text("SHUFFLE")
                Text("x\(remaining)").font(.headline.monospacedDigit())
            }
            .font(.headline)
            .foregroundColor(.brown.opacity(remaining == 0 ? 0.4 : 1.0))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 248/255, green: 238/255, blue: 210/255))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(remaining == 0 ? Color.red.opacity(0.2) : Color.clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(remaining == 0)
        .accessibilityLabel("Shuffle, \(remaining) left")
    }
}

// MARK: - Flip Card (no mirrored text)
struct FlipCard: View {
    let front: AnyView
    let back: AnyView
    let isFlipped: Bool
    let size: CGSize

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 255/255, green: 250/255, blue: 238/255))
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.12), radius: 10, y: 8)
                .overlay(
                    ZStack {
                        front
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        back
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: isFlipped)
                )
        }
    }
}

// MARK: - Card Faces
struct CardFront: View {
    let text: String
    let imageName: String
    var body: some View {
        VStack(spacing: 14) {
            AssetImage(name: imageName, fallbackSystem: "text.bubble")
                .font(.largeTitle)
                .frame(height: 32)
                .padding(.top, 6)

            Text(text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct CardBack: View {
    let text: String
    let imageName: String
    var body: some View {
        VStack(spacing: 12) {
            AssetImage(name: imageName, fallbackSystem: "sparkles")
                .font(.largeTitle)
                .frame(height: 32)
                .padding(.top, 6)

            Text("If you skip, you might miss:")
                .font(.subheadline.bold())

            Text(text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Congrats Sheet (kept for reference; unused)
struct CongratsSheet: View {
    let imageName: String
    var body: some View {
        VStack(spacing: 16) {
            AssetImage(name: imageName, fallbackSystem: "trophy.fill")
                .font(.system(size: 54))
                .frame(height: 54)

            Text("Congratulations!")
                .font(.title2.bold())
            Text("Well done—you did it! Keep going ✨")
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper to use your Assets with a fallback SF Symbol
struct AssetImage: View {
    let name: String
    let fallbackSystem: String
    var body: some View {
        if UIImage(named: name) != nil {
            Image(name).resizable().scaledToFit()
        } else {
            Image(systemName: fallbackSystem).resizable().scaledToFit()
        }
    }
}

struct Banner: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.title3.bold())
            .multilineTextAlignment(.center)
            .padding(.vertical, 6)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.35))
                    .shadow(radius: 2, y: 1)
            )
    }
}

// MARK: - Custom transition: appear from the deck
private struct DeckFromModifier: ViewModifier {
    let offset: CGSize
    let rotation: Angle
    let scale: CGFloat
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .offset(offset)
    }
}

private extension AnyTransition {
    static var fromDeck: AnyTransition {
        let active = DeckFromModifier(
            offset: CGSize(width: 10, height: 18),
            rotation: .degrees(6),
            scale: 0.96
        )
        let identity = DeckFromModifier(
            offset: .zero,
            rotation: .degrees(0),
            scale: 1.0
        )
        return .modifier(active: active, identity: identity)
    }
}

#Preview {
    ContentView()
}
