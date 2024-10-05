import SwiftUI

// Card Model
struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
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
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3)
                    Text(card.content)
                        .font(.largeTitle)
                } else {
                    // Face-down card
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                }
            }
            .frame(width: 80, height: 130)        }
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
        VStack {
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
        }
        .onAppear {
            startNewGame() // Initialize the game on load
        }
    }

    // MARK: - Game Logic

    func handleCardTap(at index: Int) {
        if !cards[index].isFaceUp && !cards[index].isMatched {  // Only proceed if the card is facedown and not matched
            if let previousIndex = indexOfSelectedCard, previousIndex != index {
                // A card is already selected, check for a match
                cards[index].isFaceUp = true // Flip the current card face-up
                if cards[previousIndex].content == cards[index].content {
                    // Cards match
                    cards[previousIndex].isMatched = true
                    cards[index].isMatched = true
                } else {
                    // No match, flip both cards back down after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        cards[previousIndex].isFaceUp = false
                        cards[index].isFaceUp = false
                    }
                }
                indexOfSelectedCard = nil // Reset the selected card
            } else {
                // No cards or only one card is selected, flip the current card
                indexOfSelectedCard = index
                cards[index].isFaceUp = true
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
