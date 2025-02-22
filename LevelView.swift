import SwiftUI


struct LevelsView: View {
    @State private var path: NavigationPath = NavigationPath()
    @AppStorage("unlockedLevel") private var unlockedLevel = 1
    @AppStorage("storeEchoCharges") private var storedEchoCharges: String = "[]"
    @State private var scrollToLevel: Int = 1
    
    private let MAX_LEVELS = 9
    let columns = Array<GridItem>(repeating: GridItem(.flexible()), count: 3)

    private var echoChargesCollected: Int {
        var charges: Int = 0
        getEchoCharges().forEach {
            charges += $0
        }
        
        return charges
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
                                        LevelMapView(level: index+1, unlockedLevels: unlockedLevel)
                                            .offset(x: (index).isMultiple(of: 2) ? -80 : 80)
                                            .onTapGesture {
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        proxy.scrollTo(unlockedLevel, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        }
    }
    
    func getEchoCharges() -> [Int] {
        if let data = storedEchoCharges.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            return decoded
        }
        return []
    }
    
    func updateEchoCharges(_ charges: [Int]) {
        if let encoded = try? JSONEncoder().encode(charges),
           let jsonString = String(data: encoded, encoding: .utf8) {
            storedEchoCharges = jsonString
        }
    }
}

struct LevelMapView: View {
    let level: Int
    let unlockedLevels: Int
    
    init(level: Int, unlockedLevels: Int) {
        self.level = level
        self.unlockedLevels = unlockedLevels
    }
    
    var body: some View {
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
}
