//
//  Created by Rudi Alberda on 20/10/2018.
//  Copyright © 2018 Rudi Alberda. All rights reserved.
//

import Foundation
import kfmdb

struct QuizWord {
    public var id: String
    public var question: String
    public var answer: String
    public var questionLocale: Locale
    public var answerLocale: Locale
    public var level: Int32
}

class WordsService {
    
    static let shared = WordsService()
    private var db: FMDatabase?
    private(set) var wordsForThisSession: [QuizWord] = []
    private(set) var newWords: [QuizWord] = []
    private(set) var incorrectWords: [QuizWord] = []
    public var newWordsPerDay = 10
    public var currentWord: QuizWord? = nil
    private(set) var wordNumber: Int = 0
    public var reverseQuestion: Bool = false
    public var answer: String?
    private(set) var sessionDay: Int = 0

    
    // TODO:
    // 1. Overzicht van fouten aan het eind
    // 4. Vooraf overicht van nieuwe woorden
    private init() {
        do {
            if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let dbURL = URL(fileURLWithPath: "\(documentsPathURL.path)/words.db")
                // Copy bundled database, if it exists and if we don't have a db file yet
                if let bundledDbURL = Bundle.main.url(forResource: "words", withExtension: "db") {
                    if !FileManager.default.fileExists(atPath: dbURL.path) {
                        try FileManager.default.copyItem(at: bundledDbURL, to: dbURL)
                    }
                }
                
                // Open database
                if let db = FMDatabase(path: dbURL.path) {
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
                        
                        let rs = try db.executeQuery("select count(*) from words where level > 0", values: [])
                        if rs.next() {
                            if rs.int(forColumnIndex: 0) == 0 {
                                try self.selectNewWordsForLevel1()
                            }
                        }
                        
                        if let rs = db.executeQuery("select sessionDay from status", withParameterDictionary: [:]) {
                            while rs.next() {
                                sessionDay = Int(rs.int(forColumn: "sessionDay"))
                            }
                        }
                    } else {
                        // TODO: error message
                    }
                }
            }
        } catch {
            print("Error initializing words: \(error).")
        }
    }
    
    
    private func createTables() throws {
        try db?.executeUpdate("create table words (id varchar, question varchar, answer varchar, questionLocale varchar, answerLocale varchar, level int)", values: nil)
        try db?.executeUpdate("create table files (filename varchar)", values: nil)
        try db?.executeUpdate("create table status (sessionDay int)", values: nil)
    }

    private func selectNewWordsForLevel1() throws {
        try db?.executeUpdate("update words set level = 1 where level = 0 limit ?", values: [ newWordsPerDay ])
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
            let words = try readWordsFromCSV(f)
            for qw in words {
                try db?.executeUpdate("insert into words (id, question, answer, questionLocale, answerLocale, level) values(?, ?, ?, ?, ?, ?)",
                                      values: [UUID().uuidString, qw.question, qw.answer, qw.questionLocale.identifier, qw.answerLocale.identifier, qw.level])
            }
            try db?.executeUpdate("insert into files (filename) values(?)", values: [file])
        }
    }
    
    
    public func initWordsForLevels(_ levels: [Int]) throws {
        var wordsToAdd: [QuizWord]
        for level in levels {
            wordsToAdd = []
            if let rs = try db?.executeQuery("select id, question, answer, questionLocale, answerLocale, level from words where level = ?",
                                             values: [level]) {
                while rs.next() {
                    let id = rs.string(forColumn: "id").trimmingCharacters(in: .whitespacesAndNewlines)
                    let question = rs.string(forColumn: "question").trimmingCharacters(in: .whitespacesAndNewlines)
                    let answer = rs.string(forColumn: "answer").trimmingCharacters(in: .whitespacesAndNewlines)
                    let qlc = rs.string(forColumn: "questionLocale").trimmingCharacters(in: .whitespacesAndNewlines)
                    let alc = rs.string(forColumn: "answerLocale").trimmingCharacters(in: .whitespacesAndNewlines)
                    let level = rs.int(forColumn: "level")
                    let quizWord = QuizWord(id: id,
                                            question: question,
                                            answer: answer,
                                            questionLocale: Locale(identifier: qlc),
                                            answerLocale: Locale(identifier: alc),
                                            level: level)
                    if (level == 1) {
                        newWords.append(quizWord)
                    }
                    wordsToAdd.append(quizWord)
                }
            }
            wordsToAdd.shuffle()
            self.wordsForThisSession.append(contentsOf: wordsToAdd)
        }
        
        self.currentWord = self.wordsForThisSession.first
    }
    
    private func readWordsFromCSV(_ file: String) throws -> [QuizWord] {
        var words: [QuizWord] = []
        let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
        let parsedCSV: [[String]] = Array(content.components(separatedBy: "\n").map{ $0.components(separatedBy: ";")}.dropFirst())
        for line in parsedCSV {
            if (line.count == 4) {
                let question = line[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let answer = line[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let qlc = Locale(identifier: line[2].trimmingCharacters(in: .whitespacesAndNewlines))
                let alc = Locale(identifier: line[3].trimmingCharacters(in: .whitespacesAndNewlines))
                words.append(QuizWord(id: UUID().uuidString, question: question, answer: answer, questionLocale: qlc, answerLocale: alc, level: 0))
            }
        }
        return words
    }
    
    public func hasNext() -> Bool {
        return wordNumber < wordsForThisSession.count-1
    }
    
    public func next() -> QuizWord? {
        if hasNext() {
            wordNumber = wordNumber+1
            currentWord = wordsForThisSession[wordNumber]
            reverseQuestion = Int.random(in: 1...100) < 75
        }
        return currentWord
    }
    
    public func isAnswerCorrect() -> Bool {
        guard var response = answer?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        var question: String
        if reverseQuestion {
            question = currentWord!.question.lowercased()
        } else {
            question = currentWord!.answer.lowercased()
        }
        let multiAnswer = question.contains(",") || question.contains("(")
        let cs = CharacterSet(charactersIn: ".,?!()/")
        question = question.trimmingCharacters(in: cs)
        response = response.trimmingCharacters(in: cs)
        if question == response {
            return true
        }
        
        if multiAnswer {
            return question.contains(response)
        }
        return false
    }
    
    public func update() throws {
        guard let cw = currentWord else {
            return
        }
        
        var level = cw.level
        if isAnswerCorrect() {
            level += 1
        } else {
            level = 1
            incorrectWords.append(cw)
        }
        try db?.executeUpdate("update words set level = ? where id = ?", values: [ level, cw.id ])
    }
    
    public func wasRight() throws {
        guard let cw = currentWord else {
            return
        }
        try db?.executeUpdate("update words set level = ? where id = ?", values: [ cw.level + 1, cw.id ])
    }

    public func finishSession() throws {
        try db?.executeUpdate("delete from status", values: nil)
        try db?.executeUpdate("insert into status (sessionDay) values (?)", values: [ sessionDay + 1 ])
        try selectNewWordsForLevel1()
        exit(0)
    }
}
