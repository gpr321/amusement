//
//  Dictionary+Extension.swift
//  extension
//
//  Created by mac on 15/3/13.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

import Foundation

extension Dictionary {
    ///  将字典合并到当前字典
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}