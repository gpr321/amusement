//
//  NSString+SandBox.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSString+SandBox.h"

@implementation NSString (SandBox)

- (instancetype)cachesPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:self];
}

- (instancetype)documentPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:self];
}

- (instancetype)tempFile{
    NSString *path = NSTemporaryDirectory();
    return [path stringByAppendingPathComponent:self];
}

@end
