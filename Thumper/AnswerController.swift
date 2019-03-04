//
//  Created by Rudi Alberda on 11/02/2019.
//  Copyright © 2019 Rudi Alberda. All rights reserved.
//

import Foundation
import UIKit

class AnswerController: UIViewController {
    
    @IBOutlet private var correct: UILabel?
    @IBOutlet private var wrong: UILabel?
    @IBOutlet private var correct_answer: UILabel?
    @IBOutlet private var your_answer: UILabel?
    @IBOutlet private var infoText: UILabel?
    @IBOutlet private var nextButton: UIButton?
    @IBOutlet private var wasRightButton: UIButton?

    override func viewWillAppear(_ animated: Bool) {
        if let quizword = WordsService.shared.currentWord {
            let is_correct = WordsService.shared.isAnswerCorrect()
            
            wrong?.isHidden = is_correct
            correct?.isHidden = !is_correct
            wasRightButton?.isHidden = is_correct
            your_answer?.isHidden = is_correct
            your_answer?.text = "You answered: \(WordsService.shared.answer ?? "")"
            
            self.view.backgroundColor = is_correct ? UIColor.init(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0) :
                UIColor.init(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
            if WordsService.shared.reverseQuestion {
                correct_answer?.text = "\(quizword.answer) = \(quizword.question)"
            } else {
                correct_answer?.text = "\(quizword.question) = \(quizword.answer)"
            }
            infoText?.text = "Level: \(quizword.level). Card \(WordsService.shared.wordNumber+1) of \(WordsService.shared.wordsForThisSession.count)."
        }
        
        nextButton?.isEnabled = WordsService.shared.hasNext()
    }
    
    private func next() {
        _ = WordsService.shared.next()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction public func nextWord() {
        WordsService.shared.update()
        next()
    }
    
    @IBAction public func wasRight() {
        WordsService.shared.wasRight()
        next()
    }
}
