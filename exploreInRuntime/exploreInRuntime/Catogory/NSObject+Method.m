//
//  NSObject+Method.m
//  exploreInRuntime
//
//  Created by mac on 15-1-28.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSObject+Method.h"
#import <objc/runtime.h>

@implementation NSObject (Method)



+ (void)printObjecytMethods{
    unsigned int count = 0;
    // 获得方法列表
    Method *methods = class_copyMethodList([self class], &count);
    // 遍历方法列表
    SEL sel = NULL;
    const char *selName = NULL;
    for (unsigned int i = 0; i < count; i++) {
        sel = method_getName(methods[i]);
        selName = sel_getName(sel);
        NSLog(@"%s",selName);
    }
    // 释放方法列表
    free(methods);
}

+ (IMP)swizzleSelector:(SEL)orignSelector WithIMP:(IMP)newIMP{
    Method method = class_getInstanceMethod([self class], orignSelector);
    /**
        做了部操作 :
            (1) 如果类对象中存在 一个 selector -> IMP,则添加不成功,这是候,我们只需要把implemention 中的 IMP 替换即可
     */
    if ( class_addMethod([self class], orignSelector, newIMP, method_getTypeEncoding(method)) == NO ) {
        method_setImplementation(method, newIMP);
    }
    return newIMP;
}

+ (void)swizzleOriginSelector:(SEL)orignSelector WithSelector:(SEL)curSelector{
    Method currMethod = class_getInstanceMethod([self class], curSelector);
    Method orginMethod = class_getInstanceMethod([self class], orignSelector);
    IMP currIMP = method_getImplementation(currMethod);
    IMP originIMP = method_getImplementation(orginMethod);

    [self swizzleSelector:orignSelector WithIMP:currIMP];
    [self swizzleSelector:curSelector WithIMP:originIMP];
}

@end
