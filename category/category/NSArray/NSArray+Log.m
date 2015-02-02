//
//  NSArray+Log.m
//  04-加载网站数据(网络)
//
//  Created by mac on 15-1-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale{
    NSMutableString *des = [NSMutableString string];
    [des appendString:@"(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [des appendString:[NSString stringWithFormat:@"%@",obj]];
    }];
    
    [des appendString:@")\n"];
    return des;
}

@end
