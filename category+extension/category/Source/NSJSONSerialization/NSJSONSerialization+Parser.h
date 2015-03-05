//
//  NSJSONSerialization+Parser.h
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Parser)
/**
 *  从指定的json文件中加载模型数组
 *  由于里面使用了KVC,因此模型里面一定不能缺少json key的属性
 *
 *  @param fileName json的文件名
 *  @param cls      模型的类型
 *
 *  @return 模型数组
 */

+ (NSArray *)gp_modelArrayFromJsonFile:(NSString *)fileName modelClass:(Class)cls;
@end
