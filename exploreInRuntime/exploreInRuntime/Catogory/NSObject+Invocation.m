//
//  NSObject+Invocation.m
//  23-网易新闻
//
//  Created by mac on 15-1-26.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSObject+Invocation.h"

@implementation NSObject (Invocation)

/**
 *  根据传进来的 selector 和 参数类型执行相应地方法并获得返回值
 *
 *  @param selector 要执行的方法
 *  @param args     参数列表
 *
 *  @return 如果该方法没有返回值 或者 该方法不存在 则返回空
 */
- (id)performSelector:(SEL)selector withArguments:(NSArray *)args{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if ( signature ) {
        NSInvocation *invacation = [NSInvocation invocationWithMethodSignature:signature];
        [invacation setTarget:self];
        [invacation setSelector:selector];
        // 设置参数
        for (NSInteger i = 0; i < args.count; i++) {
            id arg = args[i];
            [invacation setArgument:&arg atIndex:i + 2];
        }
        // 执行方法
        [invacation invoke];
        // 取出返回值
        if ( signature.methodReturnLength ) {
            id returnValue;
            [invacation getReturnValue:&returnValue];
            return returnValue;
        }
    }
    return nil;
}

@end
