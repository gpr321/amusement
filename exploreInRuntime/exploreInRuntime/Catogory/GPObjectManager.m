//
//  GPObjectManager.m
//  exploreInRuntime
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "GPObjectManager.h"
@interface GPObjectManager ()

@property (nonatomic,strong) NSArray *foundationTypes;

@property (nonatomic,strong) NSArray *baseTypes;

@end

@implementation GPObjectManager

singtonImplement(objectManager)

- (NSArray *)foundationTypes{
    if ( _foundationTypes == nil ) {
        _foundationTypes = @[@"NSObject", @"NSNumber",@"NSArray", @"NSURL", @"NSMutableURL",@"NSMutableArray",@"NSData",@"NSMutableData",@"NSDate",@"NSDictionary",@"NSMutableDictionary",@"NSString",@"NSMutableString",@"NSException"];
    }
    return _foundationTypes;
}



@end
