//
//  NSString+Compare.m
//  category
//
//  Created by mac on 15-2-9.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSString+Compare.h"

@implementation NSString (Compare)

- (NSComparisonResult)gp_compareWithDate:(NSDate *)date dateFormatter:(NSString *)formatterString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatterString;
    NSString *dateStr = [formatter stringFromDate:date];
    return  [self compare:dateStr];
}

@end
