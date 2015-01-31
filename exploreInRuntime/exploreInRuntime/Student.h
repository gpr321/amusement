//
//  Student.h
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Notification.h"

@interface Student : NSObject

@property (nonatomic,assign) NSInteger age;

@property (nonatomic,copy) NSString *name;

+ (instancetype)studentWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

- (void)sayHi;

- (void)sayHello;

+ (void)sayHaha;


@end
