//
//  NSObject+SetClass.h
//  exploreInRuntime
//
//  Created by mac on 15-1-29.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SetClass)

/**
 *  更换isa指针
 *
 *  @param aClass 要替换进去的isa指针
 */
- (void)setClass:(Class)aClass;

@end
