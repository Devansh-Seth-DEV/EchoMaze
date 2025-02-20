//
//  GameView.swift
//  EchoMaze
//
//  Created by Devansh Seth on 20/02/25.
//

import SwiftUI
import CoreHaptics

struct GameView: View {
    @Binding var unlockedLevel: Int
    let currentLevel: Int 
    let maze: [[Bool]] // Injected maze layout
    let goalPosition: (row: Int, col: Int) // Injected goal
    @State private var playerPosition = (row: 0, col: 0) // Start position
    @Environment(\.presentationMode) var presentationMode // To go back
    @State private var movesLeft: Int = -999
    @State private var showGameOver = false
    @State private var showLevelComplete = false
    private let MIN_MOVES: Int = 12
    @State private var hapticEngine: CHHapticEngine?


    var body: some View {
        ZStack {
            Image("LandingTheme")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            VStack {
                Spacer()
                Text("Moves Left: \(movesLeft)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: Color.mint.opacity(1), radius: 10)

                
                // 5x5 Grid
                GridView(maze: maze, playerPosition: playerPosition, goalPosition: goalPosition)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                Text("Not all walls are what they seem, find the one that leads to freedom. As you get closer to the exit, the pulse grows stronger guiding you toward escape.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.mint.opacity(1), radius: 10)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 10)
                
                // Arrow Controls
                VStack {
                    Button(action: { movePlayer(direction: .up) }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(playerPosition.row == 0 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == 0)
                    
                    HStack {
                        Button(action: { movePlayer(direction: .left) }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(playerPosition.col == 0 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == 0)
                        
                        Spacer()
                        
                        Button(action: { movePlayer(direction: .right) }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(playerPosition.col == maze[0].count - 1 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == maze[0].count - 1)
                    }
                    .frame(width: 200)
                    
                    Button(action: { movePlayer(direction: .down) }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(playerPosition.row == maze.count - 1 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == maze.count - 1)
                }
                .padding(.bottom, 40)
            }
            
            if showGameOver {
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("Game Over")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("You ran out of moves!")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        
                        Button(action: resetGame) {
                            Text("Try Again")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 140)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            if showLevelComplete {
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("Congratulations 🎉")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding()
                        
                        Text("You reached the exit")
                            .font(.title3)
                            .foregroundColor(.white)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.bottom, 20)
                        
                        Button(action: resetGame) {
                            Text("Retry")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 140)
                                .background(Color.mint)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .onDisappear() {
            resetGame()
        }
        .onAppear() {
            if movesLeft == -999 {
                movesLeft = abs(goalPosition.0) + abs(goalPosition.1)
                movesLeft = max(movesLeft<<1, MIN_MOVES)
                
                if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                    do {
                        hapticEngine = try CHHapticEngine()
                        try hapticEngine?.start()
                    } catch {
                        print("Haptics Engine Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func resetGame() {
        playerPosition = (0, 0) // Back to start
        movesLeft = abs(goalPosition.0) + abs(goalPosition.1) // Reset Moves
        movesLeft = max(movesLeft<<1, MIN_MOVES)
        showGameOver = false // Hide pop-up
        showLevelComplete = false
    }


    enum Direction {
        case up, down, left, right
    }


    // 🏃 Moves the player
    func movePlayer(direction: Direction) {
        guard !showLevelComplete else { return }
        
        let (row, col) = playerPosition
        var newRow = row
        var newCol = col
        
        switch direction {
        case .up where row > 0: newRow -= 1
        case .down where row < 4: newRow += 1
        case .left where col > 0: newCol -= 1
        case .right where col < 4: newCol += 1
        default: break
        }
        
        if (newRow, newCol) == playerPosition { return } 
        if canMove(to: (newRow, newCol)) {
            playerPosition = (newRow, newCol)
            movesLeft -= 1
            triggerHapticFeedback() // Call vibration feedback
            
            if movesLeft == 0 && playerPosition != goalPosition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showGameOver = true
                }
            }
        } else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        
        // **Goal Check - Strongest Vibration**
        if playerPosition == goalPosition {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error) // First strong hit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generator.notificationOccurred(.success) // Second strong hit
            }
            showLevelComplete = true
            unlockedLevel += unlockedLevel == currentLevel ? 1 : 0
        }
    }
    
    func triggerHapticFeedback() {
        guard let engine = hapticEngine else { return }

        let dx = abs(playerPosition.0 - goalPosition.0)
        let dy = abs(playerPosition.1 - goalPosition.1)
        let distance = dx + dy // Manhattan Distance

        // Normalize intensity (closer = stronger)
        let maxDistance = Float(maze.count)
        let intensityValue = max(0.2, 1.0 - (Float(distance) / maxDistance))
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityValue*2)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)

        do {
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [
                                        intensity,
                                        sharpness
                                      ],
                                      relativeTime: 0,
                                      duration: 15.0
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Proximity Haptic Error: \(error.localizedDescription)")
        }
    }

    // Checks if movement is possible
    private func canMove(to newPosition: (row: Int, col: Int)) -> Bool {
        guard movesLeft > 0 else { return false }
        let (row, col) = newPosition
        return row >= 0 && row < maze.count && col >= 0 && col < maze[0].count && maze[row][col]
    }
}


struct GridView: View {
    let maze: [[Bool]]
    let playerPosition: (row: Int, col: Int)
    let goalPosition: (row: Int, col: Int)
    
    func getCellColor(_ row: Int, _ col: Int) -> Color {
        let color: Color
        if playerPosition == (row, col) {
            color = Color.mint
        } else if goalPosition == (row, col) ||
                    !maze[row][col] {
            color = Color.white.opacity(0.3)
        } else {
            color = Color.clear
        }
        return color
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<maze.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<maze[row].count, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(getCellColor(row, col))
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}
