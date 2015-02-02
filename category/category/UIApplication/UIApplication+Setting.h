//
//  UIApplication+Setting.h
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Setting)

/**
 *  设置应用badgeNumber
 *  在iOS8.0之后设置badgeNumber要对用户申请权限
 *
 *  @param bangeNumber badgeNumber的值
 */
+ (void)setAppBadgeNumber:(NSInteger)bangeNumber;

@end
