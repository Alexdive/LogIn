//
//  UIExtensions.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit

extension UITextField {
    func loginTextStyle() {
        self.backgroundColor = .systemGray6
        self.tintColor = .systemGray2
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        let font = UIFont.systemFont(ofSize: 20)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: 1.6,
            .font: font,
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle]
        self.defaultTextAttributes = attributes
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor?, forState: UIControl.State) {
        guard let color = color else { return }
        self.clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
