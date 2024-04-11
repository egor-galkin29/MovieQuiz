import UIKit

final class AlertPresenter: AlertProtocol {
    
    weak var delegate: UIViewController?
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    func createAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert,animated: true, completion: nil)
    }
}
