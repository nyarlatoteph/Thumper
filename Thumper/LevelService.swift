//
//  Created by Rudi Alberda on 18/02/2019.
//  Copyright © 2019 Rudi Alberda. All rights reserved.
//

import Foundation

class LevelService {

    static let shared = LevelService()

    private init() {
        
    }
    
    public func levelsForDay(_ day: Int) -> Array<Int> {
        var ret:Array<Int> = [1]
        if day % 2 == 0 {
            ret.insert(2, at: 0)
        }
        if (day-1) % 4 == 0 {
            ret.insert(3, at: 0)
        }
        if [3, 12, 19, 28, 35, 44, 51, 60].contains(day % 64) {
            ret.insert(4, at: 0)
        }
        if [11, 27, 43, 59].contains(day % 64) {
            ret.insert(5, at: 0)
        }
        if [23, 58].contains(day % 64) {
            ret.insert(6, at: 0)
        }
        if day % 64 == 55 {
            ret.insert(7, at: 0)
        }
        return ret
    }

}
