import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var canBeginLaunchAnimation
    = false
    @State private var navigateToLevels = false
    @State private var navigateToTutorial = false
    @AppStorage("showTutorial") private var showTutorial: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("LandingTheme")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                VStack {
                    Text("Echo Maze")
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.mint)
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
                        .padding(.top, 40)
                        .opacity(canBeginLaunchAnimation
                                 ? 1 : 0)
                        .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation
                        )
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .center)
                
                Text("Tap anywhere to start")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(canBeginLaunchAnimation ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: canBeginLaunchAnimation)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 40)
                
                if navigateToLevels {
                    LevelsView()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 1), value: navigateToLevels)
                } else if navigateToTutorial {
                    GameTutorialView(showTutorial: $showTutorial)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 1), value: navigateToTutorial)
                }
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                withAnimation(.easeIn(duration: 0.5)) {
                    if !showTutorial {
                        navigateToLevels = true
                    } else {
                        navigateToTutorial = true
                    }
                }
            }
            .onAppear {
                canBeginLaunchAnimation = true
            }
        }

    }
}
