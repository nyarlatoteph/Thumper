//
//  Created by Rudi Alberda on 20/10/2018.
//  Copyright © 2018 Rudi Alberda. All rights reserved.
//

import UIKit

class QuizController: UIViewController {
    
    @IBOutlet private var button: UIButton?
    @IBOutlet private var right: UIButton?
    @IBOutlet private var wrong: UIButton?
    @IBOutlet private var questionLabel: UILabel?
    @IBOutlet private var answerLabel: UILabel?
    @IBOutlet private var infoText: UILabel?
    @IBOutlet private var questionLocale: UIImageView?
    @IBOutlet private var answerLocale: UIImageView?
    
    private var nextQuestion: Bool = true
    private var reversed: Bool = false
    private var quizWord: QuizWord?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reveal()
    }

    @IBAction public func reveal() {
        if nextQuestion {
            if let qw = WordsService.shared.next() {
                quizWord = qw
                reversed = Bool.random()
                nextQuestion = false

                if reversed {
                    questionLabel?.text = qw.answer
                    questionLocale?.image = UIImage(named: qw.answerLocale.languageCode ?? "nl")
                    answerLocale?.image = UIImage(named: qw.questionLocale.languageCode ?? "hu")
                } else {
                    questionLabel?.text = qw.question
                    questionLocale?.image = UIImage(named: qw.questionLocale.languageCode ?? "nl")
                    answerLocale?.image = UIImage(named: qw.answerLocale.languageCode ?? "hu")
                }
                answerLabel?.text = ""
                button?.setTitle("Onthul", for: .normal)
                right?.isHidden = true
                wrong?.isHidden = true
            }
        } else {
            button?.setTitle("Volgende", for: .normal)
            answerLabel?.text = reversed ? quizWord?.question : quizWord?.answer
            nextQuestion = true
            right?.isHidden = false
            wrong?.isHidden = false
        }
    }
    
}

