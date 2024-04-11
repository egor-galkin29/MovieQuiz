import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: (() -> Void)
    
    init(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.completion = completion
    }
}
