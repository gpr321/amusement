//
//  NSDateComponents+CurDateAndTime.h
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (CurDateAndTime)

/**
 *  根据用户给定的参数获取当前日期时间组件
	*
 *  @param unitFlags 用户给定得参数
 *
 *  @return 时间组件
 */
+ (instancetype)gp_curentDateComponnents:(NSCalendarUnit)unitFlags;

/**
 *  根据给定的时间计算出距离现在的时间日期
 *
 *  @param date 给定的时间
 *  @param units 给定时间组件选项
 *  @return 时间组件
 */
+ (instancetype)gp_dateComponentsFromNowWithDate:(NSDate *)date componentUnits:(NSCalendarUnit)units;

/**
 *  根据给定的日期字符串和给定的日期格式计算出距离现在的时间日期
 *
 *  @param dateStr       给定的时间字符串
 *  @param dateFormatter 日期格式
 *  @param units         给定时间组件选项
 *
 *  @return 时间组件
 */
+ (instancetype)gp_dateComponentsFromNowWithDateString:(NSString *)dateStr formatter:(NSString *)dateFormatter componentUnits:(NSCalendarUnit)units;
@end
