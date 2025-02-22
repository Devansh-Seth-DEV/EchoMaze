import SwiftUI
import CoreHaptics

struct GameView: View {
    @Binding var path: NavigationPath
    @Binding var unlockedLevel: Int
    let currentLevel: Int
    let maze: [[Bool]]
    let goalPosition: (row: Int, col: Int)
    let fakeGoalPosition: (row: Int, col: Int)
    private let BASE_POINT: Int = 1000
    private let EFFICIENCY_POINT: Int = 500
    
    @State private var playerPosition = (row: 0, col: 0)
    
    @State private var movesLeft: Int = 0
    @State private var totalMoves: Int = 0
    @State private var showGameOver = false
    @State private var showLevelComplete = false
    @State private var showTooltip: Bool = false
    @State private var MIN_MOVES_TO_GIVE: Int = 15
    @State private var hapticEngine: CHHapticEngine?
    @State private var playerHitWall: Bool = false
    @State private var minimumMovesRequired: Int = 0
    @State private var totalTargetScore: Int = 1
    @State private var starImage: [String] = Array<String>(repeating: "star.fill", count: 3)
    @State private var starGlowRadius: [CGFloat] = Array<CGFloat>(repeating: 0, count: 3)
    
    @State private var currentScore: Int = 300 {
        didSet {
            if currentScore > totalTargetScore {
                currentScore = totalTargetScore
            }
            
            
        }
    }
    
    init(path: Binding<NavigationPath>, unlockedLevel: Binding<Int>, currentLevel: Int, maze: [[Bool]], goalPosition: (row: Int, col: Int), fakeGoalPosition: (row: Int, col: Int)) {
        self._path = path
        self._unlockedLevel = unlockedLevel
        self.currentLevel = currentLevel
        self.maze = maze
        self.goalPosition = goalPosition
        self.fakeGoalPosition = fakeGoalPosition
       
        let minMovesToGive = max(15, maze.count*3)
        self._MIN_MOVES_TO_GIVE = .init(initialValue: minMovesToGive)
        
        self._minimumMovesRequired = .init(initialValue: abs(playerPosition.0 - goalPosition.0) + abs(playerPosition.1 - goalPosition.1))
        
        self._totalTargetScore = .init(
            initialValue: BASE_POINT + (currentLevel * EFFICIENCY_POINT * self.MIN_MOVES_TO_GIVE)
        )
        
        self._totalMoves = .init(initialValue: minMovesToGive)
        self._movesLeft = .init(initialValue: minMovesToGive)
        self._currentScore = .init(initialValue: calculateCurrentScore())
    }
    
    private var starCount: Int {
        let percentage = Double(currentScore) / Double(totalTargetScore)
        if percentage >= 0.75 {
            return 3
        } else if percentage >= 0.50 {
            return 2
        } else if percentage >= 0.25 {
            return 1
        } else {
            return 0
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image("LandingTheme")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            VStack {
                //MARK: GUIDE BULB
                Button(action: {
                    showTooltip = true
                }) {
                    Image(systemName: "lightbulb.min")
                        .resizable()
                        .foregroundColor(.mint)
                        .shadow(color: Color.white.opacity(1), radius: 5)
                        .frame(width: 30, height: 35)
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 40)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mint.opacity(0.7), lineWidth: 1)
                        .background(Color.black.opacity(0.3))
                        .frame(width: 380, height: 80)
                        .shadow(color: Color.mint.opacity(1), radius: 10)
                        .padding(.horizontal, 20)
                    
                    
                    HStack(alignment: .center, spacing: 10) {
                        ZStack {
                            HStack {
                                ForEach(0..<3, id: \.self) { index in
                                    Image(systemName: starImage[index])
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        starCount > index ? Color.mint : .white
                                    )
                                    .shadow(color: Color.mint.opacity(1), radius: 2)
                                    .shadow(color: Color.white.opacity(1), radius: starGlowRadius[index])
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.mint.opacity(1), lineWidth: 1)
                                .background(Color.black.opacity(0.3))
                                .frame(width: 100, height: 90)
                                .shadow(color: Color.mint.opacity(1), radius: 10)
                                .overlay {
                                    VStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.mint.opacity(1), lineWidth: 1)
                                            .frame( width: 90, height: 30)
                                            .background(Color.mint.opacity(0.1))
                                            .cornerRadius(12)
                                            .shadow(color: Color.mint.opacity(1), radius: 5)
                                            .shadow(color: Color.white.opacity(1), radius: 5)
                                            .overlay {
                                                Text("\(currentLevel)")
                                                    .font(.body)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.white.opacity(0.9))
                                                    .shadow(color: Color.mint.opacity(1), radius: 10)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                        
                                        Text("\(movesLeft)")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .shadow(color: Color.white.opacity(1), radius: 10)
                                            .shadow(color: Color.white.opacity(1), radius: 10)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                }
                        }
                        .cornerRadius(28)
                        .frame(maxWidth: 380, alignment: .center)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.mint.opacity(1), lineWidth: 1)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(16)
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .overlay {
                                    VStack(spacing: 5) {
                                        Text("Echo Charge")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .shadow(color: Color.mint.opacity(1), radius: 5)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        Text("\(currentScore)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .shadow(color: Color.white.opacity(1), radius: 10)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 380, alignment: .center)
                }
                .cornerRadius(16)
                .padding(.bottom, 60)

                //MARK: Maze Init
                GridView(maze: maze, playerPosition: playerPosition, goalPosition: goalPosition, playerHitWall: playerHitWall, starCount: starCount)
                    .padding(.bottom, 20)
                
                //MARK: Arrow Controlls
                VStack {
                    Button(action: { movePlayer(direction: .up) }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(playerPosition.row == 0 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == 0)
                    
                    HStack {
                        Button(action: { movePlayer(direction: .left) }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(playerPosition.col == 0 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == 0)
                        
                        Spacer()
                        
                        Button(action: { movePlayer(direction: .right) }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(playerPosition.col == maze[0].count - 1 ? .gray : .mint)
                        }
                        .disabled(playerPosition.col == maze[0].count - 1)
                    }
                    .frame(width: 200)
                    
                    Button(action: { movePlayer(direction: .down) }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(playerPosition.row == maze.count - 1 ? .gray : .mint)
                    }
                    .disabled(playerPosition.row == maze.count - 1)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            if showTooltip {
                ZStack {
                    Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
                    
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
                        
                        Text("The **Echo Point** wispers the strong echo as you get closer to it, listen the echo (vibrations).\nDon't get tricked by **Fake Echo Point** trying to mislead you. It wispers the echo twice when infront of you.")
                            .font(.headline)
                            .foregroundColor(.mint)
                            .multilineTextAlignment(.leading)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.horizontal, 40)
                        
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if showLevelComplete {
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("Congratulations")
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
                    path.removeLast(path.count)
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
        .onAppear() {
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
    
    func navigateToNextLevel() {
        let nextLevel = currentLevel + 1
        path.append(nextLevel)
    }
    
    func resetGame() {
        playerPosition = (0, 0)
        movesLeft = abs(goalPosition.0) + abs(goalPosition.1)
        movesLeft = max(movesLeft<<1, MIN_MOVES_TO_GIVE)
        showGameOver = false
        showLevelComplete = false
    }


    enum Direction {
        case up, down, left, right
    }
    
    func updateStarStatus() {
        for i in 0..<3 {
            if i > starCount-1 {
                withAnimation(.easeInOut) {
                    starImage[i] = "star"
                    starGlowRadius[i] = 0
                }
            }
            else {
                withAnimation(.easeInOut) {
                    starImage[i] = "star.fill"
                    starGlowRadius[i] = 2
                }
            }
        }
    }

    func calculateCurrentScore() -> Int {
        let extraMoves = max(0, totalMoves - movesLeft - minimumMovesRequired)
        let penalty = max(100, (totalTargetScore - BASE_POINT) / (totalMoves - minimumMovesRequired))
        let currentScore = max(0, totalTargetScore - (extraMoves * penalty))
        return currentScore
    }


    func movePlayer(direction: Direction) {
        guard !showLevelComplete else { return }
        currentScore += 50
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
            triggerHapticFeedback()
        } else {
            playerHitWall = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                playerHitWall = false
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        
        movesLeft = max(0, movesLeft-1)
        currentScore = calculateCurrentScore()
        updateStarStatus()
        
        if movesLeft == 0 && playerPosition != goalPosition {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                showGameOver = true
            }
        }

        
      
        if playerPosition == goalPosition {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generator.notificationOccurred(.success)
            }
            showLevelComplete = true
            unlockedLevel += unlockedLevel == currentLevel ? 1 : 0
        }
    }
    
    func triggerHapticFeedback() {
        guard let engine = hapticEngine else { return }

        let dx = abs(playerPosition.0 - goalPosition.0)
        let dy = abs(playerPosition.1 - goalPosition.1)
        let goalDistance = dx + dy
        
        let fakeGoalDistance: Int
        if fakeGoalPosition.0 != -1 && fakeGoalPosition.1 != -1 {
            let dfx = abs(playerPosition.0 - fakeGoalPosition.0)
            let dfy = abs(playerPosition.1 - fakeGoalPosition.1)
            fakeGoalDistance = dfx + dfy
        } else {
            fakeGoalDistance = goalDistance+1
        }
        
        let distance = min(goalDistance, fakeGoalDistance)
        
        let maxDistance = Double(maze.count)
        let intensityValue = max(0.1, 1.0 - (Double(distance) / maxDistance))
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensityValue*2))
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
    let starCount: Int
    private let interMazeSpacing: CGFloat = 10
    private let MAX_GRID_SIZE: CGFloat = 300
    @State var cellSize: CGFloat = 0
    
    func getCellColor(_ row: Int, _ col: Int) -> Color {
        let color: Color
        if playerPosition == (row, col) {
            color = playerHitWall ? Color.red.opacity(0.4) : Color.mint
        } else if goalPosition == (row, col) ||
                    !maze[row][col] {
            color = Color.white.opacity(0.3)
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
        .frame(maxWidth: MAX_GRID_SIZE, maxHeight: MAX_GRID_SIZE, alignment: .center)
        .onAppear() {
            let sizeOffset = max(maze.count, maze[0].count)
            cellSize = CGFloat(80 - (sizeOffset * 5))
        }
    }
}
