//
//  InterfaceBackgroundview.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/12/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




class ScrollableContentBackgroundView: UIView{
    
    
    init(title: String, message: String){
        self.title = title
        self.message = message
        super.init(frame: CGRect.zero)
        objectsHolderView.alpha = 0
        setUpViews()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        objectsHolderView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        UIView.animate(withDuration: 0.45) {
            self.objectsHolderView.alpha = 1
            self.objectsHolderView.transform = CGAffineTransform.identity
        }
    }
    
    private var title: String
    private var message: String
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutIfNeeded()
    
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        button.backgroundColor = color
    }
    
    
    private lazy var objectsHolderView: UIView = {
        
        let x = UIView()
        
        [topLabel, bottomLabel, buttonHolderView].forEach { x.addSubview($0) }
        
        topLabel.pin(top: x.topAnchor,centerX: x.centerXAnchor)
        bottomLabel.pin(top: topLabel.bottomAnchor,centerX: x.centerXAnchor)
        buttonHolderView.pin(top: bottomLabel.bottomAnchor,centerX: x.centerXAnchor, size: CGSize(width: 200, height: 40), insets: UIEdgeInsets(top: 20))
        return x
    }()
    
    
    private lazy var topLabel: UILabel = {
        let x = UILabel()
        x.text = title
        x.font = UIFont.boldSystemFont(ofSize: 20)
        return x
    }()
    
    
    
    private lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.text = message
        x.textColor = .gray
        return x
    }()
    
    
    
    
    
    private lazy var button: UIButton = {
        let x = UIButton(type: .system)
        x.backgroundColor = THEME_COLOR(asker: self)
        x.setAttributedTitle(NSAttributedString(string: "Search Youtube", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]), for: .normal)
        x.addTarget(self, action: #selector(respondToSearchButtonTapped), for: .touchUpInside)
        return x
        
        
    }()
    
    @objc private func respondToSearchButtonTapped(){
        
        AppManager.shared.screen.showtabBarItem(tag: 2)
        AppManager.shared.screen.searchView.popToRootViewController(animated: true)
        
        
    }
    
    private lazy var buttonHolderView: UIView = {
        let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = .clear
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowRadius = 10
        x.layer.shadowOffset = CGSize(width: 0, height: 2)
        x.layer.shadowOpacity = 0.8
        x.addSubview(button)
        button.pinAllSidesTo(x)
        
        return x
        
    }()
    
    
    private func setUpViews(){
        addSubview(objectsHolderView)
        objectsHolderView.pin(centerX: centerXAnchor, width: widthAnchor, size: CGSize(height: 120))
        objectsHolderView.centerYAnchor.constraint(equalTo: topAnchor, constant: 135).isActive = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}


