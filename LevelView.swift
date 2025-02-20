//
//  LevelViews.swift
//  EchoMaze
//
//  Created by Devansh Seth on 20/02/25.
//
import SwiftUI

struct LevelsView: View {
    @AppStorage("unlockedLevel") private var unlockedLevel = 1 // Persist unlocked levels
    @State private var selectedLevel: Int? = nil  // Store tapped level
    @State private var navigateToGame = false  // Controls navigation
    
    private let MAX_LEVELS = 9
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 2 columns

    let levels: [([[Bool]], (row: Int, col: Int))] = [
        ([
            [true,  true,  false, true,  true ],
            [false, true,  false, true,  false],
            [true,  true,  true,  true,  true ],
            [false, true,  false, true,  false],
            [true,  false, true,  true,  true ]
        ], (4, 4)),  // Level 1 (5x5 grid, goal at bottom-right)
        
        ([
            [true,  false, true,  true,  true ],
            [true,  true,  false, false, true ],
            [false, true,  true,  true,  true ],
            [true,  false, false, true,  false],
            [true,  true,  true,  true,  true ]
        ], (0, 4)),  // Level 2
        // Add more levels here
    ]

    var body: some View {
        NavigationStack {
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
                        
                        Text("You wake up in complete darkness. No sight. No sound. Only the faint pulse of the unknown.\nThe walls are invisible, but you can feel them.\nThe exit is hidden, but your instincts will guide you.")
                            .padding(.horizontal, 5)
                            .font(.body)
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
                                        navigateToGame = true
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
                    .navigationDestination(isPresented: $navigateToGame) {
                        if let selectedLevel = selectedLevel, selectedLevel <= levels.count {
                            GameView(
                                unlockedLevel: $unlockedLevel,
                                currentLevel: selectedLevel,
                                maze: levels[selectedLevel - 1].0,
                                goalPosition: levels[selectedLevel - 1].1
                            )
                        }
                    }
                }
            }
        }
    }
}
