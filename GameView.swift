import SwiftUI
import CoreHaptics

struct GameView: View {
    @Binding var path: NavigationPath
    @Binding var unlockedLevel: Int
    @Binding var storedEchoCharges: String
    
    let currentLevel: Int
    let maze: [[Bool]]
    let goalPosition: (row: Int, col: Int)
    let fakeGoalPosition: (row: Int, col: Int)

    private let BASE_POINT: Int = 1000
    private let EFFICIENCY_POINT: Int = 500
    private let FAKE_ECHO_INTRO_LEVEL: Int = FAKE_ECHO_STARTING_LEVEL
    private var WALL_HIT_PENALTY: Int = 1000
    
    private var movesLeftString: String {
        return currentLevel == 1 ? "\u{221E}" : "\(movesLeft)"
    }
    
    private var gameOverDescriptionText: Text {
        return currentScore <= 0 ? Text("You ran out of **Echo Charge**") : Text("You ran out of **Moves**")
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
    
    private var levelCompleteDescriptionText: Text {
        if starCount == 3 {
            return Text("That was a fantastic win.\nYou really brought your **A-game**!")
        } else if starCount == 2 {
            return Text("Nice job on the win!\nThat was impressive!")
        } else {
            return Text("Great job! You did it!")
        }
    }

    @State private var playerPosition = (row: 0, col: 0)
    @State private var movesLeft: Int = 0
    @State private var totalMoves: Int = 0
    @State private var showGameOver = false
    @State private var showLevelComplete = false
    @State private var showTooltip: Bool = false
    @State private var MIN_MOVES_TO_GIVE: Int = 15
    @State private var hapticEngine: CHHapticEngine?
    @State private var playerHitWall: Bool = false
    @State private var level1Counter: Int? = nil

    @State private var canShowQuickGuideTipOnLevel1: Bool? = false
    @State private var canShowEchoPointTipOnLevel1: Bool? = false
    @State private var canShowEchoPointFindTipOnLevel1: Bool? = false
    @State private var canShowWallHitTipOnLevel1: Bool? = false
    @State private var canShowMovesLeftTipOnLevel1: Bool? = false
    @State private var canShowFakeEchoPointTipOnLevel7: Bool? = false
    @State private var canShowFakeEchoPointSpotTipOnLevel7: Bool? = false
    @State private var popupOpacity = 0.0
    @State private var tipIsShowing: Bool = false
    @State private var canDissapearTip: Bool = false
    @State private var DISSAPEAR_TIP_DELAY: Double = 1.0

    @State private var minimumMovesRequired: Int = 0
    @State private var totalTargetScore: Int = 1
    @State private var starImage: [String] = Array<String>(repeating: "star.fill", count: 3)
    @State private var starGlowRadius: [CGFloat] = Array<CGFloat>(repeating: 0, count: 3)
    
    @State private var currentScore: Int = 300 {
        didSet {
            if currentScore > totalTargetScore {
                currentScore = totalTargetScore
            }
        }}

    
    init(path: Binding<NavigationPath>,
         unlockedLevel: Binding<Int>,
         storedEchoCharges: Binding<String>,
         currentLevel: Int,
         maze: [[Bool]],
         goalPosition: (row: Int, col: Int),
         fakeGoalPosition: (row: Int, col: Int)) {
        self._path = path
        self._unlockedLevel = unlockedLevel
        self._storedEchoCharges = storedEchoCharges
        self.currentLevel = currentLevel
        self.maze = maze
        self.goalPosition = goalPosition
        self.fakeGoalPosition = fakeGoalPosition
        

        let minMovesToGive = max(15, maze.count*3)
        self._MIN_MOVES_TO_GIVE = .init(initialValue: minMovesToGive)
        
        self._minimumMovesRequired = .init(initialValue:
                                            abs(playerPosition.0 - goalPosition.0) +
                                           abs(playerPosition.1 - goalPosition.1))
        
        self._totalTargetScore = .init(
            initialValue: BASE_POINT + (currentLevel * EFFICIENCY_POINT * self.MIN_MOVES_TO_GIVE)
        )
        
        self._totalMoves = .init(initialValue: minMovesToGive)
        self._movesLeft = .init(initialValue: minMovesToGive)
        self._currentScore = .init(initialValue: totalTargetScore)
        
        self._level1Counter = .init(initialValue: currentLevel != 1 ? nil : minMovesToGive)
        
        WALL_HIT_PENALTY = BASE_POINT * currentLevel
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
                    hideTip()
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
                //MARK: Progress Visuals
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
                                    .shadow(color: Color.white.opacity(1),
                                            radius: starGlowRadius[index])
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
                                        
                                        Text(movesLeftString)
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .shadow(color: Color.white.opacity(1), radius: 10)
                                            .shadow(color: Color.white.opacity(1), radius: 10)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .frame(maxWidth: .infinity,
                                           maxHeight: .infinity,
                                           alignment: .top)
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
                                    .frame(maxWidth: .infinity,
                                           maxHeight: .infinity,
                                           alignment: .center)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 380, alignment: .center)
                }
                .cornerRadius(16)
                .padding(.bottom, 60)

                //MARK: Maze Initialisation
                GridView(maze: maze,
                         playerPosition: playerPosition,
                         goalPosition: goalPosition,
                         playerHitWall: playerHitWall,
                         starCount: starCount)
                    .padding(.bottom, 20)
                
                //MARK: Arrow Controlls
                VStack {
                    Button(action: {movePlayer(direction: .up) }) {
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
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
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
                        .opacity(popupOpacity)
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .top)
                .padding(.top, 140)
                .background(Color.clear)
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
                        .opacity(popupOpacity)
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
                .background(Color.clear)
                .onTapGesture {
                    hideTip()
                }
            } else if canShowEchoPointFindTipOnLevel1 ?? false {
                VStack {
                    Text("**TUTORIAL**\n\nTo open the gate for the next level, You'll have to deactivate the **Echo Point** by hitting it using the **Arrow Keys**.\n\nTip: Not all walls are truly walls, one of them is the hidden Echo Point.")
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
                        .opacity(popupOpacity)
                        .onTapGesture {
                            hideTip()
                        }
                    
                    Text("Tap anywhere to continue.")
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .background(Color.clear)
                .onTapGesture {
                    hideTip()
                }
            } else if canShowWallHitTipOnLevel1 ?? false {
                VStack {
                    Text("Beware of the **Echoing Blockades** (Wall) it'll reflect back the echo which can reduce your **Echo Charge**.\n\n**Echo Charge** are required to deactivate the **Echo Point**")
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
                        .opacity(popupOpacity)
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .background(Color.clear)
                .onTapGesture {
                    hideTip()
                }
            } else if canShowMovesLeftTipOnLevel1 ?? false {
                VStack {
                    Text("**Every move counts**. Use them wisely to uncover the hidden escape before you run out.\nFor this tutorial you have **\u{221E} moves**.")
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
                        .opacity(popupOpacity)
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .top)
                .background(Color.clear)
                .onTapGesture {
                    hideTip()
                }
            } else if canShowFakeEchoPointTipOnLevel7 ?? false {
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
                        .opacity(popupOpacity)
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .background(Color.clear)
                .onTapGesture {
                    hideTip()
                }
            } else if canShowFakeEchoPointSpotTipOnLevel7 ?? false {
                VStack {
                    Text("To **Spot** them, feel double vibrations, they whisper the echo twice when they're one block ahead of you.")
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
                        .opacity(popupOpacity)
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
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
                .background(Color.clear)
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
                        
                        gameOverDescriptionText
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.bottom, 50)
                        
                        Image(systemName: "arrow.clockwise")
                            .padding(.top, 50)
                            .padding(.bottom, 40)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .shadow(color: Color.mint, radius: 10)
                            .foregroundColor(.white)

                            .onTapGesture {
                                resetGame()
                            }
                    }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center)
            } else if showLevelComplete {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: starImage[index])
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        starCount > index ? Color.mint : .white
                                    )
                                    .shadow(color: Color.mint.opacity(1), radius: 2)
                                    .shadow(color: Color.white.opacity(1), radius: starGlowRadius[index])
                                    .padding(.bottom, index == 1 ? 30 : 0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)
                        
                        Text("\(currentScore)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.bottom, 30)
                        
                        Text("Congratulations")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding()
                        
                        levelCompleteDescriptionText
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.bottom, 20)
                        
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
                        
                        if starCount < 3 {
                            Image(systemName: "arrow.clockwise")
                                .padding(.top, 50)
                                .padding(.bottom, 40)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .shadow(color: Color.mint, radius: 10)
                                .foregroundColor(.white)
                                .onTapGesture { resetGame() }
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
                        .shadow(color: Color.mint.opacity(1), radius: 10)
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
            if CHHapticEngine.capabilitiesForHardware()
                .supportsHaptics {
                do {
                    hapticEngine = try CHHapticEngine()
                    try hapticEngine?.start()
                } catch {
                    print("Haptics Engine Error: \(error.localizedDescription)")
                }
            }
            
            if currentLevel == 1 && canShowQuickGuideTipOnLevel1 != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    canShowEchoPointFindTipOnLevel1 = true
                    showTip()
                }
            } else if currentLevel == FAKE_ECHO_INTRO_LEVEL && canShowFakeEchoPointTipOnLevel7 != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    canShowFakeEchoPointTipOnLevel7 = true
                    showTip()
                }
            }
        }
    }
    
    private func showTip() {
        if !tipIsShowing {
            tipIsShowing = true
            popupOpacity = 0.0
            withAnimation(.easeIn(duration: 0.5)) { popupOpacity = 1.0 }
        }
    }
    
    
    private func hideTip() {
        if tipIsShowing && canDissapearTip {
            withAnimation(.easeOut(duration: 0.5)) { popupOpacity = 0.0 }
            
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
                } else if canShowFakeEchoPointTipOnLevel7 ?? false {
                    canShowFakeEchoPointTipOnLevel7 = nil
                } else if canShowFakeEchoPointSpotTipOnLevel7 ?? false {
                    canShowFakeEchoPointSpotTipOnLevel7 = nil
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
        currentScore = totalTargetScore
        updateStarStatus()
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

    func calculateCurrentScore(_ takeWallPenalty: Bool) -> Int {
        if playerPosition == goalPosition { return currentScore }
        let extraMoves = max(0, totalMoves - movesLeft - minimumMovesRequired - 1)
        let penalty = max(100, (totalTargetScore - BASE_POINT) / (totalMoves - minimumMovesRequired))
        var currentScore = max(0, totalTargetScore - (extraMoves * penalty))
        if takeWallPenalty {
            currentScore = max(0, currentScore - WALL_HIT_PENALTY)
        }
        
        currentScore = min(self.currentScore, currentScore)
        
        return currentScore
    }


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
            triggerHapticFeedback()
        } else {
            playerHitWall = true
            currentScore = max(0, currentScore-WALL_HIT_PENALTY)
            if currentLevel == 1 && canShowWallHitTipOnLevel1 != nil {
                canShowWallHitTipOnLevel1 = true
                showTip()
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        
        if !playerHitWall {
            movesLeft = max(0, movesLeft-1)
        }
        
        if currentLevel == 1 {
            if movesLeft == totalMoves-1 && canShowMovesLeftTipOnLevel1 != nil {
                canShowMovesLeftTipOnLevel1 = true
                showTip()
            }
            
            if canShowMovesLeftTipOnLevel1 == nil {
                level1Counter = max(0, level1Counter!-1)
                movesLeft = totalMoves
                
                if level1Counter! == 4 {
                    canShowQuickGuideTipOnLevel1 = true
                    showTip()
                }
            }
        }
        
        currentScore = calculateCurrentScore(playerHitWall)
        updateStarStatus()
        if playerHitWall {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                playerHitWall = false
            }
        }

        
        if movesLeft == 0 && playerPosition != goalPosition || currentScore == 0 {
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
            
            var echoCharges: [EchoChargeScore] = getEchoCharges()
            if echoCharges.count == 0 {
                echoCharges.append(EchoChargeScore(chargeScore: 0, starCount: 0))
                updateEchoCharges(echoCharges)
            }
            
            if currentScore > echoCharges[currentLevel-1].chargeScore {
                echoCharges[currentLevel-1] = .init(chargeScore: currentScore, starCount: starCount)
                updateEchoCharges(echoCharges)
            }

            if unlockedLevel == currentLevel {
                unlockedLevel += 1
                echoCharges.append(.init(chargeScore: 0, starCount: 0))
                updateEchoCharges(echoCharges)
            }
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

        if intensityValue >= 0.4 &&
            currentLevel == 1 &&
            canShowEchoPointTipOnLevel1 != nil {
            canShowEchoPointTipOnLevel1 = true
            showTip()
        } else if intensityValue >= 0.3 &&
                    currentLevel == FAKE_ECHO_INTRO_LEVEL &&
                    distance <= 2 &&
                    canShowFakeEchoPointSpotTipOnLevel7 != nil {
            canShowFakeEchoPointSpotTipOnLevel7 = true
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

    private func canMove(to newPosition: (row: Int, col: Int)) -> Bool {
        guard movesLeft > 0 else { return false }
        let (row, col) = newPosition
        return row >= 0 && row < maze.count && col >= 0 && col < maze[0].count && maze[row][col]
    }
    
    func getEchoCharges() -> [EchoChargeScore] {
        if let data = storedEchoCharges.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([EchoChargeScore].self, from: data) {
            return decoded
        }
        return []
    }
    
    func updateEchoCharges(_ charges: [EchoChargeScore]) {
        if let encoded = try? JSONEncoder().encode(charges),
           let jsonString = String(data: encoded, encoding: .utf8) {
            storedEchoCharges = jsonString
        }
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
