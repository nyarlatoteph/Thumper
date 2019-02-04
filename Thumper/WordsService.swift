//
//  Created by Rudi Alberda on 20/10/2018.
//  Copyright © 2018 Rudi Alberda. All rights reserved.
//

import Foundation
import kfmdb

struct QuizWord {
    public var question: String
    public var answer: String
    public var questionLocale: Locale
    public var answerLocale: Locale
}

class WordsService {
    
    static let shared = WordsService()
    
    private var queue: FMDatabaseQueue?
    private var words: [QuizWord] = []
    
    private init() {
        do {
            if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                queue = FMDatabaseQueue(path: "\(documentsPathURL.path)/words.db")
                queue?.inDatabase({ (db) in
                    if let rs = db?.executeQuery("select question, answer, qlc, alc from words", withParameterDictionary: [:]) {
                        while rs.next() {
                            let question = rs.string(forColumn: "question").trimmingCharacters(in: .whitespacesAndNewlines)
                            let answer = rs.string(forColumn: "answer").trimmingCharacters(in: .whitespacesAndNewlines)
                            let qlc = rs.string(forColumn: "qlc").trimmingCharacters(in: .whitespacesAndNewlines)
                            let alc = rs.string(forColumn: "alc").trimmingCharacters(in: .whitespacesAndNewlines)
                            self.words.append(QuizWord(question: question,
                                                       answer: answer,
                                                       questionLocale: Locale(identifier: qlc),
                                                       answerLocale: Locale(identifier: alc)))
                        }
                    }
                })
            }
        }
/*
            let fileURL = Bundle.main.url(forResource: "words", withExtension: "csv")
//            let fileURL = Bundle.main.url(forResource: "words_focus", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            let parsedCSV: [[String]] = Array(content.components(separatedBy: "\n").map{ $0.components(separatedBy: ";")}.dropFirst())
            for line in parsedCSV {
                if (line.count == 4) {
                    let question = line[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answer = line[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let qlc = Locale(identifier: line[2].trimmingCharacters(in: .whitespacesAndNewlines))
                    let alc = Locale(identifier: line[3].trimmingCharacters(in: .whitespacesAndNewlines))
                    words.append(QuizWord(question: question, answer: answer, questionLocale: qlc, answerLocale: alc))
                }
            }
        } catch {
            print("Error initializing words: \(error).")
        }
 */
    }
    
    public func random() -> QuizWord? {
        return words.count > 0 ? words[Int.random(in: 0 ..< words.count)] : nil
    }
    
    public func allWords() -> [QuizWord] {
        return words
    }
}
