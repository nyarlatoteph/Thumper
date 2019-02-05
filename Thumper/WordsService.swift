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
    public var level: Int32
}

class WordsService {
    
    static let shared = WordsService()
    private var db: FMDatabase?
    private var words: [QuizWord] = []
    
    private init() {
        do {
            if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                if let db = FMDatabase(path: "\(documentsPathURL.path)/words.db") {
                    self.db = db
                    if db.open() {
                        if !db.tableExists("words") {
                            try createTables()
                        }
                        
                        // Read Bundled CSV files
                        if let wordsDir = Bundle.main.url(forResource: "words", withExtension: nil) {
                            let files = try FileManager.default.contentsOfDirectory(atPath: wordsDir.path)
                            for file in files {
                                try insertIntoDb(wordsDir.path, file: file)
                            }
                        }

                        // Read words from db
                        try readWordsFromDb()
                        
                    } else {
                        
                    }
                }
            }
        } catch {
            print("Error initializing words: \(error).")
        }
    }
    
    
    private func createTables() throws {
        try db?.executeUpdate("create table words (question varchar, answer varchar, questionLocale varchar, answerLocale varchar, level int)", values: nil)
        try db?.executeUpdate("create table files (filename varchar)", values: nil)
    }
    
    private func insertIntoDb(_ path: String, file: String) throws {
        if let rs = try db?.executeQuery("select count(*) from files where filename = ?", values: [file]) {
            if rs.next() {
                if rs.int(forColumnIndex: 0) > 0 {
                    return
                }
            }
        }
        let f = "\(path)/\(file)"
        if FileManager.default.fileExists(atPath: f) {
            let words = readWordsFromCSV(f)
            for qw in words {
                try db?.executeUpdate("insert into words (question, answer, questionLocale, answerLocale, level) values(?, ?, ?, ?, ?)",
                                      values: [qw.question, qw.answer, qw.questionLocale.identifier, qw.answerLocale.identifier, qw.level])
            }
            try db?.executeUpdate("insert into files (filename) values(?)", values: [file])
        }
    }
    
    
    private func readWordsFromDb() throws {
        if let rs = db?.executeQuery("select question, answer, questionLocale, answerLocale, level from words", withParameterDictionary: [:]) {
            while rs.next() {
                let question = rs.string(forColumn: "question").trimmingCharacters(in: .whitespacesAndNewlines)
                let answer = rs.string(forColumn: "answer").trimmingCharacters(in: .whitespacesAndNewlines)
                let qlc = rs.string(forColumn: "questionLocale").trimmingCharacters(in: .whitespacesAndNewlines)
                let alc = rs.string(forColumn: "answerLocale").trimmingCharacters(in: .whitespacesAndNewlines)
                let level = rs.int(forColumn: "level")
                self.words.append(QuizWord(question: question,
                                           answer: answer,
                                           questionLocale: Locale(identifier: qlc),
                                           answerLocale: Locale(identifier: alc),
                                           level: level))
            }
        }
    }
    
    private func readWordsFromCSV(_ file: String) -> [QuizWord] {
        var words: [QuizWord] = []
        do {
            let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            let parsedCSV: [[String]] = Array(content.components(separatedBy: "\n").map{ $0.components(separatedBy: ";")}.dropFirst())
            for line in parsedCSV {
                if (line.count == 4) {
                    let question = line[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answer = line[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let qlc = Locale(identifier: line[2].trimmingCharacters(in: .whitespacesAndNewlines))
                    let alc = Locale(identifier: line[3].trimmingCharacters(in: .whitespacesAndNewlines))
                    words.append(QuizWord(question: question, answer: answer, questionLocale: qlc, answerLocale: alc, level: 1))
                }
            }
        } catch {
            print("Error initializing words: \(error).")
        }
        return words
    }
    
    public func random() -> QuizWord? {
        return words.count > 0 ? words[Int.random(in: 0 ..< words.count)] : nil
    }
    
    public func allWords() -> [QuizWord] {
        return words
    }
}
