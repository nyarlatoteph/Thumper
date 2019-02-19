//
//  Created by Rudi Alberda on 18/02/2019.
//  Copyright © 2019 Rudi Alberda. All rights reserved.
//

import Foundation

class LevelService {

    static let shared = LevelService()

    private init() {
        
    }
    
    public func sessionDay(_ date: Date?) -> Int {
        var sessionDay = 0
        if let d = date {
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: d)
            let date2 = calendar.startOfDay(for: Date())
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            sessionDay = components.day ?? 0
        }
        return sessionDay
    }
    
    public func levelsForDay(_ date: Int) -> Array<Int> {
        var ret:Array<Int> = [1]
        if date % 2 == 0 {
            ret.insert(2, at: 0)
        }
        if (date-1) % 4 == 0 {
            ret.insert(3, at: 0)
        }
        if [3, 12, 19, 28, 35, 44, 51, 60].contains(date % 64) {
            ret.insert(4, at: 0)
        }
        if [11, 27, 43, 59].contains(date % 64) {
            ret.insert(5, at: 0)
        }
        if [23, 58].contains(date % 64) {
            ret.insert(6, at: 0)
        }
        if date % 64 == 55 {
            ret.insert(7, at: 0)
        }
        return ret
    }

}
