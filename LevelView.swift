//
//  LevelViews.swift
//  EchoMaze
//
//  Created by Devansh Seth on 20/02/25.
//
import SwiftUI


struct LevelsView: View {
    @State private var path = NavigationPath()  // Tracks navigation state
    @AppStorage("unlockedLevel") private var unlockedLevel = 1 // Persist unlocked levels
    @State private var selectedLevel: Int? = nil  // Store tapped level
    @State private var navigateToGame = false  // Controls navigation
    
    private let MAX_LEVELS = 9
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 2 columns


    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()
                ZStack {
                    Image("LandingTheme")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                    VStack {
                        Text("Find Your Way Forward")
                            .padding(.bottom, 10)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.white.opacity(0.8), radius: 10)
                            .padding(.top, 50)
                        
                        Text("No sight. No sound. Only the faint pulse of the unknown. Somewhere hidden within this maze, an exit exists but it won’t reveal itself easily.")
                            .padding(.horizontal, 10)
                            .font(.body)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: Color.white.opacity(1), radius: 10)
                            .padding(.bottom, 20)

                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(1...MAX_LEVELS, id: \.self) { level in
                                Button(action: {
                                    if level <= unlockedLevel { // Only navigate if unlocked
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        selectedLevel = level
                                        path.append(level)
                                    }
                                }) {
                                    Text("\(level)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(level <= unlockedLevel ? .mint : .gray)
                                        .frame(width:  100, height: 100)
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.black))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(level <= unlockedLevel ? Color.mint : Color.gray, lineWidth: 3)
                                        )
                                        .shadow(color: level <= unlockedLevel ? Color.mint.opacity(0.8) : Color.clear, radius: 5)
                                }
                                .disabled(level > unlockedLevel)
                            }
                        }
                        .padding()
                    }
                    .navigationDestination(for: Int.self) { level in
                        GameView(
                            path: $path,
                            unlockedLevel: $unlockedLevel,
                            currentLevel: level,
                            maze: levels[level - 1].0,
                            goalPosition: levels[level - 1].1
                        )
                    }
                }
            }
        }
    }
}
