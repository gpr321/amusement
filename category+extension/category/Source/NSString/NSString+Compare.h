//
//  NSString+Compare.h
//  category
//
//  Created by mac on 15-2-9.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Compare)

/**
 *  使用当前(日期)字符串与给定的日期相比(注意当前日期字符串格式要与给定的格式字符串格式一致)
 *
 *  @param date            给定的日期
 *  @param formatterString 日期格式
 *
 *  @return 比较结果
 */
- (NSComparisonResult)gp_compareWithDate:(NSDate *)date dateFormatter:(NSString *)formatterString;

@end
