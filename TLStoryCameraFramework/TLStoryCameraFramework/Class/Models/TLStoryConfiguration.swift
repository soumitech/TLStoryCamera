//
//  TLStoryConfiguration.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

public class TLStoryConfiguration: NSObject {
    //是否开启美颜
    public static var openBeauty:Bool = false
    
    // 视频的最长时间
    public static var maxVideoTime: TimeInterval = 30
    
    // 视频的最短时间
    public static var minVideoTime: TimeInterval = 5
    
    //<此时间都是拍照
    public static var asPhotoValveTime:TimeInterval = 0.1
    
    public static var showCameraBtnHint: Bool = true
    
    // false: Show last 4 hours, true: show all photos
    public static var photoLibrayShowAllPhotos: Bool = true
    
    //最大镜头焦距
    public static var maxVideoZoomFactor:CGFloat = 20
    
    // nil为不限制
    // TODO: move it to viewController instead of global setting
    public static var restrictMediaType: TLStoryType? = nil
    
    //视频输入
    public static var videoSetting:[String : Any] = [
        AVVideoCodecKey : AVVideoCodecH264,
        AVVideoWidthKey : 720,
        AVVideoHeightKey: 1280,
        AVVideoCompressionPropertiesKey:
            [
                AVVideoProfileLevelKey : AVVideoProfileLevelH264Main31,
                AVVideoAllowFrameReorderingKey : false,
                //码率
                AVVideoAverageBitRateKey : 720 * 1280 * 3
        ]
    ]
    
    //音频输入
    public static var audioSetting:[String : Any] = [
        AVFormatIDKey : kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 2,
        AVSampleRateKey : 16000,
        AVEncoderBitRateKey : 32000
    ]
    
    //视频采集格式
    public static var videoFileType:String = AVFileType.mov.rawValue
    
    //视频采集尺寸
    public static var captureSessionPreset:String = AVCaptureSession.Preset.hd1280x720.rawValue
    
    //输出的视频尺寸
    public static var outputVideoSize:CGSize = CGSize.init(width: 720, height: 1280)
    
    //输出的图片尺寸
    public static var outputPhotoSize:CGSize = CGSize.init(width: 1080, height: 1920)
    
    //视频路径
    public static var videoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyvideo")
    
    //图片路径
    public static var photoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyphoto")

    //最大笔触
    public static var maxDrawLineWeight:CGFloat = 30
    //最小笔触
    public static var minDrawLineWeight:CGFloat = 5
    //默认笔触
    public static var defaultDrawLineWeight:CGFloat = 5
    
    //最大字体大小
    public static var maxTextWeight:CGFloat = 60
    //最小字体大小
    public static var minTextWeight:CGFloat = 12
    //默认字体大小
    public static var defaultTextWeight:CGFloat = 30
    
    //导出水印
    public static var watermarkImage:UIImage? = UIImage.init(named: "watermark")
    //导出水印位置
    public static var watermarkPosition:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 10)
}
