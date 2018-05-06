//
//  TabBarController_MusicViewDelegate.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import UIKit
extension Screen: MusicViewDelegate{
    
    
    
    
    
    
    
  
    
    
    
    
    
    func delegate_Stuff_To_Be_Done_In_ViewDidLoad(){
        AppManager.shared.musicView.delegate = self
        
    }
    

    var holderViewSideInsets: CGFloat{
        return 10
    }
    
    var holderViewTopInset: CGFloat{
        return 7 + AppManager.appInsets.top
    }
    
    
    
    private var holderViewMinimizedFrame: CGRect{

        return CGRect(x: holderViewSideInsets,
                      y: holderViewTopInset,
                      width: view.frame.width - (holderViewSideInsets * 2),
                      height: view.frame.height - holderViewTopInset)
    }
    
    
    
    //MARK: - MUSIC VIEW DELEGATE METHODS
    
    func userDid_Maximize_MusicView(){
        
        self.snapshotView = self.holderView.snapshotView(afterScreenUpdates: true)
        self.holderView.addSubview(self.snapshotView)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            let xTranslation = self.holderViewMinimizedFrame.width / self.view.frame.width
            let yTranslation = self.holderViewMinimizedFrame.height / self.view.frame.height
            let scaleTransform = CGAffineTransform(scaleX: xTranslation, y: yTranslation)
            
            let topSpace = (self.view.frame.height - (self.view.frame.height * yTranslation)) / 2
            let remainingSpace = self.holderViewMinimizedFrame.minY - topSpace
            
            self.holderView.transform = scaleTransform.translatedBy(x: 0, y: remainingSpace)
            
       
            
            self.holderView.layer.cornerRadius = 10
            self.holderView.alpha = 0.7
        }, completion: nil)
        self.dismissTabBar()

    
    }
    
    func userDid_Minimize_MusicView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            self.holderView.center = self.view.centerInFrame
            
            self.holderView.transform = CGAffineTransform.identity
            self.holderView.center = self.view.centerInBounds
            self.holderView.layer.cornerRadius = 0
            self.holderView.alpha = 1
            self.snapshotView.removeFromSuperview()
            self.snapshotView = nil
        }, completion: nil)
        self.showTabBar()

    
    }
    
    
    
    

    
    
    
   
    
    
}







