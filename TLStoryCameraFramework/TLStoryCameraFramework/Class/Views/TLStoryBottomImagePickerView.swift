//
//  TLStoryBottomImagePickerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import Photos

protocol TLStoryBottomImagePickerViewDelegate: NSObjectProtocol {
    func photoLibraryPickerDidSelectVideo(url:URL)
    func photoLibraryPickerDidSelectPhoto(image:UIImage)
}

class TLStoryBottomImagePickerView: UIView {
    public weak var delegate:TLStoryBottomImagePickerViewDelegate?
    
    fileprivate var collectionView:UICollectionView?
    
    fileprivate var hintLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(colorHex: 0xffffff, alpha: 0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var authorizationBtn:TLButton = {
        let btn = TLButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle(TLStoryCameraResource.string(key: "tl_allow_access_photo"), for: .normal)
        btn.setTitleColor(UIColor.init(colorHex: 0x4797e1, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.isHidden = true
        return btn
    }()
    
    fileprivate var imgs: PHFetchResult<PHAsset>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let collectionHeight = self.height - 23
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 80, height: collectionHeight)
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 23, width: self.width, height: collectionHeight), collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.delegate = self
        collectionView!.dataSource = self;
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.register(TLPhotoLibraryPickerCell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(collectionView!)
        self.addSubview(hintLabel)
        
        self.addSubview(authorizationBtn)
        authorizationBtn.addTarget(self, action: #selector(requestAlbumAuthorization), for: .touchUpInside)
        authorizationBtn.sizeToFit()
        authorizationBtn.center = CGPoint.init(x: self.width / 2, y: self.height - authorizationBtn.height / 2 - 30)
        
    }
    
    public func loadPhotos() {
        if !TLAuthorizedManager.checkAuthorization(with: .album) {
            self.hintLabel.text = TLStoryCameraResource.string(key: "tl_allow_access_album_hint")
            self.hintLabel.font = UIFont.systemFont(ofSize: 15)
            self.hintLabel.sizeToFit()
            self.hintLabel.center = CGPoint.init(x: self.width / 2, y: 20 + self.hintLabel.height / 2)
            self.authorizationBtn.isHidden = false
        }else {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
            
            var predicateFmt: String = ""
            var predicateArgs: [Any] = []
            
            if (TLStoryConfiguration.restrictMediaType == .photo) {
                predicateFmt.append("mediaType = %d")
                predicateArgs.append(PHAssetMediaType.image.rawValue)
            } else if (TLStoryConfiguration.restrictMediaType == .video) {
                predicateFmt.append("mediaType = %d")
                predicateArgs.append(PHAssetMediaType.video.rawValue)
            }
            
            if (!TLStoryConfiguration.photoLibrayShowAllPhotos) {
                if (predicateArgs.count > 0) {
                    predicateFmt.append(" AND ")
                }
                let dayLate = NSDate().addingTimeInterval(-24 * 60 * 60)
                predicateFmt.append("creationDate >= %@")
                predicateArgs.append(dayLate)
            }
            
            if (predicateArgs.count > 0) {
                options.predicate = NSPredicate.init(format: predicateFmt, argumentArray: predicateArgs)
            }
            
            imgs = PHAsset.fetchAssets(with: options)
            
            if self.imgs!.count > 0 {
                self.hintLabel.text = TLStoryConfiguration.photoLibrayShowAllPhotos ? TLStoryCameraResource.string(key: "tl_album") : TLStoryCameraResource.string(key: "tl_last_24_hours")
                self.hintLabel.font = UIFont.systemFont(ofSize: 12)
                self.hintLabel.sizeToFit()
                self.hintLabel.center = CGPoint.init(x: self.width / 2, y: 23 / 2)
            }else {
                self.hintLabel.text = TLStoryConfiguration.photoLibrayShowAllPhotos ? TLStoryCameraResource.string(key: "tl_no_media") : TLStoryCameraResource.string(key: "tl_last_24_hours_no_photo")
                self.hintLabel.font = UIFont.systemFont(ofSize: 12)
                self.hintLabel.sizeToFit()
                self.hintLabel.center = CGPoint.init(x: self.width / 2, y: self.height / 2)
            }
            self.authorizationBtn.isHidden = true
            self.collectionView?.reloadData()
        }
    }
    
    @objc fileprivate func requestAlbumAuthorization() {
        TLAuthorizedManager.requestAuthorization(with: .album) { (type, success) in
            self.loadPhotos()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLStoryBottomImagePickerView: UICollectionViewDelegate, UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs?.count ?? 0
    }
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TLPhotoLibraryPickerCell
        cell.set(asset: self.imgs![indexPath.row])
        return cell
    }
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.imgs![indexPath.row]
        print(asset.mediaType)
        if asset.mediaType == .video {
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (ass, mix, map) in
                guard let url = (ass as? AVURLAsset)?.url else {
                    return
                }
                if (asset.duration < TLStoryConfiguration.minVideoTime) {
                    let text = String.init(format: TLStoryCameraResource.string(key: "tl_select_video_too_short"), "\(TLStoryConfiguration.minVideoTime)")
                    DispatchQueue.main.async {
                        JLHUD.show(text: text, delay: 1.5)
                    }
                    return
                }
                if (asset.duration > TLStoryConfiguration.maxVideoTime) {
                    let text = String.init(format: TLStoryCameraResource.string(key: "tl_select_video_too_long"), "\(TLStoryConfiguration.maxVideoTime)")
                    DispatchQueue.main.async {
                        JLHUD.show(text: text, delay: 1.5)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.delegate?.photoLibraryPickerDidSelectVideo(url: url)
                }
            }
        }
        
        if asset.mediaType == .image {
            let imgSize = CGSize.init(width: asset.pixelWidth, height: asset.pixelHeight)
            let scale = imgSize.width / imgSize.height;
            let targetSize = TLStoryConfiguration.outputPhotoSize
            
            let newWidth = max(min(imgSize.width, targetSize.width), targetSize.width);
            let newHeight = max(min(imgSize.height, targetSize.height), targetSize.height);
            
            let newSize = scale > 1 ? CGSize.init(width: newWidth, height: newWidth / scale) : CGSize.init(width: newHeight * scale, height: newHeight)
            
            let option = PHImageRequestOptions.init();
            option.isSynchronous = true
            option.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: option, resultHandler: { (image, info) in
                guard let img = image else {
                    return
                }
                DispatchQueue.main.async {
                    self.delegate?.photoLibraryPickerDidSelectPhoto(image: img)
                }
            })
        }
    }
}


class TLPhotoLibraryPickerCell: UICollectionViewCell {
    fileprivate lazy var thumImgview:UIImageView = {
        let imgView = UIImageView.init()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    fileprivate lazy var durationLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    public var asset:PHAsset?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(thumImgview)
        thumImgview.frame = self.bounds
        
        self.contentView.addSubview(durationLabel)
    }
    
    public func set(asset:PHAsset) {
        self.asset = asset
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: self.size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, nfo) in
            self.thumImgview.image = image
        }
        
        let time = Int(asset.duration)
        let h = time / 3600
        let min = Int((time - h * 3600) / 60)
        let s = Int((time - h * 3600) % 60)
        let hourStr = h <= 0 ? "" : h < 10 ? "0\(h):" : "\(h):"
        let minStr = min <= 0 ? "0:" : min < 10 ? "0\(min):" : "\(min):"
        let sStr = s <= 0 ? "" : s < 10 ? "0\(s)" : "\(s)"
        
        durationLabel.isHidden = asset.mediaType != .video || time == 0
        durationLabel.text = hourStr + minStr + sStr
        durationLabel.sizeToFit()
        durationLabel.center = CGPoint.init(x: self.width - durationLabel.width / 2 - 5, y: self.height - durationLabel.height / 2 - 5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
