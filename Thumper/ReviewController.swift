//
//  Created by Rudi Alberda on 24/04/2019.
//  Copyright © 2019 Rudi Alberda. All rights reserved.
//

import Foundation
import UIKit


class ReviewController: UIViewController {
    
    @IBOutlet var scrollView: UITextView?
    
}

class ErrorReviewController: ReviewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.text = "\(WordsService.shared.incorrectWords.count) Errors this session:\n\n" +
            WordsService.shared.incorrectWords.map({ (quizWord: QuizWord) -> String in
                return "\(quizWord.question) = \(quizWord.answer)\n"
            }).joined()
    }

}

class NewWordsOverviewController: ReviewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.text = "\(WordsService.shared.newWords.count) New words this session:\n\n" +
            WordsService.shared.newWords.map({ (quizWord: QuizWord) -> String in
                return "\(quizWord.question) = \(quizWord.answer)\n"
            }).joined()
    }
    
}
