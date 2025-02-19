//
//  GameView.swift
//  EchoMaze
//
//  Created by Devansh Seth on 20/02/25.
//

import SwiftUI

struct GameView: View {
    @Binding var unlockedLevel: Int
    let currentLevel: Int 
    let maze: [[Bool]] // Injected maze layout
    let goalPosition: (row: Int, col: Int) // Injected goal
    @State private var playerPosition = (row: 0, col: 0) // Start position
    @Environment(\.presentationMode) var presentationMode // To go back

    var body: some View {
        ZStack {
            Image("LandingTheme")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            VStack {

                // 5x5 Grid
                GridView(maze: maze, playerPosition: playerPosition, goalPosition: goalPosition)
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                
                // Arrow Controls
                VStack {
                    Button(action: { movePlayer(direction: .up) }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.mint)
                    }
                    
                    HStack {
                        Button(action: { movePlayer(direction: .left) }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.mint)
                        }
                        
                        Spacer()
                        
                        Button(action: { movePlayer(direction: .right) }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.mint)
                        }
                    }
                    .frame(width: 200)
                    
                    Button(action: { movePlayer(direction: .down) }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.mint)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    enum Direction {
        case up, down, left, right
    }


    // 🏃 Moves the player
    func movePlayer(direction: Direction) {
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

        if canMove(to: (newRow, newCol)) {
            playerPosition = (newRow, newCol)
            triggerHapticFeedback() // Call vibration feedback
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
            print("🎉 You reached the goal!")
        }
    }
    
    func triggerHapticFeedback() {
        let distance = abs(playerPosition.0 - goalPosition.0) + abs(playerPosition.1 - goalPosition.1) // Manhattan Distance
        
        let generator = UIImpactFeedbackGenerator(style: getHapticStyle(for: distance))
        generator.impactOccurred()
    }

    // **Determine Haptic Intensity**
    func getHapticStyle(for distance: Int) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch distance {
        case 0, 1:
            return .heavy // 🔥 Strongest (Goal Reached)
        case 2...3:
            return .medium // 🟡 Close
        case 4...5:
            return .light // 🟢 Somewhat Close
        default:
            return .soft // 🌀 Far Away
        }
    }

    // Checks if movement is possible
    private func canMove(to newPosition: (row: Int, col: Int)) -> Bool {
        let (row, col) = newPosition
        return row >= 0 && row < maze.count && col >= 0 && col < maze[0].count && maze[row][col]
    }
}


struct GridView: View {
    let maze: [[Bool]]
    let playerPosition: (row: Int, col: Int)
    let goalPosition: (row: Int, col: Int)
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<maze.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<maze[row].count, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(playerPosition == (row, col) ? Color.mint : Color.clear)
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
