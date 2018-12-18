//
//  TLStoryCameraResource.swift
//  TLStoryCameraFramework
//
//  Created by james on 2018/12/18.
//  Copyright © 2018 com.garry. All rights reserved.
//

import Foundation

class TLStoryCameraResource {
    private static let defaultResourceBundleName = "TLStoryCameraResources"
    
    public static func path(forResource: String, ofType: String, inDirectory: String?) -> String? {
        // Search user defined bundle firstly
        if let bundlePath = Bundle.main.path(forResource: TLStoryCameraResource.defaultResourceBundleName, ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
            if let resPath = bundle.path(forResource: forResource, ofType: ofType, inDirectory: inDirectory) {
                return resPath
            }
        }
        
        // fallback to framework's default bundle
        let frameworkBundle = Bundle(path: Bundle(for: TLStoryCameraResource.self).path(forResource: TLStoryCameraResource.defaultResourceBundleName, ofType: "bundle")!)!
        return frameworkBundle.path(forResource: forResource, ofType: ofType, inDirectory: inDirectory)
    }
}
