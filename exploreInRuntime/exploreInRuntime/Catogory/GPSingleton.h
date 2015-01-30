//
//  GPSingleton.h
//  exploreInRuntime
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#ifndef exploreInRuntime_GPSingleton_h
#define exploreInRuntime_GPSingleton_h

// 懒汉式单例模式
// 头文件
#define singtonInterface(className)\
+ (instancetype)share##className;


#if __has_feature(objc_arc)
// ARC部分
#define singtonImplement(className)\
static id instance = nil;\
+ (instancetype)share##className{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
instance = [[self alloc] init];\
});\
return instance;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
instance = [super allocWithZone:zone];\
});\
return instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
return instance;\
}
#else
// MRC部分
#define singtonImplement(className)\
static id instance = nil;\
+ (instancetype)share##className{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
instance = [[self alloc] init];\
});\
return instance;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
instance = [super allocWithZone:zone];\
});\
return instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
return instance;\
}\
- (instancetype)retain{\
return instance;\
}\
- (NSUInteger)retainCount{\
return ULLONG_MAX;\
}\
- (oneway void)release{\
}\
- (instancetype)autorelease{\
return instance;\
}

#endif

#endif
