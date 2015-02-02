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
+ (instancetype)curentDateComponnents:(NSCalendarUnit)unitFlags;
@end
