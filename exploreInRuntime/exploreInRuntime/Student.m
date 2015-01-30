//
//  Student.m
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "Student.h"

@implementation Student

- (void)sayHi{
    NSLog(@"Student sayHi");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"%s",__FUNCTION__);
    return [super methodSignatureForSelector:aSelector];
}

@end
