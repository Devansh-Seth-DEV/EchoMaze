import SwiftUI


struct LevelsView: View {
    @State private var path = NavigationPath()
    @AppStorage("unlockedLevel") private var unlockedLevel = 1
    @State private var selectedLevel: Int? = nil
    @State private var navigateToGame = false
    
    private let MAX_LEVELS = 9
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]


    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()
                ZStack {
                    Image("LandingTheme")
                        .resizable()
                        .ignoresSafeArea(.all)
                        .scaledToFill()
                    
                    VStack {
                        Text("Find Your Way Forward")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.top, 100)
                        
                        Text("Trapped in a maze of silence, you are **Echo**. Walls block your way, but the **Echo Point** whispers through vibrations.")
                            .padding(.horizontal, 20)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: Color.white.opacity(1), radius: 10)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .center)

                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(1...MAX_LEVELS, id: \.self) { level in
                                Button(action: {
                                    if level <= unlockedLevel {
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
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.77)))
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
                        if level <= levels.count {
                            GameView(
                                path: $path,
                                unlockedLevel: $unlockedLevel,
                                currentLevel: level,
                                maze: levels[level - 1].0,
                                goalPosition: levels[level - 1].1,
                                fakeGoalPosition: levels[level - 1].2
                            )
                        }
                    }
                }
            }
        }
    }
}
