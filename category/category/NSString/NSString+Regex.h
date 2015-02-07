//
//  NSString+Regex.h
//  category
//
//  Created by mac on 15-2-7.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regex)

/**
 *  根据传进来的正则表达式判断当前字符串是否合法
 *
 *  @param regex 正则表达式
 *
 *  @return YES : 合法 ,否则 不合法
 */
- (BOOL)matchWithRegex:(NSString *)regex;

@end
