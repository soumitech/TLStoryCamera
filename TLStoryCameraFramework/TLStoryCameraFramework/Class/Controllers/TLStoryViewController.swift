//
//  TLStoryCameraViewController.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

public enum TLStoryType {
    case video
    case photo
}

public protocol TLStoryViewDelegate: NSObjectProtocol {
    func storyViewRecording(running:Bool)
    func storyViewDidPublish(type:TLStoryType, url:URL?)
    func storyViewClose()
}

public class TLStoryViewController: UIViewController {
    public weak var delegate:TLStoryViewDelegate?

    fileprivate var containerView = UIView.init()
    
    fileprivate var bottomImagePicker:TLStoryBottomImagePickerView?
    
    fileprivate var captureView:TLStoryCapturePreviewView?
    
    fileprivate var outputView:TLStoryOverlayOutputView?
    
    fileprivate var editContainerView:TLStoryEditContainerView?
    
    fileprivate var controlView:TLStoryOverlayControlView?
    
    fileprivate var editView:TLStoryOverlayEditView?
    
    fileprivate var textStickerView:TLStoryOverlayTextStickerView?
    
    fileprivate var imageStickerView:TLStoryOverlayImagePicker?
    
    fileprivate var blurCoverView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    
    fileprivate var swipeUp:UISwipeGestureRecognizer?
    
    fileprivate var swipeDown:UISwipeGestureRecognizer?
        
    fileprivate var output = TLStoryOutput.init()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.isUserInteractionEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        bottomImagePicker = TLStoryBottomImagePickerView.init(frame: CGRect.init(x: 0, y: self.view.safeRect.height - 165, width: self.view.safeRect.width, height: 165))
        bottomImagePicker?.delegate = self
        self.view.addSubview(bottomImagePicker!)
        
        view.addSubview(containerView)
        containerView.frame = self.view.safeRect
        
        captureView = TLStoryCapturePreviewView.init(frame: self.containerView.bounds)
        containerView.addSubview(captureView!)
        
        outputView = TLStoryOverlayOutputView.init(frame: self.containerView.bounds)
        outputView!.isHidden = true
        containerView.addSubview(outputView!)
        
        editContainerView = TLStoryEditContainerView.init(frame: self.containerView.bounds)
        editContainerView!.delegate = self
        outputView!.addSubview(editContainerView!)
        
        controlView = TLStoryOverlayControlView.init(frame: self.containerView.bounds)
        controlView!.delegate = self
        controlView!.isHidden = true
        containerView.addSubview(controlView!)
        
        editView = TLStoryOverlayEditView.init(frame: self.containerView.bounds)
        editView!.delegate = self
        editView!.isHidden = true
        containerView.addSubview(editView!)
        
        textStickerView = TLStoryOverlayTextStickerView.init(frame: self.containerView.bounds)
        textStickerView!.delegate = self
        textStickerView!.isHidden = true
        containerView.addSubview(textStickerView!)
        
        imageStickerView = TLStoryOverlayImagePicker.init(frame: self.containerView.bounds)
        imageStickerView?.delegate = self
        imageStickerView!.isHidden = true
        containerView.addSubview(imageStickerView!)
        
        containerView.addSubview(blurCoverView)
        blurCoverView.isUserInteractionEnabled = true
        blurCoverView.frame = containerView.bounds
        
        swipeUp = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeAction))
        swipeUp!.direction = .up
        self.controlView?.addGestureRecognizer(swipeUp!)
                
        self.checkAuthorized()
    }
    
    public func resumeCamera(open:Bool) {
        self.captureView!.cameraSwitch(open: open)

        if open {
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 0
            }, completion: { (x) in
                if x {
                    self.blurCoverView.isHidden = true
                }
            })
            self.controlView?.beginHintAnim()
        }else {
            self.blurCoverView.alpha = 1
            self.blurCoverView.isHidden = false
        }
    }
    
    @objc fileprivate func swipeAction(sender:UISwipeGestureRecognizer) {
        if sender.direction == .up && self.containerView.y == self.view.safeRect.origin.y {
            self.bottomImagePicker(hidden: false)
            return
        }
        
        if sender.direction == .down {
            self.bottomImagePicker(hidden: true)
            return
        }
    }
        
    fileprivate func bottomImagePicker(hidden:Bool) {
        if !hidden {
            blurCoverView.isHidden = false
            blurCoverView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 1
                self.containerView.y -= 165 + self.view.safeRect.origin.y
            }) { (x) in
                self.swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(self.swipeAction))
                if let swipeDown = self.swipeDown {
                    swipeDown.direction = .down
                    self.blurCoverView.addGestureRecognizer(swipeDown)
                }
                self.bottomImagePicker?.loadPhotos()
            }
        } else {
            blurCoverView.alpha = 1
            UIView.animate(withDuration: 0.25, animations: {
                self.blurCoverView.alpha = 0
                self.containerView.y = self.view.safeRect.origin.y
            }, completion: { (x) in
                self.blurCoverView.isHidden = true
                self.blurCoverView.alpha = 1
                if let swipeDown = self.swipeDown {
                    self.blurCoverView.removeGestureRecognizer(swipeDown)
                }
            })
        }
        
        self.delegate?.storyViewRecording(running: !hidden)
    }
    
    fileprivate func checkAuthorized() {
        let cameraAuthorization = TLAuthorizedManager.checkAuthorization(with: .camera)
        let micAuthorization = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        if cameraAuthorization {
            self.cameraStart()
        }
        if micAuthorization {
            captureView!.enableAudio()
        }
        
        let allAuthorization = TLStoryConfiguration.restrictMediaType == .photo ? cameraAuthorization : cameraAuthorization && micAuthorization
        
        if allAuthorization {
            controlView!.isHidden = false
        } else {
            let authorizedVC = TLStoryAuthorizationController()
            authorizedVC.view.frame = self.view.bounds
            authorizedVC.delegate = self
            self.view.addSubview(authorizedVC.view)
            self.addChild(authorizedVC)
        }
    }
    
    fileprivate func cameraStart() {
        if UIDevice.isSimulator {
            return
        }
        
        captureView!.initCamera()
        captureView!.startCapture()
    }
    
    fileprivate func previewDispay<T>(input:T, type:TLStoryType) {
        self.outputView!.isHidden = false
        self.output.type = type
        self.editView?.dispaly()
        self.editView?.setAudioEnableBtn(hidden: type == .photo)
        self.controlView?.dismiss()
        self.captureView?.pauseCamera()
        self.delegate?.storyViewRecording(running: true)
        
        if type == .photo, let img = input as? UIImage {
            self.output.image = img
            self.outputView?.display(withPhoto: img)
        }
        
        if type == .video, let url = input as? URL {
            self.output.url = url
            self.outputView?.display(withVideo: url)
        }
    }
    
    fileprivate func previewDismiss() {
        self.outputView!.isHidden = true
        self.editView?.dismiss()
        self.outputView?.reset()
        self.editContainerView?.reset()
        self.textStickerView?.reset()
        self.controlView?.display()
        self.captureView?.resumeCamera()
        self.output.reset()
        self.delegate?.storyViewRecording(running: false)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}

extension TLStoryViewController: TLStoryOverlayControlDelegate {
    func storyOverlayCameraClose() {
        self.delegate?.storyViewClose()
    }
    
    func storyOverlayCameraFocused(point: CGPoint) {
        captureView?.focus(point: point)
    }

    internal func storyOverlayCameraRecordingStart() {
        captureView!.configVideoRecording()
        if TLStoryConfiguration.restrictMediaType != .photo {
            captureView!.configAudioRecording()
        }
        captureView!.startRecording()
    }
    
    internal func storyOverlayCameraSwitch() {
        captureView!.rotateCamera()
    }
    
    internal func storyOverlayCameraZoom(distance: CGFloat) {
        captureView!.camera(distance: distance)
    }
    
    internal func storyOverlayCameraRecordingFinish(type: TLStoryType, recordTime: TimeInterval) {
        let isExpectVideo = TLStoryConfiguration.restrictMediaType == .video || type == .video
        if (isExpectVideo && (type == .photo || recordTime < TLStoryConfiguration.minVideoTime)) {
            let hint = String.init(format: TLStoryCameraResource.string(key: "tl_video_too_short"), "\(round(TLStoryConfiguration.minVideoTime))")
            JLHUD.show(text: hint, delay: 1)
            self.controlView?.dismiss()
            self.captureView?.destroy()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.controlView?.display()
                self.captureView?.resumeCamera()
                self.output.reset()
            }
            return
        }
        
        if type == .photo {
            self.captureView?.capturePhoto(complete: { (image) in
                if let img = image {
                    self.previewDispay(input: img, type: .photo)
                }
            })
        }else {
            self.captureView!.finishRecording(complete: { [weak self] (x) in
                if let url = x {
                    self?.previewDispay(input: url, type: .video)
                }
            })
        }
    }
    internal func storyOverlayCameraFlashChange() -> AVCaptureDevice.TorchMode {
        return self.captureView!.flashStatusChange()
    }
}

extension TLStoryViewController: TLStoryOverlayEditViewDelegate {
    internal func storyOverlayEditPublish() {
        guard let container = self.editContainerView?.getScreenshot() else {
            return
        }
        
        self.editView?.dismiss()
        
        self.output.output(filterNamed: self.outputView!.currentFilterNamed, container: container, callback: { [weak self] (url, type) in
            self?.editView?.dispaly()
            self?.delegate?.storyViewDidPublish(type: type, url: url)
            self?.previewDismiss()
        })
    }
    
    internal func storyOverlayEditSave() {
        let block:(() -> Void) = { () in
            guard let container = self.editContainerView?.getScreenshot() else {
                return
            }
            
            self.editView?.dismiss()
                        
            self.output.saveToAlbum(filterNamed: self.outputView!.currentFilterNamed, container: container, callback: { [weak self] (x) in
                self?.editView?.dispaly()
            })
        }
        
        guard TLAuthorizedManager.checkAuthorization(with: .album) else {
            TLAuthorizedManager.requestAuthorization(with: .album, callback: { (type, success) in
                if success {
                    block()
                }
            })
            return
        }
        
        block()
    }
    
    internal func storyOverlayEditTextEditerDisplay() {
        textStickerView?.show(sticker: nil)
    }
    
    internal func storyOverlayEditStickerPickerDisplay() {
        imageStickerView?.display()
    }
    
    internal func storyOverlayEditDoodleEditable() {
        self.editContainerView?.benginDrawing()
    }
    
    internal func storyOverlayEditClose() {
        self.previewDismiss()
    }
    
    internal func storyOverlayEditAudio(enable: Bool) {
        self.output.audioEnable = enable
        self.outputView?.playerAudio(enable: enable)
    }
}

extension TLStoryViewController: TLStoryOverlayTextStickerViewDelegate {
    internal func textEditerDidCompleteEdited(sticker: TLStoryTextSticker?) {
        if let s = sticker {
            self.editContainerView?.add(textSticker: s)
        }
        editView?.dispaly()
    }
}

extension TLStoryViewController: TLStoryOverlayImagePickerDelegate {
    internal func storyOverlayImagePickerDismiss() {
        editView?.dispaly()
    }

    internal func storyOverlayImagePickerDidSelected(img: UIImage) {
        self.editContainerView?.add(img: img)
    }
}

extension TLStoryViewController: TLStoryEditContainerViewDelegate {
    internal func storyEditSwpieFilter(direction: UISwipeGestureRecognizer.Direction) {
        self.outputView?.switchFilter(direction: direction);
    }
    
    internal func storyEditContainerTap() {
        self.editView?.dismiss()
        self.textStickerView?.show(sticker: nil)
    }

    internal func storyEditContainerSwipeUp() {
        self.editView?.dismiss()
        self.imageStickerView?.display()
    }

    internal func storyEditContainerSticker(editing: Bool) {
        if editing {
            self.editView?.dismiss()
        }else {
            self.editView?.dispaly()
        }
    }

    internal func storyEditContainerEndDrawing() {
        self.editView?.dispaly()
    }

    internal func storyEditContainerTextStickerBeEditing(sticker: TLStoryTextSticker) {
        self.editView?.dismiss()
        self.textStickerView?.show(sticker: sticker)
    }
}

extension TLStoryViewController: TLStoryBottomImagePickerViewDelegate {
    func photoLibraryPickerDidSelectPhoto(image: UIImage) {
        self.bottomImagePicker(hidden: true)
        self.previewDispay(input: image, type: .photo)
    }

    func photoLibraryPickerDidSelectVideo(url: URL) {
        self.bottomImagePicker(hidden: true)
        self.previewDispay(input: url, type: .video)
    }
}

extension TLStoryViewController: TLStoryAuthorizedDelegate {
    internal func requestMicAuthorizeSuccess() {
        captureView!.enableAudio()
    }
    
    internal func requestCameraAuthorizeSuccess() {
        self.cameraStart()
    }
    
    internal func requestAllAuthorizeSuccess() {
        self.controlView!.isHidden = false
    }
    
    internal func cancelAuthorizePermissions() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
