//
//  NetworkStatusMonitor.m
//  NetworkStatusDemo
//
//  Created by imac on 15/4/17.
//  Copyright (c) 2015年 Nickyxu. All rights reserved.
//

#import "NetworkStatusMonitor.h"

@implementation NetworkStatusMonitor

+(void)StartWithBlock:(void (^)(NSInteger))block{
    static  NetworkStatusMonitor *monitor;
    if (!monitor){
        monitor = [[NetworkStatusMonitor alloc]init];
    }
    monitor.callBackBlock = block;
    [[NSNotificationCenter defaultCenter]addObserver:monitor selector:@selector(applicationNetworkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    [reachability startMonitoring];
}
-(void)applicationNetworkStatusChanged:(NSNotification*)userinfo{
    NSInteger status = [[[userinfo userInfo]objectForKey:@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            [self withoutNetwork];
            return;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [self wwanNetwork];
            return;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self wifiNetwork];
            return;
        case AFNetworkReachabilityStatusUnknown:
        default:
            [self unknowNetwork];
            return;
    }
}
-(void)withoutNetwork{
    self.callBackBlock (WithoutNetwork);
}
-(void)wwanNetwork{
    CTTelephonyNetworkInfo *networkStatus = [[CTTelephonyNetworkInfo alloc]init];
    NSString *currentStatus  = networkStatus.currentRadioAccessTechnology;
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]){
        self.callBackBlock(GPRS);
        //GPRS网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]){
        self.callBackBlock(Edge);
        //2.75G的EDGE网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        self.callBackBlock(WCDMA);
        //3G WCDMA网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        self.callBackBlock(HSDPA);
        //3.5G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        self.callBackBlock(HSUPA);
        //3.5G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        self.callBackBlock(CDMA1xNetwork);
        //CDMA2G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        self.callBackBlock(CDMAEVDORev0);
        //CDMA的EVDORev0(应该算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        self.callBackBlock(CDMAEVDORevA);
        //CDMA的EVDORevA(应该也算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        self.callBackBlock(CDMAEVDORevB);
        //CDMA的EVDORev0(应该还是算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        self.callBackBlock(HRPD);
        //HRPD网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        self.callBackBlock(LTE);
        //LTE4G网络
        return;
    }
    
    /*==
    取运营商名字  Objective.subscriberCellularProvider.carrierName
     */
}
-(void)wifiNetwork{
    self.callBackBlock (WifiNetwork);
}
-(void)unknowNetwork{
    self.callBackBlock(UnknowNetwork);
}

@end
