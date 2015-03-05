//
//  ViewController.m
//  05-Reachability
//
//  Created by 刘凡 on 15/1/13.
//  Copyright (c) 2015年 joyios. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()
@property (nonatomic, strong) Reachability *reachabilityManager;
@end

@implementation ViewController

- (Reachability *)reachabilityManager {
    if (_reachabilityManager == nil) {
        _reachabilityManager = [Reachability reachabilityWithHostName:@"baidu.com"];
    }
    return _reachabilityManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkReachStatus) name:kReachabilityChangedNotification object:nil];
    [self.reachabilityManager startNotifier];
}

- (void)dealloc {
    [self.reachabilityManager stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self checkReachStatus];
}

- (void)checkReachStatus {
    switch (self.reachabilityManager.currentReachabilityStatus) {
        case NotReachable:
            NSLog(@"无连接");
            break;
        case ReachableViaWiFi:
            NSLog(@"不花钱");
            break;
        case ReachableViaWWAN:
            NSLog(@"花钱");
            break;
    }
}

@end
