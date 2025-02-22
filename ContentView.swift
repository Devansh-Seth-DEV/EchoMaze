import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var canBeginLaunchAnimation
    = false
    @State private var navigateToLevels = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if navigateToLevels {
                    LevelsView()
                        .transition(.opacity)
                } else {
                    Image("LandingTheme")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                    VStack {
                        Text("Echo Maze")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .padding(.top, 120)
                            .shadow(color: Color.cyan.opacity(1), radius: 10)
                            .opacity(canBeginLaunchAnimation
                                     ? 1 : 0)
                            .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation
                            )
                        
                        
                        Text("The Path Unseen")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.cyan.opacity(0.5), radius: 5)
                            .opacity(canBeginLaunchAnimation
                                     ? 1 : 0)
                            .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation
                            )
                        
                        Text("No visuals. No sound. Only touch.\nThe closer you get, the stronger you feel.\nCan you escape the unseen?")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                            .opacity(canBeginLaunchAnimation
                                     ? 1 : 0)
                            .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation
                            )
                        
                        Text("Tap anywhere to start")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 100)
                            .opacity(canBeginLaunchAnimation ? 1 : 0)
                            .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation)
                    }
                }
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                withAnimation(.easeIn(duration: 0.3)) {
                    navigateToLevels = true
                }
            }
        }
        .onAppear {
            canBeginLaunchAnimation = true
        }
    }
    
    func startGame() {
        print("Game started")
    }
}
