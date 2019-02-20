//
//  TLStoryAuthorizationController.swift
//  TLStoryCamera
//
//  Created by 郭锐 on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

protocol TLStoryAuthorizedDelegate: NSObjectProtocol {
    func requestCameraAuthorizeSuccess()
    func requestMicAuthorizeSuccess()
    func requestAllAuthorizeSuccess()
    func cancelAuthorizePermissions()
}

class TLStoryAuthorizationController: UIViewController {
    public weak var delegate:TLStoryAuthorizedDelegate?
    
    fileprivate var bgBlurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
    
    fileprivate var titleLabel:UILabel = {
        let lable = UILabel.init()
        lable.text = TLStoryCameraResource.string(key: "tl_permisson_request_title")
        lable.textColor = UIColor.init(colorHex: 0xcccccc, alpha: 1)
        lable.font = UIFont.systemFont(ofSize: 18)
        return lable
    }()
    
    fileprivate var cancelBtn:TLButton = {
        let btn = TLButton.init(type: UIButton.ButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.tl_imageWithNamed(named: "story_icon_close"), for: .normal)
        return btn
    }()
    
    fileprivate var openCameraBtn:TLButton = {
        let btn = TLButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle(TLStoryCameraResource.string(key: "tl_open_camera_permission"), for: .normal)
        btn.setTitle(TLStoryCameraResource.string(key: "tl_opened_camera_permission"), for: .selected)
        btn.setTitleColor(UIColor.init(colorHex: 0x4797e1, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor.init(colorHex: 0x999999, alpha: 1), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var openMicBtn:TLButton = {
        let btn = TLButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle(TLStoryCameraResource.string(key: "tl_open_audio_permission"), for: .normal)
        btn.setTitle(TLStoryCameraResource.string(key: "tl_opened_audio_permission"), for: .selected)
        btn.setTitleColor(UIColor.init(colorHex: 0x4797e1, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor.init(colorHex: 0x999999, alpha: 1), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var authorizedManager = TLAuthorizedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bgBlurView)
        bgBlurView.frame = self.view.bounds
        
        self.view.addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint.init(x: self.view.width / 2, y: self.view.height / 2 - 45 - titleLabel.height / 2)
        
        self.view.addSubview(cancelBtn)
        cancelBtn.sizeToFit()
        cancelBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        cancelBtn.center = CGPoint.init(x: self.cancelBtn.width / 2, y: cancelBtn.centerY + 40)
        cancelBtn.addTarget(self, action: #selector(cancelAuthorizationAction), for: .touchUpInside)
        
        openCameraBtn.isSelected = TLAuthorizedManager.checkAuthorization(with: .camera)
        openMicBtn.isSelected = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        self.view.addSubview(openCameraBtn)
        openCameraBtn.sizeToFit()
        openCameraBtn.center = CGPoint.init(x: self.view.width / 2, y: self.view.height / 2 + 20 + openCameraBtn.height / 2)
        
        self.view.addSubview(openMicBtn)
        openMicBtn.sizeToFit()
        openMicBtn.center = CGPoint.init(x: self.view.width / 2, y: openCameraBtn.y + openCameraBtn.height + 30 + openMicBtn.height / 2)
        
        self.openCameraBtn.addTarget(self, action: #selector(openCameraAction), for: .touchUpInside)
        self.openMicBtn.addTarget(self, action: #selector(openMicAction), for: .touchUpInside)
        
        // 只能拍摄照片时，不用申请麦克风权限
        openMicBtn.isHidden = TLStoryConfiguration.restrictMediaType == .photo
    }
    
    @objc fileprivate func cancelAuthorizationAction() {
        self.delegate?.cancelAuthorizePermissions()
    }
    
    @objc fileprivate func openCameraAction() {
        TLAuthorizedManager.requestAuthorization(with: .camera) { (type, success) in
            if !success {
                return
            }
            self.openCameraBtn.isEnabled = true
            self.openCameraBtn.isSelected = true
            self.openCameraBtn.sizeToFit()
            self.openCameraBtn.centerX = self.view.width / 2
            self.delegate?.requestCameraAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    @objc fileprivate func openMicAction() {
        TLAuthorizedManager.requestAuthorization(with: .mic) { (type, success) in
            if !success {
                return
            }
            self.openMicBtn.isEnabled = true
            self.openMicBtn.isSelected = true
            self.openMicBtn.sizeToFit()
            self.openMicBtn.centerX = self.view.width / 2
            self.delegate?.requestMicAuthorizeSuccess()
            self.dismiss()
        }
    }
    
    fileprivate func dismiss() {
        let cameraAuthorization = TLAuthorizedManager.checkAuthorization(with: .camera)
        let micAuthorization = TLAuthorizedManager.checkAuthorization(with: .mic)
        // 只能拍摄照片时，申请了相机的权限就行
        let authorization = TLStoryConfiguration.restrictMediaType == .photo ? cameraAuthorization : cameraAuthorization && micAuthorization
        if authorization {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.alpha = 0
            }, completion: { (x) in
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.delegate?.requestAllAuthorizeSuccess()
            })
        }
    }
}
