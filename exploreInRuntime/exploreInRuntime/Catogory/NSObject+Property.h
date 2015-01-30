//
//  NSObject+Property.h
//  exploreInRuntime
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSString *const baseType = @"baseType";

@interface NSObject (Property)

/**
 *  添加一个属性到本对象中,这个方法实现的原理是使用运行时的关联关系
 *
 *  @param property 要添加的关联属性
 *  @param name     关联属性的名字
 *  @param policy   关联属性的组合关系
 */
- (void)setProperty:(id)property WithName:(NSString *)name policy:(objc_AssociationPolicy) policy;

/**
 *  根据属性名字获得一个对象的关联属性值
 *  (注意,这里只能获取,- (void)setProperty:(id)property WithName:(NSString *)name policy:(objc_AssociationPolicy) policy; 这个方法设置进去的属性值)
 *
 *  @param name 关联属性的名字
 *
 *  @return 关联属性的值
 */
- (id)propertyWithName:(NSString *)name;

/**
 *  获得属性列表,带下划线的那种
 *
 *  @return 属性列表
 */
+ (NSArray *)propertitesList;

/**
 *  获得属性列表,不带下划线的那种
 *
 *  @return 属性列表
 */
+ (NSArray *)privatePropertitesList;

/**
 *  获得属性字典 key : 不带下划线的属性名字 value : 属性的名字
 *
 *  @return 属性字典
 */
- (NSDictionary *)propertitesDictionary;

/**
 *  获得属性字典 key : 带下划线的属性名字 value : 属性的名字
 *
 *  @return 属性字典
 */
- (NSDictionary *)privatePropertitesDictionary;

/**
 *  遍历对象的属性
 *
 *  @param block 每当遍历一个对象的时候会调用一次block
 */
- (void)enumerateProperNameAndValueUsingBlock:(void(^)(NSString *name,id value,NSString *typeEncode))block;

@end
