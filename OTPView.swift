//
//  OTPView.swift
//
//
//  Created by Ihab yasser on 12/07/2023.
//

import UIKit


enum OTPType{
    case Numeric
    case Alphabitic
}

struct OTPConfiguration {
    var boxSize:CGFloat
    var numberOfBoxes:Int = 4
    var font:UIFont
    var type:OTPType = .Numeric
    var selectedColor:UIColor = Colors.AccentColor
    var normalColor:UIColor = .gray
}

protocol OTPDidEnteredDelegate {
    func entered(text:String)
}

class OTPView: UIView {
    
    lazy var stack:UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    fileprivate let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    fileprivate var config:OTPConfiguration? = OTPConfiguration(boxSize: 50, font: UIFont.boldSystemFont(ofSize: 25))
    fileprivate var boxes:[UITextField] = []
    var delegate:OTPDidEnteredDelegate?
    var text:String?{
        get{
            return enteredValues()
        }
    }
    
    
    init(config:OTPConfiguration) {
        super.init(frame: .zero)
        self.config = config
        setupViews()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews(isStoryboard: true)
    }
    
    func configure(config:OTPConfiguration){
        self.config = config
        setupViews()
    }
    
    fileprivate func setupViews(isStoryboard:Bool = false){
        guard let config = self.config else {
            assertionFailure("view configurations required.")
            return
        }
        boxes.removeAll()
        for _ in 1...config.numberOfBoxes {
            boxes.append(createBox(configurations: config))
        }
        addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        stack.removeFullyAllArrangedSubviews()
        for (index , box) in boxes.enumerated() {
            box.tag = index + 1
            stack.addArrangedSubview(box)
            box.widthAnchor.constraint(equalToConstant: config.boxSize).isActive = true
            box.heightAnchor.constraint(equalToConstant: config.boxSize).isActive = true
        }
        if boxes.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.boxes[0].becomeFirstResponder()
                self.highligh(box: self.boxes[0])
            }
        }
    }

    
    
    fileprivate func createBox(configurations:OTPConfiguration) -> Box{
        let box = Box(frame: CGRect(origin: .zero, size: CGSize(width: configurations.boxSize, height: configurations.boxSize)))
        box.isUserInteractionEnabled = true
        box.layer.masksToBounds = true
        box.font = configurations.font
        box.textColor = configurations.selectedColor
        box.layer.cornerRadius = 4
        box.layer.borderColor = configurations.normalColor.cgColor
        box.layer.borderWidth = 1
        box.textAlignment = .center
        box.delegate = self
        box.textContentType = .oneTimeCode
        box.translatesAutoresizingMaskIntoConstraints = false
        box.keyboardType = configurations.type == .Numeric ? .numberPad : .default
        return box
    }
    
    
    fileprivate func highligh(box:UITextField?){
        box?.layer.borderColor = config!.selectedColor.cgColor
    }
    
    fileprivate func resetHighligh(){
        for box in boxes {
            box.layer.borderColor = config!.normalColor.cgColor
        }
    }
    
    fileprivate func enteredValues() -> String{
        var text = ""
        for box in boxes {
            text += box.text ?? ""
        }
        return text
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override var intrinsicContentSize: CGSize {
            return stack.intrinsicContentSize
        }
    
}

extension OTPView : UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        if string != filtered {
            return false
        }
        if replacedText.count >= 1 {
            textField.text = replacedText.last?.uppercased()
            resetHighligh()
            if let nextOTPField = boxes.first(where: { box in
                !box.hasText
            })/*viewWithTag(textField.tag + 1)*/ {
                nextOTPField.becomeFirstResponder()
                highligh(box: nextOTPField as? Box)
            }
            else {
                delegate?.entered(text: enteredValues())
                textField.resignFirstResponder()
            }
        }else{
            textField.text = ""
            if textField.tag > 1 {
                resetHighligh()
            }
            if let prevOTPField = viewWithTag(textField.tag - 1) {
                prevOTPField.becomeFirstResponder()
                highligh(box: prevOTPField as? Box)
            }
        }
        return false
    }
    
}

class Box:UITextField {
    
    override func layoutSubviews() {
        textAlignment = .center
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
    }
    
}
extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
