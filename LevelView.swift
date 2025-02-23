import SwiftUI


struct LevelsView: View {
    @State private var path: NavigationPath = NavigationPath()
    @AppStorage("unlockedLevel") private var unlockedLevel = 1
    @AppStorage("storeEchoCharges") private var storedEchoCharges: String = "[]"
    
    @State private var scrollToLevelFirstTime: Bool? = false
    
    @State private var canShowStartLevel1TutorialTip: Bool? = false {
        didSet {
            if let condition = self.canShowStartLevel1TutorialTip, condition == true {
                showTip()
            }
        }
    }
    
    @State private var popupOpacity = 0.0
    @State private var tipIsShowing: Bool = false
    @State private var canDissapearTip: Bool = false
    @State private var DISSAPEAR_TIP_DELAY: Double = 1.0
    
    let columns = Array<GridItem>(repeating: GridItem(.flexible()), count: 3)

    private var echoChargesCollected: Int {
        var charges: Int = 0
        getEchoCharges().forEach { charges += $0.chargeScore }
        return charges
    }
    
    init() {
        if unlockedLevel == 1 && getEchoCharges().count == 0 {
            let echoCharges = Array<EchoChargeScore>(repeating: .init(chargeScore: 0,
                                                                      starCount: 0),
                                                     count: levels.count)
            updateEchoCharges(echoCharges)
        }
    }
    
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
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.mint.opacity(0.7), lineWidth: 3)
                            .frame(width: 380, height: 100, alignment: .center)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(28)
                            .shadow(color: Color.mint.opacity(1), radius: 10)
                            .padding(.horizontal, 20)
                            .overlay {
                                VStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.mint.opacity(0.7), lineWidth: 1)
                                        .background(Color.mint.opacity(0.2))
                                        .cornerRadius(24)
                                        .frame(width: 370, height: 40, alignment: .top)
                                        .shadow(color: Color.mint.opacity(1), radius: 5)
                                        .padding(.horizontal, 20)
                                        .overlay {
                                            Text("Echo Charges Collected")
                                                .font(.title2)
                                                .foregroundStyle(.white)
                                                .shadow(color: Color.mint, radius: 10)
                                        }
                                    
                                    Text("\(echoChargesCollected)")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                        .shadow(color: Color.mint, radius: 5)
                                        .shadow(color: Color.white, radius: 5)
                                }
                                .cornerRadius(16)
                                .background(Color.clear)
                                .frame(maxHeight: .infinity, alignment: .top)
                            }
                        
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                    ForEach(levels.indices.reversed(), id: \.self) { index in
                                        LevelMapView(level: index+1,
                                                     unlockedLevels: unlockedLevel,
                                                     echoChargeScore: getEchoCharges()[index])
                                            .offset(x: (index).isMultiple(of: 2) ? -80 : 80)
                                            .onTapGesture {
                                                if canShowStartLevel1TutorialTip ?? false {
                                                    hideTip()
                                                }
                                                if index+1 <= unlockedLevel {
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    path.append(index+1)
                                                }
                                            }
                                    }
                                    .padding(.vertical, 40)
                                }
                            }
                            .frame(maxHeight: 700, alignment: .center)
                            .position(x: UIScreen.main.bounds.width/2,
                                      y: UIScreen.main.bounds.height - 520)
                            .background(Color.clear.ignoresSafeArea())
                            .onAppear() {
                                if unlockedLevel == 1 &&
                                    canShowStartLevel1TutorialTip != nil {
                                    canShowStartLevel1TutorialTip = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        proxy.scrollTo(unlockedLevel, anchor: .center)
                                        scrollToLevelFirstTime = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                    

                    
                    if scrollToLevelFirstTime == true &&
                        (canShowStartLevel1TutorialTip ?? false) {
                        VStack(spacing: 30) {
                            Text("**Welcome**\n\n**Level 1** is a great starting point. It’s designed to help you get familiar with the game mechanics. Let’s get started!")
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
                                .animation(.easeInOut(duration: 1), value: tipIsShowing)
                            
                            Text("Tap on the level to start")
                                .font(.body)
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: 350,
                               maxHeight: .infinity,
                               alignment: .center)
                        .padding(.top, 250)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                                canDissapearTip = true
                            }
                        }
                    }
                }
                .navigationDestination(for: Int.self) { level in
                    if level <= levels.count {
                        GameView(
                            path: $path,
                            unlockedLevel: $unlockedLevel,
                            storedEchoCharges: $storedEchoCharges,
                            currentLevel: level,
                            maze: levels[level - 1].0,
                            goalPosition: levels[level - 1].1,
                            fakeGoalPosition: levels[level - 1].2
                        )
                    }
                }
            }
            .onTapGesture {
                hideTip()
            }
            .onAppear() {
                if unlockedLevel == 1 {
                    var echoChargeValue = Array<EchoChargeScore>(repeating: .init(chargeScore: 0,
                                                                                  starCount: 0),
                                                                 count: levels.count)
                    if storedEchoCharges != "[]" {
                        for (index, echoCharge) in getEchoCharges().enumerated() {
                            echoChargeValue[index] = echoCharge
                        }
                    }
                    updateEchoCharges(echoChargeValue)
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
                
                if canShowStartLevel1TutorialTip ?? false {
                    canShowStartLevel1TutorialTip = nil
                }
            }
        }
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


struct EchoChargeScore: Codable {
    var chargeScore: Int
    var starCount: Int
}


struct LevelMapView: View {
    let level: Int
    let unlockedLevels: Int
    let echoChargeScore: EchoChargeScore
    
    @State private var starImage = Array<String>(repeating: "star", count: 3)
    @State private var starGlowRadius = Array<CGFloat>(repeating: 0, count: 3)
    
    
    private var chargeScoreString: String {
        return self.echoChargeScore.chargeScore == 0 ? "" : "\(self.echoChargeScore.chargeScore)"
    }
    
    init(level: Int,
         unlockedLevels: Int,
         echoChargeScore: EchoChargeScore) {
        self.level = level
        self.unlockedLevels = unlockedLevels
        self.echoChargeScore = echoChargeScore
    }
    
    
    var body: some View {
        VStack {
            Text(chargeScoreString)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            HStack(alignment: .center, spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: starImage[index])
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(
                            (echoChargeScore.starCount > index ? Color.mint : .white)
                                .opacity(level < unlockedLevels ? 1 : 0)
                        )
                        .shadow(color: Color.mint.opacity(1), radius: 2)
                        .shadow(color: Color.white.opacity(1), radius: starGlowRadius[index])
                        .padding(.bottom, index == 1 ? 15 : 0)
                }
            }
            .frame(width: 80, height: 30, alignment: .center)
            .background(Color.clear)
            
            
            RoundedRectangle(cornerRadius: 24)
                .fill(level <= unlockedLevels ? Color.mint.opacity(0.6) : Color.black.opacity(0.4))
                .frame(width: 100, height: 60)
                .shadow(color: Color.mint, radius: 5)
                .overlay(
                    Text("\(level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .shadow(color: Color.mint, radius: level <= unlockedLevels ? 10 : 0)
                        .shadow(color: Color.white, radius: level <= unlockedLevels ? 10 : 0)
                )
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear() {
            updateStarStatus()
        }
    }
    
    func updateStarStatus() {
        for i in 0..<3 {
            if i > echoChargeScore.starCount-1 {
                withAnimation(.easeInOut) {
                    starImage[i] = "star"
                    starGlowRadius[i] = 0
                }
            } else {
                withAnimation(.easeInOut) {
                    starImage[i] = "star.fill"
                    starGlowRadius[i] = 2
                }
            }
        }
    }
}
