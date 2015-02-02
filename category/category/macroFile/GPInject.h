//
//  GPInject.h
//  category
//
//  Created by mac on 15-2-2.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

// 头文件快速注入
#define GPInjectH(name)\
\
- (instancetype)initWithDict:(NSDictionary *)dict; \
\
+ (instancetype)name##WithdDict:(NSDictionary *)dict; \
\
+ (NSArray *)name##sFromFile;

// .m文件快速注入 fileName不带扩展名
#define GPInjectM(name,fileName)\
\
- (instancetype)initWithDict:(NSDictionary *)dict{ \
    if ( self = [super init] ) { \
        [self setValuesForKeysWithDictionary:dict]; \
    } \
    return self; \
} \
\
+ (instancetype)name##WithdDict:(NSDictionary *)dict{ \
    return [[self alloc]initWithDict:dict]; \
} \
\
+ (NSArray *)name##sFromFile{ \
    NSString *fullPath = [[NSBundle mainBundle]pathForResource:@#fileName ofType:@"plist"]; \
    NSArray *array = [NSArray arrayWithContentsOfFile:fullPath]; \
    NSMutableArray *name##s = [NSMutableArray arrayWithCapacity:array.count]; \
    for (NSDictionary *item in array) { \
        [name##s addObject:[self name##WithdDict:item]]; \
    } \
    return name##s; \
} \