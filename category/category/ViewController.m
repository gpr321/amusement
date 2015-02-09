//
//  ViewController.m
//  category
//
//  Created by mac on 15-2-2.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Compare.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *dateStr = @"2015-02-08";
    NSString *formatter = @"yyyy-MM-dd";
    NSComparisonResult result = [dateStr gp_compareWithDate:[NSDate date] dateFormatter:formatter];
    
    if ( result == NSOrderedAscending ) {
        NSLog(@"小于");
    } else if ( result == NSOrderedDescending){
        NSLog(@"大于");
    } else if (result == NSOrderedSame) {
        NSLog(@"等于");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
