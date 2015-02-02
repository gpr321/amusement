//
//  UIApplication+Setting.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "UIApplication+Setting.h"

@implementation UIApplication (Setting)

/**
 *  设置应用badgeNumber
 *  在iOS8.0之后设置badgeNumber要对用户申请权限
 *
 *  @param bangeNumber badgeNumber的值
 */
+ (void)setAppBadgeNumber:(NSInteger)bangeNumber{
    UIApplication *app = [UIApplication sharedApplication];
#ifdef __IPHONE_8_0
    // 获取系统版本号
    CGFloat versionNum = [UIDevice currentDevice].systemVersion.floatValue;
    // 如果系统版本号大于8.0之后要申请权限
    if ( versionNum >= 8.0 ) {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        // 注册通知申请权限
        [app registerUserNotificationSettings:setting];
    }
#endif
    app.applicationIconBadgeNumber = bangeNumber;
}

@end
