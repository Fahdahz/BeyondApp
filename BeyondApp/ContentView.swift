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

enum ChallengeCategory { case indoor, outdoor }

// MARK: - View
struct ContentView: View {
    // ---- Settings you can tweak ----
    private let cardSize   = CGSize(width: 300, height: 450)
    private let iconFrontName = "cardSparkle"
    private let iconBackName  = "cardSparkle"
    private let maxShuffles = 3   // daily allowance

    // --------------------------------
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false

    @AppStorage("shufflesUsed") private var shufflesUsed: Int = 0
    @State private var showCongrats: Bool = false
    @State private var showNoShuffles: Bool = false
    @State private var showCheckIn: Bool = false        // ← confidence popup gate

    @State private var cardSwapID = UUID()
    @State private var deckShift = false

    // Confetti control
    @State private var showConfetti: Bool = false

    // Category/deck state
    @State private var currentCategory: ChallengeCategory = .indoor
    @State private var deck: [ChallengeItem] = ChallengeDeck.indoor   // start on Indoor

    // Confidence store shared with Progress page
    @StateObject private var confidence = ConfidenceStore()

    // TESTING: reset allowance every minute (store last reset as timestamp)
    @AppStorage("lastShuffleResetTS") private var lastShuffleResetTS: Double = 0
    private let testResetInterval: TimeInterval = 60 // 1 minute

    @Environment(\.scenePhase) private var scenePhase
    @State private var resetTicker: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.5843, blue: 0.0, opacity: 0.18),
                        Color(red: 1.0, green: 0.4118, blue: 0.7059, opacity: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    // Banner + progress button
                    ZStack {
                        Image("bannerRibbon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 420, height: 540)
                            .clipped()
                            .padding(.top, 25)

                        Text("TAP TODAY'S\nCHALLENGE")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .padding(.top,47)
                            .dynamicTypeSize(.xSmall)
                            .foregroundColor(.brown)
                            .opacity(1)
                    }
                    .frame(height: 120)
                    .padding(.top, 2)
                    .overlay(alignment: .topTrailing) {
                        // 🔗 Go to your real ProgressPage
                        NavigationLink {
                            ProgressPage(store: confidence)   // <<<<<<<<<<
                                .environmentObject(confidence)
                        } label: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title3)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(radius: 2, y: 1)
                        }
                        .padding(.trailing, 31)
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
                            front: AnyView(CardFront(text: deck[currentIndex].front, imageName: iconFrontName)),
                            back:  AnyView(CardBack(text: deck[currentIndex].back,  imageName: iconBackName)),
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
                            // show the confidence check-in first
                            showCheckIn = true
                        }

                        ShuffleButton(remaining: max(0, maxShuffles - shufflesUsed)) {
                            shuffle()
                        }
                    }
                    .padding(.top, 32)

                    Spacer()
                }
                .padding()
                .onAppear {
                    initializeResetTimestampIfNeeded()
                    checkAndResetShufflesIfNeeded()
                    startResetTickerIfNeeded()
                }
                .onDisappear {
                    stopResetTicker()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        checkAndResetShufflesIfNeeded()
                        startResetTickerIfNeeded()
                    } else {
                        stopResetTicker()
                    }
                }
                .onChange(of: showCongrats) { _, newValue in
                    // Trigger a short confetti burst whenever congrats appears
                    if newValue {
                        showConfetti = true
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(3))
                            showConfetti = false
                        }
                    }
                }

                // Confetti overlay (behind popups)
                if showConfetti {
                    ConfettiView(isActive: showConfetti, duration: 2.0)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(9) // keep it behind popups
                }

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

                // Confidence check-in popup (your separate file)
                if showCheckIn {
                    ConfidenceCheckInPopup(
                        isDarkMode: false,
                        onSkip: {
                            // skip saving, but still show congrats
                            showCheckIn = false
                            withAnimation(.easeInOut) { showCongrats = true }
                        },
                        onSave: { before, after in
                            // Save to the SAME store used by ProgressPage
                            confidence.add(before: before, after: after)
                            showCheckIn = false
                            withAnimation(.easeInOut) { showCongrats = true }
                        },
                        onClose: {
                            showCheckIn = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(11)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Testing reset (every minute)
    private func initializeResetTimestampIfNeeded() {
        if lastShuffleResetTS == 0 {
            lastShuffleResetTS = Date().timeIntervalSince1970
        }
    }

    private func startResetTickerIfNeeded() {
        guard resetTicker == nil else { return }
        resetTicker = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5)) // check every 5 seconds
                checkAndResetShufflesIfNeeded()
            }
        }
    }

    private func stopResetTicker() {
        resetTicker?.cancel()
        resetTicker = nil
    }

    private func checkAndResetShufflesIfNeeded() {
        let now = Date().timeIntervalSince1970
        if now - lastShuffleResetTS >= testResetInterval {
            shufflesUsed = 0
            lastShuffleResetTS = now
            showNoShuffles = false
        }
    }

    // MARK: - Actions
    /// Alternates Indoor ↔ Outdoor each tap, then shows a different random card in that category.
    private func shuffle() {
        // Ensure reset if interval passed while app stayed open
        checkAndResetShufflesIfNeeded()

        // If already at 0 remaining, block and show final popup
        guard shufflesUsed < maxShuffles else {
            withAnimation(.easeInOut) { showNoShuffles = true }
            return
        }

        // 1) Alternate the category
        currentCategory = (currentCategory == .indoor) ? .outdoor : .indoor
        deck = (currentCategory == .indoor) ? ChallengeDeck.indoor : ChallengeDeck.outdoor

        // 2) Choose a new index (try not to repeat the same card)
        let newIndex = deck.nextRandomIndex(excluding: currentIndex)

        // 3) Animate the swap
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            isFlipped = false
            currentIndex = newIndex
            cardSwapID = UUID()
            deckShift.toggle()
        }

        // 4) Count & notify
        shufflesUsed += 1
        let remaining = maxShuffles - shufflesUsed

        if remaining == 0 {
            withAnimation(.easeInOut) { showNoShuffles = true }
        }
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

// MARK: - Utility
extension Array where Element == ChallengeItem {
    /// Returns a random valid index different from `current` when possible.
    func nextRandomIndex(excluding current: Int?) -> Int {
        guard !isEmpty else { return 0 }
        if count == 1 { return 0 }
        var i: Int
        repeat { i = Int.random(in: 0..<count) } while i == current
        return i
    }
}

// MARK: - Decks (10 indoor + 10 outdoor) from your sheets
enum ChallengeDeck {
    static let indoor: [ChallengeItem] = [
        .init(front: "Compliment a family member or a friend on something they did (cooking, outfit, effort)!",
              back:  "You might miss spreading positivity that strengthens bonds."),
        .init(front: "Join a family meal, even if just for a short time!",
              back:  "You might miss enjoying shared food and conversation that builds closeness."),
        .init(front: "Invite an acquaintance for coffee or a walk!",
              back:  "You might miss turning an acquaintance into a real friend."),
        .init(front: "Send a voice note instead of texting!",
              back:  "You might miss letting them hear your tone and warmth, which builds stronger connections."),
        .init(front: "Schedule a 5–10 minute video call with family or friends!",
              back:  "You might miss seeing their expressions and deepening emotional connection."),
        .init(front: "Send a short text to a family member or friend!",
              back:  "You might miss reminding someone that you care and keeping the bond alive."),
        .init(front: "Send a meme, funny video, or song link to someone!",
              back:  "You might miss making someone smile and starting a lighthearted chat."),
        .init(front: "Share one small detail about your day with a family member or a friend!",
              back:  "You might miss opening the door for longer conversations."),
        .init(front: "Write an email or long message updating a friend about your week!",
              back:  "You might miss reconnecting more deeply and being on their mind."),
        .init(front: "Share a photo of something in your daily life with a family member or a friend!",
              back:  "You might miss sparking a conversation over something simple and relatable.")
    ]

    static let outdoor: [ChallengeItem] = [
        .init(front: "Join a local class (yoga, art, cooking) or a gym!",
              back:  "You might miss learning a new skill and meeting people who share your interests."),
        .init(front: "Apply for an in-person course!",
              back:  "You might miss a career step or a doorway to new friends."),
        .init(front: "Start a short conversation with someone in line!",
              back:  "You might miss a surprising connection or a moment of shared laughter."),
        .init(front: "Compliment a passer-by!",
              back:  "You might miss sparking a warm chat and opening the door to future conversations."),
        .init(front: "Attend a local event and introduce yourself to at least 3 people!",
              back:  "You might miss expanding your circle with people who could bring joy or opportunity."),
        .init(front: "Sit in a public place (café, park) for 5–10 minutes without your phone!",
              back:  "You might miss noticing how normal it feels to simply “be” around others."),
        .init(front: "Volunteer for 1–2 hours at a community event!",
              back:  "You might miss feeling helpful and meeting kind, like-minded people."),
        .init(front: "Order something new from a café!",
              back:  "You might miss discovering your new favorite drink."),
        .init(front: "Hold the door open for someone!",
              back:  "You might miss a simple positive exchange that boosts mood and confidence."),
        .init(front: "Ask someone for a small recommendation (a book, food, or a place)!",
              back:  "You might miss discovering new interests and finding common ground to keep the conversation going.")
    ]
}

#Preview {
    ContentView()
}

// MARK: - Confetti (UIKit CAEmitterLayer wrapped for SwiftUI)
private struct ConfettiView: UIViewRepresentable {
    var isActive: Bool
    var duration: TimeInterval = 2.0

    func makeUIView(context: Context) -> ConfettiEmitterView {
        let v = ConfettiEmitterView()
        v.isUserInteractionEnabled = false
        return v
    }

    func updateUIView(_ uiView: ConfettiEmitterView, context: Context) {
        if isActive {
            uiView.start(duration: duration)
        } else {
            uiView.stop()
        }
    }
}

private final class ConfettiEmitterView: UIView {
    override class var layerClass: AnyClass { CAEmitterLayer.self }

    private var hasConfigured = false

    private var emitterLayer: CAEmitterLayer? { layer as? CAEmitterLayer }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let emitter = emitterLayer else { return }
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.size.width, height: 2)
    }

    func start(duration: TimeInterval) {
        guard let emitter = emitterLayer else { return }

        if !hasConfigured {
            emitter.emitterCells = makeConfettiCells()
            hasConfigured = true
        }

        emitter.birthRate = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stop()
        }
    }

    func stop() {
        guard let emitter = emitterLayer else { return }
        emitter.birthRate = 0.0
        // Let existing particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak emitter] in
            emitter?.emitterCells = nil
        }
        hasConfigured = false
    }

    private func makeConfettiCells() -> [CAEmitterCell] {
        // Softer pastel palette
        let colors: [UIColor] = [
            UIColor(red: 1.00, green: 0.85, blue: 0.78, alpha: 1.0), // pastel peach
            UIColor(red: 1.00, green: 0.80, blue: 0.86, alpha: 1.0), // pastel pink
            UIColor(red: 0.75, green: 0.90, blue: 1.00, alpha: 1.0), // baby blue
            UIColor(red: 0.80, green: 0.95, blue: 0.80, alpha: 1.0), // mint green
            UIColor(red: 1.00, green: 0.94, blue: 0.75, alpha: 1.0), // pale yellow
            UIColor(red: 0.90, green: 0.80, blue: 1.00, alpha: 1.0)  // lavender
        ]

        let shapes: [ConfettiShape] = [.rectangle, .circle, .triangle]

        return colors.flatMap { color in
            shapes.map { shape -> CAEmitterCell in
                let cell = CAEmitterCell()
                cell.contents = makeImage(shape: shape, color: color, size: CGSize(width: 8, height: 8))?.cgImage
                // Fewer, smaller, and softer
                cell.birthRate = 4
                cell.lifetime = 5.0
                cell.lifetimeRange = 1.5
                cell.velocity = 120
                cell.velocityRange = 50
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 12
                cell.spin = 1.2
                cell.spinRange = 1.8
                cell.scale = 0.45
                cell.scaleRange = 0.2
                cell.yAcceleration = 90
                cell.xAcceleration = 6
                // Gentle fade out
                cell.alphaRange = 0.2
                cell.alphaSpeed = -0.2
                return cell
            }
        }
    }

    private enum ConfettiShape { case rectangle, circle, triangle }

    private func makeImage(shape: ConfettiShape, color: UIColor, size: CGSize = CGSize(width: 8, height: 8)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            color.setFill()
            switch shape {
            case .rectangle:
                UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
            case .circle:
                UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
            case .triangle:
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.close()
                path.fill()
            }
        }
    }
}
