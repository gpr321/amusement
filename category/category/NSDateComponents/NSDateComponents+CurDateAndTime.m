//
//  NSDateComponents+CurDateAndTime.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSDateComponents+CurDateAndTime.h"

@implementation NSDateComponents (CurDateAndTime)

/**
 *  根据用户给定的参数获取当前日期时间组件
	*
 *  @param unitFlags 用户给定得参数
 *
 *  @return 时间组件
 */
+ (instancetype)curentDateComponnents:(NSCalendarUnit)unitFlags{
    // 获取时间
    NSCalendar *ca = [NSCalendar currentCalendar];
    // 获取时分秒的时间组件
    return [ca components:unitFlags fromDate:[NSDate date]];
}

@end
