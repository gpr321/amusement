//
//  Person.m
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "Person.h"
#import "NSObject+GP.h"

@implementation Person

//+ (void)load{
//    [self swizzleOriginSelectorIMP:@selector(sayHello) WithSelector:@selector(sayHaha)];
//}

- (void)sayHi{
    NSLog(@"Person sayHi");
}

- (void)sayHello{
    NSLog(@"Person sayHello");
}

+ (void)sayHaha{
    NSLog(@"Person haha");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"%s",__FUNCTION__);
    return [super methodSignatureForSelector:aSelector];
}


@end
