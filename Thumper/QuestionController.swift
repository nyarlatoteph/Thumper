//
//  Created by Rudi Alberda on 11/02/2019.
//  Copyright © 2019 Rudi Alberda. All rights reserved.
//

import Foundation
import UIKit

class QuestionController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private var question: UILabel?
    @IBOutlet private var answer: UITextField?
    @IBOutlet private var infoText: UILabel?
    @IBOutlet private var questionLocale: UIImageView?
    @IBOutlet private var answerLocale: UIImageView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        answer?.delegate = self
        answer?.text = ""
        answer?.becomeFirstResponder()
        
        if let quizword = WordsService.shared.currentWord {
            infoText?.text = "D \(WordsService.shared.sessionDay) - L \(quizword.level) - # \(WordsService.shared.wordNumber+1) / \(WordsService.shared.wordsForThisSession.count)."
            if WordsService.shared.reverseQuestion {
                question?.text = quizword.answer
                questionLocale?.image = UIImage(named: quizword.answerLocale.languageCode ?? "nl")
                answerLocale?.image = UIImage(named: quizword.questionLocale.languageCode ?? "hu")
            } else {
                question?.text = quizword.question
                questionLocale?.image = UIImage(named: quizword.questionLocale.languageCode ?? "nl")
                answerLocale?.image = UIImage(named: quizword.answerLocale.languageCode ?? "hu")
            }
        }
    }
    
    @IBAction func dontKnow() {
        WordsService.shared.answer = "I don't know"
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        WordsService.shared.answer = answer?.text
        answer?.resignFirstResponder()
        self.performSegue(withIdentifier: "showAnswer", sender: self)
        return false
    }
    
}
