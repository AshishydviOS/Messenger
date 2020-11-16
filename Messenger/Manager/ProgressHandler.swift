//
//  ProgressHandler.swift
//  Messenger
//
//  Created by Ashish Yadav on 16/11/20.
//

import Foundation
import PKHUD

class ProgressHandler{
    
    static let sharedInstance = ProgressHandler()
    private init(){}
    
    func setupProgress(){
        PKHUD.sharedHUD.contentView = PKHUDRotatingImageView(image: PKHUDAssets.progressCircularImage, title: "Loading", subtitle:"Please Wait")
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
    }
    
    func showProgress() {
        PKHUD.sharedHUD.show()
    }
    
    func hideProgress(){
        PKHUD.sharedHUD.hide(animated: true, completion: nil)
    }

}
