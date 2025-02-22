import SwiftUI
import UIKit

// All the images are used in this app is taken from DeepAI

@main
struct EchoMazeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        resetSandboxData()
    }
    
    func resetSandboxData() {
        [
            "unlockedLevel",
            "storeEchoCharges",
            "showTutorial",
            
        ].forEach { object in
            UserDefaults.standard.removeObject(forKey: object)
        }
    }
}
