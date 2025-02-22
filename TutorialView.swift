import SwiftUI

struct TutorialView: View {
    @Binding var showTutorial: Bool
    
    @State private var canShowQuickGuideTip: Bool? = false
    @State private var canShowEchoPointTip: Bool? = false
    @State private var canShowEchoPointFind: Bool? = false
    @State private var canShowWallHitTip: Bool? = false
    @State private var canShowMovesLeft: Bool? = false
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
            }
        }
    }
}
