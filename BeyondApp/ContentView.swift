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
    // --- Settings (top of Beyond) ---
    private let cardSize   = CGSize(width: 300, height: 450)   // ← longer/taller
    private let cardCorner: CGFloat = 26
    private let iconFrontName = "cardSparkle"   // put your asset name; SF fallback used if missing
    private let iconBackName  = "cardSparkle"

    // --------------------------------

    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var shufflesUsed: Int = 0
    @State private var showCongrats: Bool = false
    @State private var showNoShuffles: Bool = false
    @State private var cardSwapID = UUID()
    @State private var deckShift = false            // ← drives deck movement
    @AppStorage("isDarkMode") private var isDarkMode = false

    
    private var bgColors: [Color] {
           isDarkMode
           ? [.black.opacity(0.92), .black.opacity(0.75)]
           : [.orange.opacity(0.18), .pink.opacity(0.12)]
       }

    
    
    // Your 3 challenges
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
                Banner(title: "TRY TODAY'S\nCHALLENGE")

                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                
                    .overlay(alignment: .topTrailing) {
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
                        .padding(.top, 5)
                        .padding(.trailing, 190)
                    }


                // Layered background cards for the mockup look
                // Layered background cards for the mockup look
                // Layered background cards for the mockup look
                ZStack {
                    // ghost cards (animated with deckShift)
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

                    // MAIN card (only this animates)
                    FlipCard(
                        front: AnyView(CardFront(text: challenges[currentIndex].front, imageName: iconFrontName)),
                        back:  AnyView(CardBack(text: challenges[currentIndex].back,  imageName: iconBackName)),
                        isFlipped: isFlipped,
                        size: cardSize
                    )
                    .onTapGesture { withAnimation(.spring()) { isFlipped.toggle() } }
                    .id(cardSwapID) // ← animate only the top card by changing this ID
                    .transition(.asymmetric(
                        insertion: .fromDeck.combined(with: .opacity),   // ← appear from deck
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: cardSwapID)
                    .zIndex(1)
                }


                // Buttons
                HStack(spacing: 12) {
                    Button {
                        showCongrats = true
                    } label: {
                        Label("Did it!", systemImage: "checkmark.seal.fill")
                            .padding(.horizontal, 10)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        shuffle()
                    } label: {
                        Label("Shuffle", systemImage: "shuffle")
                            .padding(.horizontal, 10)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 6)

                // Stars (start empty; fill as you shuffle)
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < shufflesUsed ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(i < shufflesUsed ? .yellow : .secondary)
                    }
                }
                .padding(.top, 2)

                Spacer()
            }
            .padding()
        }
        // Congrats pop-up (you can swap the icon with your own asset)
        .sheet(isPresented: $showCongrats) {
            CongratsSheet(imageName: "congratsIcon")  // <-- replace with your asset name
                .presentationDetents([.fraction(0.35)])
        }
        // No-shuffles-left pop-up
        .alert("All shuffles used", isPresented: $showNoShuffles) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You’ve used all 3 shuffles. Try this challenge!")
        }
    }

    // MARK: - Actions
    private func shuffle() {
        guard shufflesUsed < 3 else {
            showNoShuffles = true
            return
        }

        // choose next card: SEQUENTIAL
        let newIndex = (currentIndex + 1) % challenges.count
        // If you prefer random, use your old random logic instead.

        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            isFlipped = false
            currentIndex = newIndex
            cardSwapID = UUID()   // ← forces only the FlipCard to be replaced/animated
            deckShift.toggle()    // ← animate the deck movement too
        }

        shufflesUsed += 1
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
                        // Rotate faces in opposite directions so text is never mirrored
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
                .font(.largeTitle) // affects SF Symbol size; ignored by bitmap images
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

// MARK: - Congrats Sheet
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
        // Try asset first; if not found, show system symbol
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: fallbackSystem)
                .resizable()
                .scaledToFit()
        }
    }
}

struct Banner: View {
    let title: String
    var body: some View {
        // If you add a ribbon PNG called "ribbonBanner" to Assets,
        // replace with Image("ribbonBanner")
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

// MARK: - Custom transition: appear from the deck (matches the back ghost card)
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
    // Matches the second ghost card: rotation + offset; tweak as you like
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
