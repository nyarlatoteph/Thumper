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
    @IBOutlet private var infoText: UILabel?

    override func viewWillAppear(_ animated: Bool) {
        if let quizword = WordsService.shared.currentWord {
            let is_correct = false
            wrong?.isHidden = is_correct
            correct?.isHidden = !is_correct
            correct_answer?.text = "\(quizword.question) = \(quizword.answer)"
            infoText?.text = "Level: \(quizword.level). Card \(WordsService.shared.wordNumber+1) of \(WordsService.shared.wordsForThisSession.count)."
        }
    }
}
