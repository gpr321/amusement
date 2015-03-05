//
//  NSDateComponents+CurDateAndTime.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSDateComponents+CurDateAndTime.h"

@implementation NSDateComponents (CurDateAndTime)

+ (instancetype)gp_curentDateComponnents:(NSCalendarUnit)unitFlags{
    // 获取时间
    NSCalendar *ca = [NSCalendar currentCalendar];
    // 获取时分秒的时间组件
    return [ca components:unitFlags fromDate:[NSDate date]];
}

+ (instancetype)gp_dateComponentsFromNowWithDate:(NSDate *)date componentUnits:(NSCalendarUnit)units{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:units fromDate:date toDate:[NSDate date] options:kNilOptions];
}

+ (instancetype)gp_dateComponentsFromNowWithDateString:(NSString *)dateStr formatter:(NSString *)dateFormatter componentUnits:(NSCalendarUnit)units{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = dateFormatter;
    NSDate *date = [fmt dateFromString:dateStr];
    return [self gp_dateComponentsFromNowWithDate:date componentUnits:units];
}

@end
