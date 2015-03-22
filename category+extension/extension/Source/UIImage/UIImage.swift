//
//  UIImage.swift
//  extension
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

import Foundation

extension UIImage {
    class func originalImageWithName(imageName: String) -> UIImage {
        let img = UIImage(named: imageName)
        return img!.imageWithRenderingMode(.AlwaysOriginal)
    }
}
