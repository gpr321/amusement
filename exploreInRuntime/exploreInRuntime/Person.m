//
//  Person.m
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "Person.h"
#import "NSObject+Method.h"

@implementation Person

//+ (void)load{
//    [self swizzleOriginSelectorIMP:@selector(sayHi) WithSelector:@selector(sayHello)];
//}

- (void)sayHi{
    NSLog(@"Person sayHi");
}

- (void)sayHello{
    NSLog(@"sayHello");
}

+ (void)sayHaha{
    NSLog(@"haha");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"%s",__FUNCTION__);
    return [super methodSignatureForSelector:aSelector];
}


@end
