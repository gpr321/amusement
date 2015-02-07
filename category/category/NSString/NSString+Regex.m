//
//  NSString+Regex.m
//  category
//
//  Created by mac on 15-2-7.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)

- (BOOL)matchWithRegex:(NSString *)regex{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
    return [predicate evaluateWithObject:self];
}

@end
