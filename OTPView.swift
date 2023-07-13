//
//  OTPView.swift
//  Study
//
//  Created by Ihab yasser on 12/07/2023.
//

import UIKit

class OTPView: UIView {
    
    private let stack:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let box:UITextField = {
        let box = UITextField()
        box.borderStyle = .line
        return box
    }()
    
    var numberOfBoxes:Int = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    private func setupViews(){
        addSubview(stack)
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        for _ in 0...numberOfBoxes {
            stack.addArrangedSubview(box)
        }
    }
    
    private func calculateBoxSize() -> CGSize {
        let boxesSpaces = numberOfBoxes * 8
        let boxWidth = (frame.width - CGFloat(boxesSpaces)) / CGFloat(numberOfBoxes)
        return CGSize(width: boxWidth, height: boxWidth)
    }
}
