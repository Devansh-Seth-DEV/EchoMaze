import SwiftUI
import CoreHaptics

struct GameView: View {
    @Binding var path: NavigationPath
    @Binding var unlockedLevel: Int
    let currentLevel: Int
    let maze: [[Bool]] // Injected maze layout
    let goalPosition: (row: Int, col: Int) // Injected goal
    let fakeGoalPosition: (row: Int, col: Int) // Injected fake goal
    @State private var playerPosition = (row: 0, col: 0) // Start position
    @State private var movesLeft: Int = -999
    @State private var showGameOver = false
    @State private var showLevelComplete = false
    @State private var showTooltip: Bool = false
    @State private var MIN_MOVES: Int = 15
    @State private var hapticEngine: CHHapticEngine?
    @State private var playerHitWall: Bool = false
    @State private var canShowQuickGuideTipOnLevel1: Bool? = false
    @State private var canShowEchoPointTipOnLevel1: Bool? = false
    @State private var canShowEchoPointFindTipOnLevel1: Bool? = false
    @State private var canShowWallHitTipOnLevel1: Bool? = false
    @State private var canShowMovesLeftTipOnLevel1: Bool? = false
    @State private var canShowFakeEchoPointTipOnLevel6: Bool? = false
    @State private var canShowFakeEchoPointSpotTipOnLevel6: Bool? = false
    @State private var popupOpacity = 0.0
    @State private var tipIsShowing: Bool = false
    @State private var canDissapearTip: Bool = false
    @State private var DISSAPEAR_TIP_DELAY: Double = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image("LandingTheme")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            VStack {
                HStack {
                    let movesLeftText = canShowMovesLeftTipOnLevel1 == nil ? "\u{221E}" : "\(movesLeft)"
                    Text("Moves: \(movesLeftText)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(1), radius: 10)
                        .padding(.leading, 10) // Offset from trailing edge
                        .frame(maxWidth: 200, alignment: .leading)

                    
                    Button(action: {
                        hideTip()
                        showTooltip = true
                    }) {
                        Image(systemName: "lightbulb.min")
                            .resizable()
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .shadow(color: Color.white.opacity(1), radius: 10)
                            .frame(width: 30, height: 35)
                        
                    }
                    .padding(.leading, 70)
                }
                
                //MARK: Maze Init
                GridView(maze: maze, playerPosition: playerPosition, goalPosition: goalPosition, playerHitWall: playerHitWall)
                    .padding(.bottom, 10)
                
                //MARK: Arrow Controlls
                VStack {
                    Button(action: { movePlayer(direction: .up) }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(playerPosition.row == 0 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == 0 || tipIsShowing)
                    
                    HStack {
                        Button(action: { movePlayer(direction: .left) }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(playerPosition.col == 0 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == 0 || tipIsShowing)
                        
                        Spacer()
                        
                        Button(action: { movePlayer(direction: .right) }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(playerPosition.col == maze[0].count - 1 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == maze[0].count - 1 || tipIsShowing)
                    }
                    .frame(width: 200)
                    
                    Button(action: { movePlayer(direction: .down) }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(playerPosition.row == maze.count - 1 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == maze.count - 1 || tipIsShowing)
                }
                .padding(.bottom, 20)
            }
            
            if showTooltip {
                ZStack {
                    Color.black.opacity(0.9).ignoresSafeArea()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Quick Guide")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.mint)
                                .frame(width: 45, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text("This is **Echo**, Move it to find the escape.")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .shadow(color: Color.mint.opacity(1), radius: 10)
                                .frame(maxWidth: 300, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                        HStack(alignment: .center, spacing: 10) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.3))
                                .frame(width: 45, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text("This is **Echoing Blockade** The **Echo** reflects back, signaling a blocked path.")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .shadow(color: Color.mint.opacity(1), radius: 10)
                                .frame(maxWidth: 300, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        HStack(alignment: .center, spacing: 10) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.clear)
                                .frame(width: 45, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text("This is an **Open Path** You can move freely here.")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .shadow(color: Color.mint.opacity(1), radius: 10)
                                .frame(maxWidth: 300, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        HStack(alignment: .center, spacing: 10) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.3))
                                .frame(width: 45, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text("This is **Echo Point** It looks like **Echoing Blockade** but it's an unseen path calling the **Echo**.")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .shadow(color: Color.mint.opacity(1), radius: 10)
                                .frame(maxWidth: 300, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
//                        Text("The **Echo Point** wispers the strong echo as you get closer to it, listen the echo (vibrations).\nDon't get tricked by **Fake Echo Point** trying to mislead you. It wispers the echo twice when infront of you.")
//                            .font(.headline)
//                            .foregroundColor(.mint)
//                            .multilineTextAlignment(.leading)
//                            .shadow(color: Color.mint.opacity(1), radius: 10)
//                            .padding(.horizontal, 40)
                        
                        Text("Find the hidden **Echo Point** to escape")
                            .font(.headline)
                            .foregroundColor(.mint)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.horizontal, 40)
                        
                        Button(action: { showTooltip = false }) {
                            Text("Got It!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 140)
                                .background(Color.mint)
                                .cornerRadius(12)
                                .padding(.top, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            
            if canShowQuickGuideTipOnLevel1 ?? false {
                VStack {
                    Text("Need help? Tap the **bulb** icon on top to get a Quick Guide.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 140)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowEchoPointTipOnLevel1 ?? false {
                VStack {
                    Text("Feel the phone vibrations. The closer you get to the **Echo Point**, the louder the vibrations will be.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowEchoPointFindTipOnLevel1 ?? false {
                VStack {
                    Text("You'll have to find and hit the hidden **Echo Point** to escape!. Not all walls are truly walls, one of them is the hidden Echo Point.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                    
                    Text("Tap anywhere to continue.")
//                        .padding()
                        .font(.body)
                        .foregroundColor(Color.white)
                        .shadow(color: Color.mint, radius: 5)
                        .opacity(popupOpacity)
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowWallHitTipOnLevel1 ?? false {
                VStack {
                    Text("Beware of the **Echoing Blockades** (Wall) it'll reflect back the echo, signalling a blocked path.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowMovesLeftTipOnLevel1 ?? false {
                VStack {
                    Text("**Every move counts**. Use them wisely to uncover the hidden escape before you run out.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .padding(.top, 120)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowFakeEchoPointTipOnLevel6 ?? false {
                VStack {
                    Text("Don't be tricked by **Fake Echo Point** they try to mislead you.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            } else if canShowFakeEchoPointSpotTipOnLevel6 ?? false {
                VStack {
                    Text("To **Spot** them, listen carefully on vibrations they whisper the echo twice when they're one block ahead of you.")
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.mint, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mint, lineWidth: 1)
                                .shadow(color: Color.mint, radius: 10)
                        )
                        .opacity(popupOpacity) // Apply opacity for fade-in
                        .onTapGesture {
                            hideTip()
                        }
                }
                .frame(width: 350)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                        canDissapearTip = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.clear) // Dim background
                .onTapGesture {
                    hideTip()
                }
            }
            
            if showGameOver {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
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
            } else if showLevelComplete {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    VStack {
                        Text("Congratulations")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding()
                        
                        Text("You reached the **Echo Point**")
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
                        
                        if currentLevel != levels.count {
                            Button(action: navigateToNextLevel) {
                                Text("Next")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 140)
                                    .background(Color.mint)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    path.removeLast(path.count) // Always go back to LevelsView
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.mint)
                        .shadow(color: Color.mint.opacity(1), radius: 10)
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.mint)
                        .shadow(color: Color.white.opacity(1), radius: 10)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear() {
            resetGame()
        }
        .onTapGesture {
            hideTip()
        }
        .onAppear() {
            MIN_MOVES = maze.count * 3
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
            
            if currentLevel == 1 && canShowQuickGuideTipOnLevel1 != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    canShowEchoPointFindTipOnLevel1 = true
                    showTip()
                }
            } else if currentLevel == 6 && canShowFakeEchoPointTipOnLevel6 != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    canShowFakeEchoPointTipOnLevel6 = true
                    showTip()
                }
            }
        }
    }
    
    private func showTip() {
        if !tipIsShowing {
            tipIsShowing = true
            popupOpacity = 0.0
            withAnimation(.easeIn(duration: 0.5)) {
                popupOpacity = 1.0 // Fade in
            }
        }
    }
    
    
    private func hideTip() {
        if tipIsShowing && canDissapearTip {
            withAnimation(.easeOut(duration: 0.5)) {
                popupOpacity = 0.0
            }
            
            DispatchQueue.main.async {
                tipIsShowing = false
                canDissapearTip = false
                if canShowQuickGuideTipOnLevel1 ?? false {
                    canShowQuickGuideTipOnLevel1 = nil
                } else if canShowEchoPointTipOnLevel1 ?? false {
                    canShowEchoPointTipOnLevel1 = nil
                } else if canShowEchoPointFindTipOnLevel1 ?? false {
                    canShowEchoPointFindTipOnLevel1 = nil
                } else if canShowWallHitTipOnLevel1 ?? false {
                    canShowWallHitTipOnLevel1 = nil
                } else if canShowMovesLeftTipOnLevel1 ?? false {
                    canShowMovesLeftTipOnLevel1 = nil
                } else if canShowFakeEchoPointTipOnLevel6 ?? false {
                    canShowFakeEchoPointTipOnLevel6 = nil
                } else if canShowFakeEchoPointSpotTipOnLevel6 ?? false {
                    canShowFakeEchoPointSpotTipOnLevel6 = nil
                }
            }
        }
    }
    
    func navigateToNextLevel() {
        let nextLevel = currentLevel + 1
        path.append(nextLevel)
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
        guard !showLevelComplete, !tipIsShowing else { return }
        
        let (row, col) = playerPosition
        var newRow = row
        var newCol = col
        
        switch direction {
        case .up where row > 0: newRow -= 1
        case .down where row < maze.count: newRow += 1
        case .left where col > 0: newCol -= 1
        case .right where col < maze[row].count: newCol += 1
        default: break
        }
        
        if (newRow, newCol) == playerPosition { return } 
        
        if canMove(to: (newRow, newCol)) {
            playerPosition = (newRow, newCol)
            triggerHapticFeedback() // Call vibration feedback
        } else {
            playerHitWall = true
            if currentLevel == 1 && canShowWallHitTipOnLevel1 != nil {
                canShowWallHitTipOnLevel1 = true
                showTip()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                playerHitWall = false
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        
        movesLeft = max(0, movesLeft-1)
        if canShowMovesLeftTipOnLevel1 == nil {
            movesLeft = MIN_MOVES
        }
        
        if currentLevel == 1 {
            if movesLeft == MIN_MOVES-2 && canShowMovesLeftTipOnLevel1 != nil {
                canShowMovesLeftTipOnLevel1 = true
                showTip()
            } else if movesLeft == 4 && canShowQuickGuideTipOnLevel1 != nil {
                canShowQuickGuideTipOnLevel1 = true
                showTip()
            }
        }
        
        
        if movesLeft == 0 && playerPosition != goalPosition {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                showGameOver = true
            }
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
        let goalDistance = dx + dy // Manhattan Distance
        
        let fakeGoalDistance: Int
        if fakeGoalPosition.0 != -1 && fakeGoalPosition.1 != -1 {
            let dfx = abs(playerPosition.0 - fakeGoalPosition.0)
            let dfy = abs(playerPosition.1 - fakeGoalPosition.1)
            fakeGoalDistance = dfx + dfy
        } else {
            fakeGoalDistance = goalDistance+1
        }
        
        let distance = min(goalDistance, fakeGoalDistance)
        
        // Normalize intensity (closer = stronger)
        let maxDistance = Double(maze.count)
        let intensityValue = max(0.1, 1.0 - (Double(distance) / maxDistance))
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensityValue*2))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)

        if intensityValue >= 0.4 && currentLevel == 1 && canShowEchoPointTipOnLevel1 != nil {
            canShowEchoPointTipOnLevel1 = true
            showTip()
        } else if intensityValue >= 0.6 && currentLevel == 6 && distance == fakeGoalDistance && canShowFakeEchoPointSpotTipOnLevel6 != nil {
            canShowFakeEchoPointSpotTipOnLevel6 = true
            showTip()
        }
        
        do {
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [
                                        intensity,
                                        sharpness
                                      ],
                                      relativeTime: 0,
                                      duration: 15.0
            )
            var events = [event]
            if distance == fakeGoalDistance && fakeGoalPosition.0 != -1 && fakeGoalPosition.1 != -1 &&
                distance <= 1
            {
                events.removeAll()
                for i in 0..<2 {
                    events.append(
                        CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [
                                        intensity,
                                        sharpness
                                      ],
                                      relativeTime: Double(i)*0.1,
                                      duration: 1.0
                                     ))
                }
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
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
    let playerHitWall: Bool
    private let interMazeSpacing: CGFloat = 10
    @State var cellSize: CGFloat = 0
    
    func getCellColor(_ row: Int, _ col: Int) -> Color {
        let color: Color
        if playerPosition == (row, col) {
            color = playerHitWall ? Color.red.opacity(0.4) : Color.mint
        } else if goalPosition == (row, col) ||
                    !maze[row][col] {
            color = Color.white.opacity(0.5)
        } else {
            color = Color.clear
        }
        return color
    }
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(0..<maze.count, id: \.self) { row in
                HStack(alignment: .center) {
                    ForEach(0..<maze[row].count, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(getCellColor(row, col))
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .onAppear() {
            let sizeOffset = max(maze.count, maze[0].count)
            cellSize = CGFloat(80 - (sizeOffset * 5))
        }
    }
}
