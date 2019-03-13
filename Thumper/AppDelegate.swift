//
//  AppDelegate.swift
//  Thumper
//
//  Created by Rudi Alberda on 20/10/2018.
//  Copyright © 2018 Rudi Alberda. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let levels = LevelService.shared.levelsForDay(WordsService.shared.sessionDay)
            try WordsService.shared.initWordsForLevels(levels)
            
            print(WordsService.shared.wordsForThisSession)
        } catch {
            return false
        }
        return true
    }

}

