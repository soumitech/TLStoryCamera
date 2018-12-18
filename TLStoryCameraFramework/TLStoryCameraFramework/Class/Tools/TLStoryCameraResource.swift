//
//  TLStoryCameraResource.swift
//  TLStoryCameraFramework
//
//  Created by james on 2018/12/18.
//  Copyright © 2018 com.garry. All rights reserved.
//

import Foundation

public class TLStoryCameraResource {
    public static let defaultResourceBundleName = "TLStoryCameraResources"
    
    public static let userResourceBundle: Bundle = {
        return Bundle.main
    }()
    
    public static let userTLStoryCameraResourceBundle: Bundle? = {
        if let bundlePath = Bundle.main.path(forResource: TLStoryCameraResource.defaultResourceBundleName, ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return nil
    }()
    
    public static let frameworkResourceBundle: Bundle = {
        return Bundle(path: Bundle(for: TLStoryCameraResource.self).path(forResource: TLStoryCameraResource.defaultResourceBundleName, ofType: "bundle")!)!
    }()
    
    /// allow user to change bundle search order, so other framework can include it and customize resource
    public static var stringSearchBundles = [userResourceBundle, userTLStoryCameraResourceBundle, frameworkResourceBundle]
    
    /// other resource, like image, plist search order
    public static var resourceSearchBundles = [userTLStoryCameraResourceBundle, frameworkResourceBundle]
    
    public static func path(forResource: String, ofType: String, inDirectory: String?) -> String? {
        for bundle in resourceSearchBundles {
            if let path = bundle?.path(forResource: forResource, ofType: ofType, inDirectory: inDirectory) {
                return path
            }
        }
        return nil
    }
    
    public static func string(key: String) -> String {
        for bundle in stringSearchBundles {
            guard let b = bundle else {
                continue
            }
            let s = NSLocalizedString(key, tableName: "Localizable", bundle: b, value: "", comment: "")
            if (s != "" && s != key) {
                return s
            }
        }
        return key
    }
}
