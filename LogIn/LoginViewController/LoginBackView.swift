//
//  LoginBackView.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 15.01.2022.
//

import UIKit

final class LoginBackView: UIView {
    
    private let viewFrame = UIScreen.main.bounds
    
    private lazy var backGradientView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = viewFrame.size
        gradientLayer.colors = [UIColor.systemIndigo.cgColor,
                                UIColor.systemPurple.withAlphaComponent(0.5).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
        view.layer.mask = makeBackWaveMask()
        return view
    }()
    
    private lazy var backView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = viewFrame.size
        gradientLayer.colors = [UIColor.systemIndigo.cgColor,
                                UIColor.systemPurple.cgColor,
                                UIColor.white.cgColor]
        view.layer.addSublayer(gradientLayer)
        view.layer.mask = makeWaveMask()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [backGradientView,
         backView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backGradientView.topAnchor.constraint(equalTo: topAnchor, constant: -100),
            backGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backGradientView.heightAnchor.constraint(equalToConstant: frame.height * 0.85),
            
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: frame.height * 0.8)
        ])
    }
    
    func animate() {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.backGradientView.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    /// masks for background views
    private func makeWaveMask() -> CAShapeLayer {
        let path = UIBezierPath()
        let width = viewFrame.width
        let height = viewFrame.height
        path.move(to: CGPoint(x: 0.0, y: height * 0.7))
        path.addCurve(to: CGPoint(x: width, y: height * 0.65),
                      controlPoint1: CGPoint(x: width * 0.4, y: height * 0.8),
                      controlPoint2: CGPoint(x: width * 0.66, y: height * 0.6))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
    
    private func makeBackWaveMask() -> CAShapeLayer {
        let path = UIBezierPath()
        let width = viewFrame.width
        let height = viewFrame.height
        path.move(to: CGPoint(x: 0.0, y: height * 0.68))
        path.addCurve(to: CGPoint(x: width, y: height * 0.7),
                      controlPoint1: CGPoint(x: width * 0.45, y: height * 0.83),
                      controlPoint2: CGPoint(x: width * 0.7, y: height * 0.62))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
}
