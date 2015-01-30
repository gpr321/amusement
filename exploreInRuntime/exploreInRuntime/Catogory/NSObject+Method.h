//
//  NSObject+Method.h
//  exploreInRuntime
//
//  Created by mac on 15-1-28.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Method)

/**
 *  替换类对象的一个方法
 *
 *  @param orignSelector 原对象的selector，类要找到对应的IMP一定要根据这个selector去找
 *  @param newIMP        新的实现方法,注意这个方法除了方法名不一样,参数和返回值都要跟原来的方法一致
 *
 *  @return newIMP
 */
+ (IMP)swizzleSelector:(SEL)orignSelector WithIMP:(IMP)newIMP;

/**
 *  把当前 curSelector 对应的实现方法替换为 orignSelector 对应的方法,注意类方法和对象方法之间不能对调,只在对象方法之间对调,类方法之间对调
 *  比如 Person 对象里面 有两个类方法 sayHi(正常调用的时候打印 NSLog(@"sayHi");) 和 sayHello(正常调用的时候打印 NSLog(@"sayHello");) ,当对调之后,调用  sayHi 会打印 NSLog(@"sayHello"); 调用  sayHello 会打印 NSLog(@"sayHi");
 *
 *  @param orignSelector
 *  @param curSelector
 */
+ (void)swizzleOriginSelectorIMP:(SEL)orignSelector WithSelector:(SEL)curSelector;

/**
 *  打印类中的所有方法,包括 implementation 中的方法
 */
+ (void)printObjecytMethods;

@end
