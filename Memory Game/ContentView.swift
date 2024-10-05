import SwiftUI

// Card Model
struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var isMatchedAnimation: Bool = false
}

// Card View
struct CardView: View {
    let card: Card
    
    var body: some View {
        if card.isMatched {
            // Placeholder for matched cards, make them invisible
            RoundedRectangle(cornerRadius: 10)
                .opacity(0)
        } else {
            ZStack {
                if card.isFaceUp {
                    // Face-up card
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)) // Apply the gradient
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2) // Adding shadow for depth
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2) // Adding shadow to stroke
                    Text(card.content)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                } else {
                    // Face-down card
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.blue, .teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient for face-down cards
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
                }
            }
            .frame(width: 80, height: 130)
            .rotation3DEffect(.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0)) // Add 3D rotation for the flip
            .animation(.easeInOut(duration: 0.5), value: card.isFaceUp) // Smooth animation for flipping
            .scaleEffect(card.isMatchedAnimation ? 1.3 : 1) // Scale up animation for match
            .opacity(card.isMatchedAnimation ? 0 : 1) // Fade out when matched
            .animation(.easeInOut(duration: 0.8), value: card.isMatchedAnimation)
        }
    }
}

// Main View
struct ContentView: View {
    // State variables for the cards and the game logic
    @State private var cards: [Card] = [] // Store the deck of cards
    @State private var indexOfSelectedCard: Int? = nil

    // Grid layout configuration
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 4x4 grid

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(colors: [.black, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title
                Text("Matching Game!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)) // Apply gradient to text color
                    .padding()
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2) // Keep the shadow for depth

                ScrollView {
                    // Display the grid of cards
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Array(cards.indices), id: \.self) { index in
                            CardView(card: cards[index])
                                .onTapGesture {
                                    handleCardTap(at: index)
                                }
                                .padding(5) // Add padding around each card to give more space
                        }
                    }
                    .padding()
                }
                
                // Reset Game Button
                Button("Reset Game") {
                    resetGame()
                }
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
            }
        }
        .onAppear {
            startNewGame() // Initialize the game on load
        }
    }

    // Game Logic
    func handleCardTap(at index: Int) {
        if !cards[index].isFaceUp && !cards[index].isMatched {  // Only proceed if the card is facedown and not matched
            if let previousIndex = indexOfSelectedCard, previousIndex != index {
                // A card is already selected, check for a match
                withAnimation {
                    cards[index].isFaceUp = true // Flip the current card face-up
                }
                if cards[previousIndex].content == cards[index].content {
                    // Cards match
                    withAnimation {
                        cards[previousIndex].isMatchedAnimation = true // Start match animation
                        cards[index].isMatchedAnimation = true // Start match animation
                    }
                    // After a delay, mark the cards as fully matched
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        cards[previousIndex].isMatched = true
                        cards[index].isMatched = true
                    }
                } else {
                    // No match, flip both cards back down after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            cards[previousIndex].isFaceUp = false
                            cards[index].isFaceUp = false
                        }
                    }
                }
                indexOfSelectedCard = nil // Reset the selected card
            } else {
                // No cards or only one card is selected, flip the current card
                indexOfSelectedCard = index
                withAnimation {
                    cards[index].isFaceUp = true
                }
            }
        }
    }

    func resetGame() {
        startNewGame() // Reset game
    }

    func startNewGame() {
        // Emoji list for the card contents
        let cardContents = ["🐶", "🐱", "🐭", "🐹", "🦊", "🐻", "🐼", "🐨"]
        var deck = cardContents + cardContents // Two of each card for matching
        deck.shuffle() // Shuffle the deck
        
        // Initialize the cards and set them face down
        cards = deck.map { content in
            Card(content: content)
        }
    }
}


#Preview {
    ContentView()
}
