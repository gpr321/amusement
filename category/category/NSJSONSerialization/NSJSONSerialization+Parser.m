//
//  NSJSONSerialization+Parser.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSJSONSerialization+Parser.h"

@implementation NSJSONSerialization (Parser)

/**
 *  从指定的json文件中加载模型数组
 *  由于里面使用了KVC,因此模型里面一定不能缺少json key的属性
 *
 *  @param fileName json的文件名
 *  @param cls      模型的类型
 *
 *  @return 模型数组
 */

+ (NSArray *)gp_modelArrayFromJsonFile:(NSString *)fileName modelClass:(Class)cls{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:array.count];
    id model = nil;
    for (NSDictionary *item in array) {
        model = [[cls alloc] init];
        [item enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [model setValue:obj forKeyPath:key];
        }];
        [models addObject:model];
    }
    return models;
}

@end
