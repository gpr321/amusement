//
//  ViewController.m
//  exploreInRuntime
//
//  Created by mac on 15-1-28.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+GP.h"
#import "Person.h"
#import "Student.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self test3];
}

// 偷换方法
- (void)test3{
    [Person swizzleOriginSelectorIMP:@selector(sayHello) WithSelector:@selector(sayHi)];
    Person *p = [[Person alloc] init];
    [p sayHello];
    [p sayHi];
}

// 偷换isa指针
- (void)test2{
    Person *p = [[Person alloc] init];
    Student *s = [[Student alloc] init];
    [p setClass:[Student class]];
    
    [s sayHello];
    [p sayHello];
}

// 实现一对多的观察者模式
- (void)test1{
    Person *p = [[Person alloc] init];
    
    Student *s1 = [Student studentWithName:@"student-1"];
    Student *s2 = [Student studentWithName:@"student-2"];
    Student *s3 = [Student studentWithName:@"student-3"];
    
    [p addNotificationObserver:s1];
    [p addNotificationObserver:s2];
    [p addNotificationObserver:s3];
    
    [p triggerNotificationWithUserInfo:nil];
}

@end
