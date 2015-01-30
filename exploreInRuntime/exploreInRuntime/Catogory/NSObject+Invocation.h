//
//  NSObject+Invocation.h
//  23-网易新闻
//
//  Created by mac on 15-1-26.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Invocation)

/**
 *  根据传进来的 selector 和 参数类型执行相应地方法并获得返回值
 *
 *  @param selector 要执行的方法
 *  @param args     参数列表
 *
 *  @return 如果该方法没有返回值 或者 该方法不存在 则返回空
 */
- (id)performSelector:(SEL)selector withArguments:(NSArray *)args;

@end
