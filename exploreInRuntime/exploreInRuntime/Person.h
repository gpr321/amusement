//
//  Person.h
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Student;

@interface Person : NSObject

@property (nonatomic,assign) NSInteger age;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) float height;

@property (nonatomic,assign) double tall;

@property (nonatomic,assign) int tall1;

@property (nonatomic,assign) long tall2;

@property (nonatomic,assign) long long tall3;

@property (nonatomic,assign) BOOL flag;

- (void)sayHi;

- (void)sayHello;

+ (void)sayHaha;

@end
