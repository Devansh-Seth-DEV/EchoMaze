import SwiftUI

struct GameTutorialView: View {
    @Binding var showTutorial: Bool
    
    @State private var navigateToIntroGameplay: Bool = false
    
    @State private var canShowQuickGuideTip: Bool? = false {
        didSet {
            if let condition = self.canShowQuickGuideTip, condition == true {
                showTip()
            }
        }
    }
    
    @State private var canShowEchoPointTip: Bool? = false {
        didSet {
            if let condition = self.canShowEchoPointTip, condition == true {
                showTip()
            }
        }
    }
    
    @State private var canShowEchoPointFindTip: Bool? = false {
        didSet {
            if let condition = self.canShowEchoPointFindTip, condition == true {
                showTip()
            }
        }
    }
    
    private var tipText: Text? {
        if canShowQuickGuideTip ?? false {
            return Text("**Welcome, Echo!**\n\nYou are trapped in a silent maze where no sound exists. Your only way out is to find and deactivate the **Echo Point**, a hidden source of resonance that can restore your lost signal.")
        } else if canShowEchoPointTip ?? false {
            return Text("But there’s a challenge you cannot see the **Echo Point**, only sense it through **vibrations**.\n\nFollow your **phone vibrations** beneath your steps. Stronger pulses mean you're close to **Echo Point**, weaker ones mean you're far.")
        } else if canShowEchoPointFindTip ?? false {
            return Text("Find and Deactivate the **Echo Point** before the silence claims you!")
        } else { return nil }
    }
    
    @State private var popupOpacity = 0.0
    @State private var tipIsShowing: Bool = false
    @State private var canDissapearTip: Bool = false
    @State private var DISSAPEAR_TIP_DELAY: Double = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("LandingTheme")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                
                if tipIsShowing {
                    VStack(spacing: 30) {
                        tipText?
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
                        
                        Text(!(canShowEchoPointFindTip ?? false) ? "Tap anywhere to continue..." : "Tap to begin")
                            .font(.body)
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 350)
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + DISSAPEAR_TIP_DELAY) {
                            canDissapearTip = true
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.clear)
                }
                
                
                if navigateToIntroGameplay {
                    LevelsView()
                        .transition(.opacity)
                }
            }
        }
        .onTapGesture {
            hideTip()
        }
        .onAppear() {
            canShowQuickGuideTip = true
        }
    }
    
    private func showTip() {
        if !tipIsShowing {
            tipIsShowing = true
            popupOpacity = 0.0
            withAnimation(.easeIn(duration: 0.5)) {
                popupOpacity = 1.0
            }
        }
    }
    
    
    private func hideTip() {
        if tipIsShowing && canDissapearTip {
            withAnimation(.easeInOut(duration: 0.5)) {
                popupOpacity = 0.0

            }
            
            tipIsShowing = false
            canDissapearTip = false
            DispatchQueue.main.async {
                if canShowQuickGuideTip ?? false {
                    canShowQuickGuideTip = nil
                    canShowEchoPointTip = true
                } else if canShowEchoPointTip ?? false {
                    canShowEchoPointTip = nil
                    canShowEchoPointFindTip = true
                } else if canShowEchoPointFindTip ?? false {
                    canShowEchoPointFindTip = nil
                    showTutorial = false
                    navigateToIntroGameplay = true
                }
            }
        }
    }
}
