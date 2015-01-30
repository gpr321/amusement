//
//  ViewController.m
//  exploreInRuntime
//
//  Created by mac on 15-1-28.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Method.h"
#import "Person.h"
#import "Student.h"
#import "NSObject+SetClass.h"
#import "NSObject+Property.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    Person *p = [[Person alloc] init];
    p.name = @"jack";
    p.age = 50;
    p.height = 100;
    [p enumerateProperNameAndValueUsingBlock:^(NSString *name, id value,NSString *typeEncode) {
        NSLog(@"%@--%@",value,typeEncode);
    }];
//    NSLog(@"%@",[Person privatePropertitesList]);
}

@end
