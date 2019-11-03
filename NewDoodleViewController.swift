
import UIKit

protocol NewDoodleViewControllerDelegate: class {
    func newDoodleViewControllerDidComplete(with size: CGSize)
}

class NewDoodleViewController: UIViewController {
    
    @IBOutlet var aspectView: AspectPreviewView!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var formContainerView: UIView!
    @IBOutlet var aspectSwitch: UISwitch!
    
    weak var delegate: NewDoodleViewControllerDelegate?
    
    private let maxSideLength: Int = 15000
    
    private var inputSize: (width: Int, height: Int) {
        let width = Int(widthTextField.text ?? "0") ?? 0
        let height = Int(heightTextField.text ?? "0") ?? 0
        return (width, height)
    }
    
    private var maxWidth: Int {
        let aspectRatio = aspectView.aspectRatio
        if aspectSwitch.isOn {
            if aspectRatio > 1 {
                return maxSideLength
            }
            else {
                return Int(CGFloat(maxSideLength) * aspectRatio)
            }
        }
        return maxSideLength
    }
    
    private var maxHeight: Int {
        let aspectRatio = aspectView.aspectRatio
        if aspectSwitch.isOn {
            if aspectRatio > 1 {
                return Int(CGFloat(maxSideLength) / aspectRatio)
            }
            else {
                return maxSideLength
            }
        }
        return maxSideLength
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("NEWDOODLE", comment: "New Doodle")
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        aspectSwitch.onTintColor = .doodlerRed
        widthTextField.tintColor = .doodlerRed
        heightTextField.tintColor = .doodlerRed
        formContainerView.layer.cornerRadius = 5
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("CANCEL", comment: "Cancel"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("CREATE", comment: "Create"),
            style: .plain,
            target: self,
            action: #selector(createButtonPressed)
        )
                
        widthTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        heightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let width: CGFloat, height: CGFloat
        
        if let lastSize = SettingsController.shared.documentSize {
            width = lastSize.width
            height = lastSize.height
        }
        else {
            let screenSize = UIScreen.main.bounds.size
            width = screenSize.width
            height = screenSize.height
        }
        
        widthTextField.text = String(Int(width))
        heightTextField.text = String(Int(height))
        
        aspectView.aspectRatio = width / height
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonPressed() {
        guard let widthText = widthTextField.text, let width = Double(widthText) else {
            return
        }
        
        guard let heightText = heightTextField.text, let height = Double(heightText) else {
            return
        }

        let selectedSize = CGSize(width: width, height: height)
        SettingsController.shared.documentSize = selectedSize
        
        dismiss(animated: true) {
            self.delegate?.newDoodleViewControllerDidComplete(with: selectedSize)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard inputSize.width > 0 && inputSize.height > 0 else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        if navigationItem.rightBarButtonItem?.isEnabled == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
                        
        guard aspectSwitch.isOn else {
            aspectView.aspectRatio = CGFloat(inputSize.width) / CGFloat(inputSize.height)
            return
        }
        
        if textField == widthTextField {
            heightTextField.text = String(Int(round(CGFloat(inputSize.width) / aspectView.aspectRatio)))
        }
        else {
            widthTextField.text = String(Int(round(CGFloat(inputSize.height) * aspectView.aspectRatio)))
        }
        
        if inputSize.width > maxWidth {
            widthTextField.text = String(maxWidth)
        }
        
        if inputSize.height > maxHeight {
            heightTextField.text = String(maxHeight)
        }
    }
    
}

extension NewDoodleViewController: NavigationPresentationConfigurable {
    
    var contentHeight: CGFloat {
        return 320
    }
    
}
