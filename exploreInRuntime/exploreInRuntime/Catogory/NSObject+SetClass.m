//
//  NSObject+SetClass.m
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSObject+SetClass.h"
#import <objc/runtime.h>

@implementation NSObject (SetClass)

- (void)setClass:(Class)aClass{
    NSAssert(class_getInstanceSize([self class]) == class_getInstanceSize(aClass), @"class size must be equaled");
    object_setClass(self, aClass);
}

@end
