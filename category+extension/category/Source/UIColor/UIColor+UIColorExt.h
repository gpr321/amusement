//
//  UIColor+UIColorExt.h
//  doctorApp
//
//  Created by richardYang on 3/23/14.
//  Copyright (c) 2014 richardYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorExt)
+ (UIColor *)colorFromRGB:(NSInteger)rgbValue withAlpha:(CGFloat)alpha;
+ (UIColor *)colorFromRGB:(NSInteger)rgbValue;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexStringWithAlpha:(NSString *)hexString;

@end
