//
//  Student.m
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "Student.h"
#import "NSObject+Notification.h"

@implementation Student

- (instancetype)initWithName:(NSString *)name{
    if ( self = [super init] ) {
        self.name = name;
    }
    return self;
}

+ (instancetype)studentWithName:(NSString *)name{
    return [[self alloc]initWithName:name];
}

- (void)observerDidreceiveNotification:(NSDictionary *)userInfo{
    NSLog(@"%@ 收到通知了",self.name);
}

- (void)sayHi{
    NSLog(@"Student sayHi");
}

- (void)sayHello{
    NSLog(@"Student sayHello");
}

+ (void)sayHaha{
    NSLog(@"Student haha");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"%s",__FUNCTION__);
    return [super methodSignatureForSelector:aSelector];
}

@end
