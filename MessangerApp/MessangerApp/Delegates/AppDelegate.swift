//
//  AppDelegate.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import UIKit
import Firebase
import Reachability

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let reachability = try! Reachability()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        setupServiceLocator()
        setupReachability()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    private func setupServiceLocator() {
        let secureStorage = SecureStorageService()
        let authService = AuthService()
        let firebaseService = FirebaseService()
        let chatSignalService = ChatSignalService()
        let imageLoader = ImageLoader()
        let dataCacher = DataCacher()
        
        ServiceLocator.shared.addService(service: secureStorage)
        ServiceLocator.shared.addService(service: authService)
        ServiceLocator.shared.addService(service: firebaseService)
        ServiceLocator.shared.addService(service: chatSignalService)
        ServiceLocator.shared.addService(service: imageLoader)
        ServiceLocator.shared.addService(service: dataCacher)
        guard let dbURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("MessangerDB.sqlite") else { return }
        let storageService = StorageService(path: dbURL.path)
        let sendingService = SendingService(
            firebaseService: firebaseService,
            storageService: storageService,
            chatSignalService: chatSignalService
        )
        ServiceLocator.shared.addService(service: storageService)
        ServiceLocator.shared.addService(service: sendingService)
    }
    
    private func setupReachability() {
        reachability.whenReachable = { reachability in
            let chatSignalService: ChatSignalService? = ServiceLocator.shared.getService()
            chatSignalService?.signalStartSending()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to notifier reachability")
        }
    }

}

